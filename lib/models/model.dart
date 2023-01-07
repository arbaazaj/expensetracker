import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? name;
  final int? amount;
  final bool? type;

  Expense({this.name, this.amount, this.type});

  factory Expense.fromFirestore(DocumentSnapshot snapshot) {
    return Expense(
      name: snapshot['name'],
      amount: snapshot['amount'],
      type: snapshot['type'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
    };
  }
}
