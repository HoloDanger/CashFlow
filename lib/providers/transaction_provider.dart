import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  final DatabaseService _databaseService;

  final Logger logger = Logger();

  TransactionProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  List<Transaction> get transactions => _transactions;

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      _transactions.add(transaction);
      await _databaseService.insertTransaction(transaction);
      notifyListeners();
    } catch (error) {
      logger.e('Failed to add transaction: $error');
    }
  }

  // Retrieve all transactions
  Future<void> fetchTransactions() async {
    try {
      logger.i('Fetching transactions from database.');
      _transactions = await _databaseService.getTransactions();
      notifyListeners();
    } catch (error) {
      logger.e('Error fetching transactions: $error');
      rethrow;
    }
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
