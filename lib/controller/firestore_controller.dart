import 'package:expensetracker/helper/firestore_db.dart';
import 'package:get/get.dart';
import 'package:expensetracker/models/model.dart';

class FirestoreController extends GetxController {

  Rx<List<Expense>> expenseList = Rx<List<Expense>>([]);
  List<Expense> get expenses => expenseList.value;

  @override
  void onReady() {
    super.onReady();
    expenseList.bindStream(FirestoreDb.expenseStream());
  }

}
