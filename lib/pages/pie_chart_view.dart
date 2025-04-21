import 'package:flutter/material.dart';

class PieChartView extends StatelessWidget {
  const PieChartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Pie Chart'),
      ),
      body: Center(
        child: Text(
          'Pie Chart View\n Coming soon...',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
