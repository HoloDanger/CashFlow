import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.parse(_amountController.text);
    final enteredCategory = _categoryController.text;

    final newTranslation = Transaction(
      id: const Uuid().v4(),
      amount: enteredAmount,
      category: enteredCategory,
      date: _selectedDate,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTranslation);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter an amount';
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter a category';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
