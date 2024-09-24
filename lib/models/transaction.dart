import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;
  final String formattedDate;
  final String formattedAmount;
  final String? recurringFrequency;

  Transaction(
      {required this.id,
      required this.amount,
      required this.category,
      required this.date,
      this.recurringFrequency})
      : formattedDate = DateFormat('MMM dd, yyyy').format(date),
        formattedAmount = NumberFormat.currency(
          locale: 'en_PH',
          symbol: '₱',
          decimalDigits: 2,
        ).format(amount);

  // Convert to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  // Create a Transaction from a map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    // Handle potential parsing errors
    try {
      return Transaction(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(), // Ensure amount is a double
        category: map['category'] as String,
        date: DateTime.parse(map['date'] as String),
      );
    } catch (e) {
      throw FormatException('Error parsing transaction data: ${e.toString()}');
    }
  }

  // Override toString for better debugging
  @override
  String toString() {
    return 'Transaction{id: $id, amount: $amount, category: $category, date: $date}';
  }

  // Override equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.date == date;
  }

  @override
  int get hashCode =>
      id.hashCode ^ amount.hashCode ^ category.hashCode ^ date.hashCode;

  // Create a copy of the Transaction with optional modifications
  Transaction copyWith(
      {String? id, double? amount, String? category, DateTime? date}) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }
}
