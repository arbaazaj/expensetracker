import 'package:expensetracker/blocs/balance/balance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/expense.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final BalanceBloc _balanceBloc;


  ExpenseBloc(this._balanceBloc) : super(ExpenseInitial()) {

    // Add expense.
    on<AddExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenseData = {
          'user_id': _supabase.auth.currentUser!.id,
          'amount': event.amount,
          'category': event.category,
          'description': event.description,
          'date': event.date.toIso8601String(),
        };

        await _supabase.from('expenses').insert(expenseData).whenComplete(() {
          add(FetchExpenses());

        }).catchError((onError) {
          emit(ExpenseError(message: 'Failed to add expense: ${onError.toString()}'));
        });
      } catch (error) {
        emit(ExpenseError(message: error.toString()));
      }
    });

    // Fetch expenses.
    on<FetchExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final response = await _supabase
            .from('expenses')
            .select()
            .eq('user_id', _supabase.auth.currentUser!.id)

            .order('created_at', ascending: false);
        if (response.isEmpty) {
          emit(
            ExpenseError(message: 'No expenses found'),
          );
        } else {
          final expenses = (response as List<dynamic>)
              .map((expenseData) => Expense.fromJson(expenseData))
              .toList();
          emit(ExpenseLoaded(expenses: expenses));
          // I want to call the balance bloc to update the balance using CalculateBalance event.
          _balanceBloc.add(CalculateBalance());
        }
      } catch (e) {
        emit(ExpenseError(message: e.toString()));
      }
    });
  }
}
