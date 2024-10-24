import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DatabaseService _databaseService;
  final Logger logger = Logger();

  TransactionProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  List<Transaction> get transactions =>
      List.unmodifiable(_transactions); // Prevent external modification

  // Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _databaseService.insertTransaction(transaction);
      _transactions.add(transaction);
      logger.i('Added transaction: $transaction');
      notifyListeners();
    } catch (error) {
      logger.e('Failed to add transaction: $error');
    }
  }

  // Retrieve all transactions
  Future<List<Transaction>> fetchTransactions() async {
    try {
      logger.i('Fetching transactions from database.');
      _transactions.clear(); // Clear existing list before fetching
      _transactions.addAll(await _databaseService.getTransactions());
      logger.i('Fetched ${_transactions.length} transactions.');
      notifyListeners();
    } catch (error) {
      logger.e('Error fetching transactions: $error');
      rethrow;
    }
    return _transactions;
  }

  // Delete a transaction
  Future<void> deleteTransaction(String id) async {
    try {
      final Transaction? transactionToDelete = _transactions.firstWhereOrNull(
        (txn) => txn.id == id,
      );
      if (transactionToDelete == null) {
        logger.w('Transaction with id $id not found.');
        return;
      }
      _transactions.remove(transactionToDelete);
      await _databaseService.deleteTransaction(id);
      logger.i('Deleted transaction: $transactionToDelete');
      notifyListeners();
    } catch (error) {
      logger.e('Error deleting transaction: $error');
      rethrow;
    }
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (previousValue, element) => previousValue + element.amount);
  }
}
