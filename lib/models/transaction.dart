import 'package:intl/intl.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
}

class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String formattedDate;
  final String formattedAmount;
  final bool isRecurring;
  final RecurrenceFrequency? recurrenceFrequency; // daily, weekly, monthly
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
  });

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
      'isRecurring': isRecurring ? 1 : 0,
      'recurrenceFrequency': recurrenceFrequency,
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
