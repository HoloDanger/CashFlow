import 'package:intl/intl.dart';
import 'package:money_tracker/models/recurrence_frequency.dart';

/// Represents a financial transaction.
class Transaction {
  // Unique identifier for the transaction.
  final String id;
  // Amount of the transaction.
  final double amount;
  // Category of the transaction.
  final String category;
  // Date of the transaction.
  final DateTime date;
  // Formatted date string for display.
  final String formattedDate;
  // Formatted amount string for display.
  final String formattedAmount;
  // Indicates if the transaction is recurring.
  final bool isRecurring;
  // Frequency of recurrence if the transaction is recurring.
  final RecurrenceFrequency? recurrenceFrequency;
  // Next occurrence of the recurring transaction.
  final DateTime nextOccurrence;

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.formattedDate,
    required this.formattedAmount,
    this.isRecurring = false,
    this.recurrenceFrequency,
    required this.nextOccurrence,
  }) : assert(!isRecurring || recurrenceFrequency != null,
            'Recurring transactions must have a recurrence frequency.');

  // Factory method to create a Transaction from a map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Handle potential parsing errors
    try {
      return Transaction(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(), // Ensure amount is a double
        category: map['category'] as String,
        date: DateTime.parse(map['date'] as String),
        formattedDate:
            DateFormat.yMMMEd().format(DateTime.parse(map['date'] as String)),
        formattedAmount:
            NumberFormat.currency(symbol: '\$').format(map['amount']),
        isRecurring: map['isRecurring'] == 1,
        recurrenceFrequency: map['recurrenceFrequency'] != null
            ? RecurrenceFrequency.values.firstWhere((e) =>
                e.toString().split('.').last == map['recurrenceFrequency'])
            : null,
        nextOccurrence: DateTime.parse(map['nextOccurrence'] as String),
      );
    } catch (e) {
      // Handle parsing errors
      throw FormatException('Error parsing transaction: $e');
    }
  }

  // Method to convert a Transaction to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'formattedDate': formattedDate,
      'formattedAmount': formattedAmount,
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceFrequency': recurrenceFrequency?.toString().split('.').last,
      'nextOccurrence': nextOccurrence.toIso8601String(),
    };
  }

  // Create a copy of the Transaction with optional modifications
  Transaction copyWith({
    String? id,
    double? amount,
    String? category,
    DateTime? date,
    bool? isRecurring,
    RecurrenceFrequency? recurrenceFrequency,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      formattedDate: formattedDate,
      formattedAmount: formattedAmount,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceFrequency: recurrenceFrequency ?? this.recurrenceFrequency,
      nextOccurrence: nextOccurrence,
    );
  }

  // Override toString method for better debugging
  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, category: $category, date: $date, isRecurring: $isRecurring, recurrenceFrequency: $recurrenceFrequency, nextOccurrence: $nextOccurrence}';
  }

  // Override == operator for comparing instances
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.date == date &&
        other.isRecurring == isRecurring &&
        other.recurrenceFrequency == recurrenceFrequency &&
        other.nextOccurrence == nextOccurrence;
  }

  // Override hashCode for using instances in collections
  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        category.hashCode ^
        date.hashCode ^
        isRecurring.hashCode ^
        recurrenceFrequency.hashCode ^
        nextOccurrence.hashCode;
  }
}
