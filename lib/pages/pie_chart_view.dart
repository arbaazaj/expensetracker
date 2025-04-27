import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/expense/expense_bloc.dart';

class PieChartView extends StatelessWidget {
  const PieChartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pie Chart'),
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            // Group expenses by category
            final categoryTotals = <String, double>{};
            for (var expense in state.expenses) {
              categoryTotals[expense.type] =
                  (categoryTotals[expense.type] ?? 0) + expense.amount;
            }

            // Generate pie chart sections
            final pieSections = categoryTotals.entries.map((entry) {
              final color = Colors.primaries[
                  categoryTotals.keys.toList().indexOf(entry.key) %
                      Colors.primaries.length];
              return PieChartSectionData(
                value: entry.value,
                title: '${entry.key}\n${entry.value.toStringAsFixed(2)}',
                color: color,
                radius: 50,
                titleStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            );
          } else if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No expenses available.'));
          }
        },
      ),
    );
  }
}
