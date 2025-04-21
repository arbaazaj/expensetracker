part of 'balance_bloc.dart';

@immutable
sealed class BalanceEvent {}

final class CalculateBalance extends BalanceEvent {}
