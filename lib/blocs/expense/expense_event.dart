part of 'expense_bloc.dart';

@immutable
sealed class ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final double amount;
  final String type;
  final String category;
  final String? description;
  final DateTime date;

  AddExpense({
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });
}

class FetchExpenses extends ExpenseEvent {}

class DeleteExpense extends ExpenseEvent {
  final String id;

  DeleteExpense({required this.id});
}