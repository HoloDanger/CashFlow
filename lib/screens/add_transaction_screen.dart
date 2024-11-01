import 'package:flutter/material.dart';
import 'package:money_tracker/utils/custom_exceptions.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/models/recurrence_frequency.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/providers/category_provider.dart';
import 'package:money_tracker/services/recurring_transaction_service.dart';
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

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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

  void _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredAmount = double.parse(_amountController.text);
    final enteredCategory = _selectedCategory;
    final enteredDate = _selectedDate ?? DateTime.now();

    if (enteredCategory == null) {
      _showSnackBar('Please select a category');
      return;
    }

    RecurrenceFrequency? recurrenceFrequency;
    if (_recurrenceFrequency != 'None') {
      try {
        recurrenceFrequency = RecurrenceFrequency.values.firstWhere(
          (e) =>
              e.toString().split('.').last.toLowerCase() ==
              _recurrenceFrequency.toLowerCase(),
        );
      } catch (e) {
        _showSnackBar('Invalid recurrence frequency');
        return;
      }
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      amount: enteredAmount,
      formattedAmount: '₱${enteredAmount.toStringAsFixed(2)}',
      category: enteredCategory,
      date: enteredDate,
      formattedDate: '${enteredDate.toLocal()}'.split(' ')[0],
      isRecurring: recurrenceFrequency != null,
      recurrenceFrequency: recurrenceFrequency,
      nextOccurrence: recurrenceFrequency != null
          ? calculateNextOccurrence(enteredDate, recurrenceFrequency)
          : enteredDate,
    );

    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final recurringTransactionService =
        Provider.of<RecurringTransactionService>(context, listen: false);

    try {
      await transactionProvider.addTransaction(newTransaction, _showSnackBar);
      logger.i('Submitted transaction: $newTransaction');

      if (newTransaction.isRecurring &&
          newTransaction.recurrenceFrequency != null) {
        recurringTransactionService
            .scheduleRecurringTransaction(newTransaction);
        _showSnackBar('Recurring transaction added successfully!');
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on TransactionNotFoundException catch (e) {
      logger.e('Transaction not found exception: ${e.message}');
      _showSnackBar(e.message);
    } catch (error) {
      logger.e('Error adding transaction: $error');
      _showSnackBar('Failed to add transaction.');
    }
  }

  DateTime calculateNextOccurrence(
      DateTime date, RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        final int year = date.month == 12 ? date.year + 1 : date.year;
        final int month = date.month == 12 ? 1 : date.month + 1;
        final int day =
            date.day > 28 ? 28 : date.day; // To handle shorter months
        return DateTime(year, month, day);
      default:
        return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Handle drawer open if applicable
          },
        ),
        title: Text(
          'Add Transaction',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontVariations: <FontVariation>[FontVariation('wght', 700)],
            shadows: <Shadow>[
              Shadow(
                offset: Offset(-2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAD73), Color(0xFFAABD36)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Transaction Amount Field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Amount',
                    hintText: 'Enter the amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Amount field cannot be empty.';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null) {
                      return 'Invalid number format.';
                    }
                    if (amount <= 0) {
                      return 'Amount must be greater than zero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Transaction Category Dropdown
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
                            child: Text(
                              category,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 16,
                              ),
                            ),
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

                // Transaction Date Picker
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
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required.';
                    }
                    final selectedDate = DateTime.tryParse(value);
                    if (selectedDate == null) {
                      return 'Invalid date format.';
                    }
                    if (selectedDate.isAfter(
                        DateTime.now().add(const Duration(days: 365)))) {
                      return 'Date cannot be more than a year in the future.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Recurrence Frequency Dropdown
                DropdownButtonFormField<String>(
                  value: _recurrenceFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Recurring Frequency',
                    hintText: 'Select frequency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'None',
                      child: Text(
                        'None',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Daily',
                      child: Text(
                        'Daily',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Weekly',
                      child: Text(
                        'Weekly',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Monthly',
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (newValue) {
                    setState(() {
                      _recurrenceFrequency = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Fredoka',
                    ),
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
