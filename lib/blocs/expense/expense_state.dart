part of 'expense_bloc.dart';

@immutable
sealed class ExpenseState {}

final class ExpenseInitial extends ExpenseState {}

final class ExpenseLoading extends ExpenseState {}

final class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;

  ExpenseLoaded({required this.expenses});
}

final class ExpenseAdded extends ExpenseState {}

final class ExpenseError extends ExpenseState {
  final String message;

  ExpenseError({required this.message});
}
