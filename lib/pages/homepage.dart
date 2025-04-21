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

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final category = _categoryController.text;
      final description = _descriptionController.text;

      context.read<ExpenseBloc>().add(AddExpense(
            amount: amount,
            category: category,
            description: description,
            date: _selectedDate ?? DateTime.now(),
          ));

      _amountController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedDate = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckIfUserIsLoggedIn());
    context.read<ExpenseBloc>().add(FetchExpenses());
    context.read<BalanceBloc>().add(CalculateBalance());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Get.to(() => const AuthPage());
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
                semanticLabel: 'Logout',
              ),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => const PieChartView());
              },
              icon: const Icon(Icons.pie_chart),
            ),
            IconButton(
              onPressed: () {},
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
                      }
                      if (state is BalanceError) {
                        return Center(
                          child: Text('Error: ${state.message}'),
                        );
                      }
                      if (state is BalanceCalculated) {
                        return TopCardAlternative(
                          balance: state.balance.toInt(),
                          income: state.income.toInt(),
                          expense: state.expense.toInt(),
                        );
                      }
                      return const SizedBox();
                    }),
                    Flexible(
                      child: ListView.builder(
                        itemCount: state.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];
                          return ListTile(
                            title: Text(expense.category),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(expense.date), // Format date
                            ),
                            trailing: Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
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
      context: context,
      builder: (context) {
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
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
                        ),
                      ),
                      TextButton(
                        onPressed: _presentDatePicker,
                        child: const Text(
                          'Choose Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: _submitExpense,
                  child: const Text('Add Expense'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
