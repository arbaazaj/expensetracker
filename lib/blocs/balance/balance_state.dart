part of 'balance_bloc.dart';

@immutable
sealed class BalanceState {}

final class BalanceInitial extends BalanceState {}

final class BalanceLoading extends BalanceState {}

final class BalanceCalculated extends BalanceState {
  final double balance;
  final double income;
  final double expense;

  BalanceCalculated({
    required this.balance,
    required this.income,
    required this.expense,
  });
}

final class BalanceError extends BalanceState {
  final String message;

  BalanceError({required this.message});
}