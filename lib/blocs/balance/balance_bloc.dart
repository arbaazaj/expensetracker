import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'balance_event.dart';
part 'balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  BalanceBloc() : super(BalanceInitial()) {
    on<CalculateBalance>((event, emit) async {
      emit(BalanceLoading());
      try {
        final userId = _supabase.auth.currentUser?.id;

        // Fetch income and expense data from Supabase
        final response = await _supabase
            .from('expenses')
            .select('amount, category')
            .eq('user_id', userId!);

        // Filter income data from the response
        final List<Map<String, dynamic>> incomeList =
            (response as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .where((e) => e['category'] == 'income')
                .toList();

        // Filter expense data from the response
        final List<Map<String, dynamic>> expenseList =
            (response as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .where((e) => e['category'] == 'expense')
                .toList();

        // Calculate total income and expense
        double totalIncome = 0.0;
        if (incomeList.isNotEmpty) {
          totalIncome = incomeList
              .map((e) => (e['amount'] as num).toDouble())
              .reduce((a, b) => a + b);
        }

        // Assuming the expense category is 'expense'
        double totalExpense = 0.0;
        if (expenseList.isNotEmpty) {
          totalExpense = expenseList
              .map((e) => (e['amount'] as num).toDouble())
              .reduce((a, b) => a + b);
        }

        // Calculate the balance
        final balance = totalIncome - totalExpense;

        emit(BalanceCalculated(
          balance: balance,
          income: totalIncome,
          expense: totalExpense,
        ));
      } catch (error) {
        emit(BalanceError(message: error.toString()));
      }
    });
  }
}
