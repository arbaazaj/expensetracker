import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/pages/login_page.dart';
import 'package:expensetracker/pages/pie_chart_view.dart';
import 'package:expensetracker/utils/error_string_interpolation.dart';
import 'package:expensetracker/widgets/custom_floating_action_button.dart';
import 'package:expensetracker/widgets/top_card_alternative.dart';
import 'package:expensetracker/widgets/transaction_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Initialize Firestore.
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // collect user input
  final _textControllerAmount = TextEditingController();
  final _textControllerItem = TextEditingController();

  // Form Global key to manage dialog state.
  final _formKey = GlobalKey<FormState>();

  // Variables.
  bool _isIncome = false;
  bool isUserSignedIn = false;
  int _sumOfAllIncome = 0;
  int _sumOfAllExpense = 0;
  int _balanceLeft = 0;

  // Keyboard focus
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();

  // Scroll Controller for the list to hide fab on scroll.
  final ScrollController _controller = ScrollController();

  // Firebase Firestore api calls.
  final Stream<QuerySnapshot> _expensesRef = FirebaseFirestore.instance
      .collection('expenses')
      .orderBy('timestamp', descending: true)
      .snapshots();
  final Stream<DocumentSnapshot> _expenseTotalStreamRef = FirebaseFirestore
      .instance
      .collection('expenseTotal')
      .doc('total')
      .snapshots();
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('expenses');
  final CollectionReference _expenseTotalCollectionRef =
      FirebaseFirestore.instance.collection('expenseTotal');

  // Call to collection of expenses.
  Future<QuerySnapshot<Object?>> callRef() async {
    final response = await _collectionRef.get();
    return response;
  }

  // Calculating and updating documents.
  void calculateExpenses() async {
    // For income.
    try {
      callRef().then((response) {
        for (var income in response.docs) {
          if (income.get('type') == 'income') {
            _sumOfAllIncome =
                _sumOfAllIncome + int.parse(income.get('amount').toString());
          }
        }
        _balanceLeft = _sumOfAllIncome;
        addTotalExpensesToFirestore();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
    // For expense.
    try {
      callRef().then((response) {
        for (var expense in response.docs) {
          if (expense.get('type') == 'expense') {
            _sumOfAllExpense =
                _sumOfAllExpense + int.parse(expense.get('amount').toString());
          }
        }
        _sumOfAllIncome = _sumOfAllIncome - _sumOfAllExpense;
        _balanceLeft = _sumOfAllIncome;
        addTotalExpensesToFirestore();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  // Call to collection of expenseTotal and update it.
  void addTotalExpensesToFirestore() async {
    try {
      await _expenseTotalCollectionRef.doc('total').update({
        'balance': _balanceLeft,
        'income': _sumOfAllIncome,
        'expense': _sumOfAllExpense
      }).then((value) {
        _balanceLeft = 0;
        _sumOfAllIncome = 0;
        _sumOfAllExpense = 0;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Check if user is signed in.
  Future checkIfUserIsSignedIn() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          isUserSignedIn = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfUserIsSignedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[750],
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: () => onPressedAccountIcon(context),
            icon: isUserSignedIn
                ? const Icon(Icons.logout, semanticLabel: 'Account')
                : const Icon(Icons.account_circle, semanticLabel: 'Logout'),
          ),
          IconButton(
            onPressed: () => Get.to(() => const PieChartView()),
            icon: const Icon(Icons.pie_chart),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 10.0, left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          children: [
            // Top card with balance, income and expense data fetching in realtime from expenseTotal collection.
            StreamBuilder<DocumentSnapshot>(
                stream: _expenseTotalStreamRef,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Top card to display data.
                  return TopCardAlternative(
                    balance: snapshot.data!.get('balance'),
                    income: snapshot.data!.get('income'),
                    expense: snapshot.data!.get('expense'),
                  );
                }),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Expanded(
                      // Listview with expenses collection.
                      child: StreamBuilder<QuerySnapshot>(
                          stream: _expensesRef,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              if (snapshot.error
                                  .toString()
                                  .contains(firestorePermissionDeniedError)) {
                                return Center(
                                  child: Text('You need to Sign in first',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500)),
                                );
                              }
                              return Text(
                                  'Something went wrong: ${snapshot.error}',
                                  style: TextStyle(color: Colors.grey[700]));
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return ListView(
                              controller: _controller,
                              children: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TransactionCard(
                                    transactionName: data['name'],
                                    money: '${data['amount']}',
                                    expenseOrIncome: data['type'],
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Custom FAB with hide on scroll feature.
      floatingActionButton: CustomFAB(
        controller: _controller,
        onPressed: () => _buildTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void onPressedAccountIcon(BuildContext context) {
    if (isUserSignedIn) {
      FirebaseAuth.instance.signOut().then((value) {
        Get.snackbar('>', 'Logging out...');
        setState(() {
          isUserSignedIn = false;
        });
        Get.toNamed('/login');
      });
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  // onPressed Action for fab which opens a dialog with a form including controls to add a transaction.
  void _buildTransactionDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return AlertDialog(
                title: const Text('Add Transaction'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text('Expense'),
                          Switch(
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            value: _isIncome,
                            onChanged: (newValue) {
                              setState(() {
                                _isIncome = newValue;
                              });
                            },
                          ),
                          const Text('Income'),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: TextFormField(
                                focusNode: focusNode,
                                onEditingComplete: () {
                                  setState(() {
                                    focusNode.nextFocus();
                                  });
                                },
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Amount?',
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return 'Enter an amount';
                                  }
                                  return null;
                                },
                                controller: _textControllerAmount,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: focusNode2,
                              onSubmitted: (_) {
                                setState(() {
                                  focusNode2.unfocus();
                                });
                              },
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'For what?',
                              ),
                              controller: _textControllerItem,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  MaterialButton(
                    color: Colors.grey[600],
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.grey[600],
                    child: const Text('Enter',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => _addExpenseTransaction(),
                  )
                ],
              );
            },
          );
        });
  }

  // onPressed Enter action on the form control inside dialog box.
  // Adds a new transaction to the expenses collection also updates the expenseTotal collection.
  void _addExpenseTransaction() async {
    if (_formKey.currentState!.validate()) {
      String name = _textControllerItem.text;
      String amount = _textControllerAmount.text;
      String type = _isIncome ? 'income' : 'expense';
      await _collectionRef.add({
        'name': name,
        'amount': amount,
        'type': type,
        'timestamp': Timestamp.now()
      }).then((value) {
        Navigator.of(context).pop();
        _textControllerItem.clear();
        _textControllerAmount.clear();
        calculateExpenses();
      }).catchError((onError) {
        if (kDebugMode) {
          print(onError);
        }
      });
    }
  }
}
