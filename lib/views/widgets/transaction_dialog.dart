import 'package:flutter/material.dart';
import 'package:hive_db/models/transaction.dart';

class TransactionDialog extends StatefulWidget {
  final Transaction? transaction;
  final Function(String name, double amount, bool isExpense) onClickedDone;

  const TransactionDialog({
    Key? key,
    this.transaction,
    required this.onClickedDone,
  }) : super(key: key);

  @override
  TransactionDialogState createState() => TransactionDialogState();
}

class TransactionDialogState extends State<TransactionDialog> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  bool isExpense = true;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final transaction = widget.transaction!;
      nameController.text = transaction.name;
      amountController.text = transaction.amount.toString();
      isExpense = transaction.isExpense;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final title = isEditing ? 'Edit Transaction' : 'Add Transaction';

    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Name',
                ),
                controller: nameController,
                keyboardType: TextInputType.name,
                validator: (name) {
                  if (name != null && name.isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Amount',
                ),
                controller: amountController,
                keyboardType: TextInputType.number,
                validator: (amount) {
                  if (amount != null && double.tryParse(amount) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  RadioListTile<bool>(

                    title: const Text('Expense'),
                    value: true,
                    groupValue: isExpense,
                    onChanged: (value) => setState(() => isExpense = value!),
                  ),
                  RadioListTile<bool>(
                    title: const Text('Income'),
                    value: false,
                    groupValue: isExpense,
                    onChanged: (value) => setState(() => isExpense = value!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(isEditing ? 'Save' : 'Add'),
          onPressed: () async {
            final isValid = formKey.currentState!.validate();

            if (isValid) {
              final name = nameController.text;
              final amount = double.tryParse(amountController.text) ?? 0;
              widget.onClickedDone(name, amount, isExpense);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
