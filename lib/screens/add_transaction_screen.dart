import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/models/recurrence_frequency.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/providers/category_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  String _recurrenceFrequency = 'None';
  final Logger logger = Logger();

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.parse(_amountController.text);
    final enteredCategory = _selectedCategory;
    final enteredDate = _selectedDate ?? DateTime.now();

    if (enteredCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    RecurrenceFrequency? recurrenceFrequency;
    if (_recurrenceFrequency != 'None') {
      try {
        recurrenceFrequency = RecurrenceFrequency.values.firstWhere(
          (e) => e.toString().split('.').last == _recurrenceFrequency,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid recurrence frequency')),
        );
        return;
      }
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      amount: enteredAmount,
      formattedAmount: '\$${enteredAmount.toStringAsFixed(2)}',
      category: enteredCategory,
      date: enteredDate,
      formattedDate: '${enteredDate.toLocal()}'.split(' ')[0],
      isRecurring: recurrenceFrequency != null,
      recurrenceFrequency: recurrenceFrequency,
      nextOccurrence: enteredDate,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction, context);
    logger.i('Submitted transaction: $newTransaction');

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Amount',
                    hintText: 'Enter the amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount field cannot be empty.';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Invalid number format.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Category',
                    hintText: 'Select a category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categoryProvider.categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Category selection is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Date',
                    hintText: 'Select a date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _recurrenceFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Recurring Frequency',
                    hintText: 'Select frequency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'None', child: Text('None')),
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _recurrenceFrequency = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _formKey.currentState?.validate() == true
                      ? _submitData
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
