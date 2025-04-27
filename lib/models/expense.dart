import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String category;
  final String? description;
  final DateTime date;

  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'].toString(),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'category': category.toString(),
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  @override
  List<Object?> get props =>
      [id, userId, amount, type, category, description, date];
}
