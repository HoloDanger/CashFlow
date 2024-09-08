import 'package:flutter/foundation.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseService _databaseService;

  TransactionProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  List<Transaction> get transactions => _transactions;

  // Add a new transaction
  void addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    await _databaseService.insertTransaction(transaction);
    notifyListeners();
  }

  // Retrieve all transactions
  Future<void> fetchTransactions() async {
    _transactions = await _databaseService.getTransactions();
    notifyListeners();
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((txn) => txn.id == id);

    try {
      await _databaseService.deleteTransaction(id);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
