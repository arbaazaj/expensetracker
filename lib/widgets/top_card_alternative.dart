import 'package:flutter/material.dart';

class TopCardAlternative extends StatelessWidget {
  final int? balance;
  final int? income;
  final int? expense;

  const TopCardAlternative(
      {Key? key,
      required this.balance,
      required this.income,
      required this.expense})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      elevation: 8.0,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Text('BALANCE', style: TextStyle(fontSize: 32)),
            ),
            Text('\$$balance',
                style: const TextStyle(fontSize: 20, color: Colors.green)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Income
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                          text: 'Income\n',
                          style: const TextStyle(fontSize: 12),
                          children: [
                            TextSpan(
                                text: '\$$income',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.green)),
                          ]),
                    ),
                  ],
                ),
                // Expense
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: RichText(
                        text: TextSpan(
                            text: 'Expense\n',
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                  text: '\$$expense',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.red)),
                            ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
