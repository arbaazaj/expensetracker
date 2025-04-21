import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'balance_event.dart';
part 'balance_state.dart';

class BalanceBloc extends Bloc<BalanceEvent, BalanceState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  BalanceBloc() : super(BalanceInitial()) {
    on<CalculateBalance>((event, emit) async {
      emit(BalanceLoading());
      try {
        // Fetch income and expense data from Supabase
        final incomeResponse = await _supabase
            .from('expenses')
            .select('amount')
            .eq('category', 'income');

        // Assuming the expense category is 'expense'
        final expenseResponse = await _supabase
            .from('expenses')
            .select('amount')
            .eq('category', 'expense');

        // Calculate total income and expense
        final income = (incomeResponse as List<dynamic>?)
                ?.map((e) => (e['amount'] as num).toDouble())
                .reduce((a, b) => a + b) ??
            0.0;

        // Assuming the expense category is 'expense'
        final expense = (expenseResponse as List<dynamic>?)
                ?.map((e) => (e['amount'] as num).toDouble())
                .reduce((a, b) => a + b) ??
            0.0;

        // Calculate the balance
        final balance = income - expense;

        emit(BalanceCalculated(
          balance: balance,
          income: income,
          expense: expense,
        ));
      } catch (error) {
        emit(BalanceError(message: error.toString()));
      }
    });
  }
}
