import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_db/boxes.dart';
import 'package:hive_db/models/transaction.dart';
import 'package:hive_db/views/widgets/transaction_dialog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  TransactionPageState createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Hive Expense Tracker'),
          centerTitle: true,
        ),
        body: ValueListenableBuilder<Box<Transaction>>(
          valueListenable: StoredBoxes.getTransactions().listenable(),
          builder: (context, box, widget) {
            final transactions = box.values.toList().cast<Transaction>();
            log('Values: ${box.values}');
            log('Keys: ${box.keys}');
            return buildContent(transactions);
          },
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return TransactionDialog(
                      onClickedDone: addTransaction,
                    );
                  });
            }),
      );

  Widget buildContent(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'No expenses yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final netExpense = transactions.fold<double>(
        0,
        (previousValue, transaction) => transaction.isExpense
            ? previousValue - transaction.amount
            : previousValue + transaction.amount,
      );
      final newExpenseString = '${netExpense.toStringAsFixed(2)} LE';
      final color = netExpense > 0 ? Colors.green : Colors.red;

      return Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Net Expense: $newExpenseString',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                final transaction = transactions[index];
                return buildTransaction(context, transaction);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildTransaction(
    BuildContext context,
    Transaction transaction,
  ) {
    final color = transaction.isExpense ? Colors.red : Colors.green;
    final date = DateFormat.yMMMd().format(transaction.createdDate);
    //final amount = '${transaction.amount.toStringAsFixed(2)} \$';
    final amount = '${transaction.amount.toStringAsFixed(2)} LE';

    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Text(
          transaction.name,
          maxLines: 2,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(date),
        trailing: Text(
          amount,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          buildButtons(context, transaction),
        ],
      ),
    );
  }

  Widget buildButtons(BuildContext context, Transaction transaction) => Row(
        children: [
          Expanded(
            child: TextButton.icon(
                label: const Text('Edit'),
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return TransactionDialog(
                        transaction: transaction,
                        onClickedDone: (name, amount, isExpense) =>
                            editTransaction(
                                transaction, name, amount, isExpense),
                      );
                    },
                  );
                }),
          ),
          Expanded(
            child: TextButton.icon(
              label: const Text('Delete'),
              icon: const Icon(Icons.delete),
              onPressed: () => deleteTransaction(transaction),
            ),
          )
        ],
      );

  Future addTransaction(String name, double amount, bool isExpense) async {
    final transaction = Transaction()
      ..name = name
      ..createdDate = DateTime.now()
      ..amount = amount
      ..isExpense = isExpense;

    final box = StoredBoxes.getTransactions();
    box.add(transaction);


    ///OR...
    /*    box.put('key1', transaction);
    final myTransaction = box.get('key');
    log('Transaction added: $myTransaction');*/
  }

  void editTransaction(
    Transaction transaction,
    String name,
    double amount,
    bool isExpense,
  ) {
    transaction.name = name;
    transaction.amount = amount;
    transaction.isExpense = isExpense;

    /*    log('Key: ${transaction.key}');
    final box = StoredBoxes.getTransactions();
    box.put(transaction.key, transaction);*/
    ///OR...
    transaction.save();
  }

  void deleteTransaction(Transaction transaction) {

    /*    final box = StoredBoxes.getTransactions();
    box.delete(transaction.key);*/
    ///OR...
    transaction.delete();
  }

  @override
  Future<void> dispose() async {
    await StoredBoxes.getTransactions().compact();
    Hive.close(); //Close all open boxes
    //Hive.box('transaction').close(); //To close specific box
    super.dispose();
  }
}
