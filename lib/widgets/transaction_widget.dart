import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String transactionName;
  final String money;
  final String expenseOrIncome;

  const TransactionCard(
      {Key? key,
      required this.transactionName,
      required this.money,
      required this.expenseOrIncome})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.grey[900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey[500]),
                  child: Center(
                      child: Icon(
                    Icons.attach_money_outlined,
                    color: Colors.grey[900],
                  )),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(transactionName,
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            Text(
              '${expenseOrIncome == 'expense' ? '-' : '+'}\$$money',
              style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: 16,
                color: expenseOrIncome == 'expense' ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
