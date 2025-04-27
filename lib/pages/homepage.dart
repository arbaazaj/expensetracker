import 'package:expensetracker/blocs/authentication/auth_bloc.dart';
import 'package:expensetracker/blocs/balance/balance_bloc.dart';
import 'package:expensetracker/blocs/expense/expense_bloc.dart';
import 'package:expensetracker/pages/auth_page.dart';
import 'package:expensetracker/pages/pie_chart_view.dart';
import 'package:expensetracker/widgets/custom_floating_action_button.dart';
import 'package:expensetracker/widgets/top_card_ui/top_card_alternative.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // Scroll Controller for the list to hide fab on scroll.
  final ScrollController _controller = ScrollController();
  final ScrollController _listController = ScrollController();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime? _selectedDate;
  bool _isIncome = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _presentDatePicker(StateSetter modalSetState) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      modalSetState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitExpense(StateSetter modalSetState) {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;
      final category = _categoryController.text;

      context.read<ExpenseBloc>().add(AddExpense(
            amount: amount,
            type: _isIncome ? 'income' : 'expense',
            category: category,
            description: description,
            date: _selectedDate ?? DateTime.now(),
          ));
      modalSetState(() {
        context.read<BalanceBloc>().add(CalculateBalance());
        _listController.animateTo(0.0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
        _amountController.clear();
        _descriptionController.clear();
        _selectedDate = null;
        _isIncome = false;
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _listController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    context.read<AuthBloc>().add(CheckIfUserIsLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Get.to(() => const AuthPage());
        }
        if (state is AuthAuthenticated) {
          context.read<ExpenseBloc>().add(FetchExpenses());
          context.read<BalanceBloc>().add(CalculateBalance());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[750],
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(
                Icons.currency_rupee,
                color: Colors.green,
              ),
              SizedBox(
                width: 2.0,
              ),
              Flexible(
                  child: Text(
                'Expense Tracker',
                style:
                    TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              )),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.account_circle,
                semanticLabel: 'Profile',
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const PieChartView());
              },
              icon: const Icon(Icons.pie_chart),
            ),
            IconButton(
              onPressed: () {
                showMenu(
                  position: const RelativeRect.fromLTRB(20.0, 100.0, 0.0, 0.0),
                  context: context,
                  items: [
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                      onTap: () {
                        context.read<AuthBloc>().add(SignOutRequested());
                      },
                    ),
                  ],
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExpenseLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    BlocBuilder<BalanceBloc, BalanceState>(
                        builder: (context, state) {
                      if (state is BalanceLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is BalanceError) {
                        return Center(
                          child: Text('Error: ${state.message}'),
                        );
                      } else if (state is BalanceCalculated) {
                        return TopCardAlternative(
                          balance: state.balance.toInt(),
                          income: state.income.toInt(),
                          expense: state.expense.toInt(),
                        );
                      } else {
                        return const Center(
                          child: Text('No balance data available'),
                        );
                      }
                    }),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView.builder(
                        controller: _listController,
                        reverse: false,
                        shrinkWrap: true,
                        itemCount: state.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];

                          return Dismissible(
                            key: Key(expense.id),
                            background: Container(
                              color: Colors.red,
                              child: const Icon(Icons.delete),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                context
                                    .read<ExpenseBloc>()
                                    .add(DeleteExpense(id: expense.id));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                    Text('${expense.description} deleted'),
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              isThreeLine: true,
                              title: Text(
                                expense.description == null
                                    ? expense.type
                                    : expense.description!,
                                style: TextStyle(
                                  color: expense.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat('${expense.category}\ndd/MM/yyyy')
                                    .format(expense.date), // Format date
                              ),
                              trailing: Text(
                                expense.type == 'income'
                                    ? '+\$${expense.amount.toStringAsFixed(2)}'
                                    : '-\$${expense.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: expense.type == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ExpenseError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No expenses yet.'));
            }
          },
        ),
        // Custom FAB with hide on scroll feature.
        floatingActionButton: CustomFAB(
          controller: _controller,
          onPressed: () => _buildTransactionModal(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // onPressed Action for fab which opens a dialog with a form including
  // controls to add a transaction.
  void _buildTransactionModal(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Switch for income/expense
                          Text(
                            'Type:',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Expense',
                                style: !_isIncome
                                    ? TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )
                                    : TextStyle(
                                        fontSize: 16,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Switch(
                                value: _isIncome,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: WidgetStatePropertyAll(
                                  _isIncome ? Colors.green : Colors.red,
                                ),
                                activeColor: Colors.transparent,
                                trackOutlineColor: WidgetStatePropertyAll(
                                  _isIncome ? Colors.green : Colors.red,
                                ),
                                onChanged: (value) {
                                  modalSetState(() {
                                    _isIncome = value;
                                  });
                                },
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Income',
                                style: _isIncome
                                    ? TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      )
                                    : TextStyle(
                                        fontSize: 16,
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _categoryController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No Date Chosen!'
                                  : 'Picked Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              modalSetState(() {
                                _presentDatePicker(modalSetState);
                              });
                            },
                            child: const Text(
                              'Choose Date',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _submitExpense(modalSetState);
                      },
                      child: const Text('Add Expense'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
