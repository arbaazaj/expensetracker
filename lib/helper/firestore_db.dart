import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/constants/constants.dart';
import 'package:expensetracker/models/model.dart';

class FirestoreDb {
  static addIncome(Expense income) async {}

  static addExpense(Expense expense) async {}

  static Stream<List<Expense>> expenseStream() {
    return firebaseFirestore
        .collection('expenses')
        .snapshots()
        .map((QuerySnapshot snapshot) {
      List<Expense> expensesList = [];
      for (var expense in snapshot.docs) {
        final expenseModel = Expense.fromFirestore(expense);
        expensesList.add(expenseModel);
      }
      return expensesList;
    });
  }
}
