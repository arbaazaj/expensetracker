import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/pages/login_page.dart';
import 'package:expensetracker/utils/error_string_interpolation.dart';
import 'package:expensetracker/widgets/top_card_alternative.dart';
import 'package:expensetracker/widgets/transaction_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  // Firebase Firestore api calls.
  final Stream<QuerySnapshot> _expensesRef = FirebaseFirestore.instance
      .collection('expenses')
      .orderBy('timestamp')
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

  // Calculate Total Income.
  void calculateIncome() async {
    await _collectionRef.where('type', isEqualTo: 'income').get().then(
      (res) {
        for (var element in res.docs) {
          var amount = element.get('amount');
          _sumOfAllIncome = _sumOfAllIncome + int.parse(amount.toString());
        }
        calculateExpenses();
      },
      onError: (e) {
        if (kDebugMode) {
          print("Error completing: $e");
        }
      },
    );
  }

  // Calculate Total Expenses.
  void calculateExpenses() async {
    await _collectionRef.where('type', isEqualTo: 'expense').get().then(
        (value) {
      for (var expense in value.docs) {
        var amount = expense.get('amount');
        _sumOfAllExpense = _sumOfAllExpense + int.parse(amount.toString());
      }
      _balanceLeft = _sumOfAllIncome - _sumOfAllExpense;
      addTotalExpensesToFirestore();
    }, onError: (error) {
      if (kDebugMode) {
        print("Error completing: $error");
      }
    });
  }

  void addTotalExpensesToFirestore() async {
    try {
      await _expenseTotalCollectionRef.doc('total').update({
        'balance': _balanceLeft,
        'income': _sumOfAllIncome,
        'expense': _sumOfAllExpense
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
    setState(() {
      calculateIncome();
    });
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 10.0, left: 16.0, right: 16.0, bottom: 8.0),
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: _expenseTotalStreamRef,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buildTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void onPressedAccountIcon(BuildContext context) {
    if (isUserSignedIn) {
      FirebaseAuth.instance.signOut().then((value) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Logging Out...')));
        setState(() {
          isUserSignedIn = false;
        });
      });
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

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

  Future _addExpenseTransaction() async {
    if (_formKey.currentState!.validate()) {
      String name = _textControllerItem.text;
      String amount = _textControllerAmount.text;
      String type = _isIncome ? 'income' : 'expense';
      return await _collectionRef.add({
        'name': name,
        'amount': amount,
        'type': type,
        'timestamp': Timestamp.now()
      }).then((value) {
        Navigator.of(context).pop();
        _textControllerItem.clear();
        _textControllerAmount.clear();
        setState(() {
          calculateExpenses();
          addTotalExpensesToFirestore();
        });
      }).catchError((onError) {
        if (kDebugMode) {
          print(onError);
        }
      });
    }
  }
}
