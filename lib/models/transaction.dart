class Transaction {
  final String id;
  final double amount;
  final String category;
  final DateTime date;

  Transaction(
      {required this.id,
      required this.amount,
      required this.category,
      required this.date});

  // For database storage, add methods to convert to/from map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}
