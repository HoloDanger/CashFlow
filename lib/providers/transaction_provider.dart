import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/utils/custom_exceptions.dart';

/// A provider class that manages transactions and notifies listeners of changes.
class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final Map<String, Transaction> _transactionMap = {};
  final DatabaseService _databaseService;
  final Logger logger = Logger();

  /// Constructs a [TransactionProvider] with the given [DatabaseService].
  TransactionProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  /// Returns an unmodifiable list of transactions to prevent external modification.
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Shows a snackbar with the given [message].
  void _showSnackBar(Function(String) showSnackBarCallback, String message) {
    showSnackBarCallback(message);
  }

  /// Logs the error with the given [message] and [error].
  void _logError(String message, dynamic error) {
    logger.e('$message: $error');
  }

  /// Handles errors by logging them and showing a snackbar with a user-friendly message.
  void _handleError(Function(String) showSnackBarCallback, String logMessage,
      dynamic error, String userMessage) {
    _logError(logMessage, error);
    _showSnackBar(showSnackBarCallback, userMessage);
  }

  /// Performs a transaction operation and handles success and error cases.
  Future<void> _performTransactionOperation(
      Future<void> Function() operation,
      Function(String) showSnackBarCallback,
      String successMessage,
      String logMessage) async {
    try {
      await operation();
      _notifyAndShowSnackBar(showSnackBarCallback, successMessage);
    } on DatabaseException catch (e) {
      _handleError(
          showSnackBarCallback, '$logMessage: Database error', e, e.message);
    } catch (error) {
      _handleError(showSnackBarCallback, '$logMessage: Unexpected error', error,
          'Unexpected error occurred.');
    }
  }

  /// Adds a new transaction and provides user feedback.
  Future<void> addTransaction(
      Transaction transaction, Function(String) showSnackBarCallback) async {
    await _performTransactionOperation(
      () async {
        await _databaseService.insertTransaction(transaction);
        _transactions.add(transaction);
        _transactionMap[transaction.id] = transaction;
        logger.i('Added transaction: $transaction');
      },
      showSnackBarCallback,
      'Transaction added successfully!',
      'Failed to add transaction',
    );
  }

  /// Fetches all transactions from the database.
  Future<List<Transaction>> fetchTransactions() async {
    try {
      logger.i('Fetching transactions from database.');
      final fetchedTransactions = await _databaseService.getTransactions();
      _transactions
        ..clear()
        ..addAll(fetchedTransactions);
      logger.i('Fetched ${_transactions.length} transactions.');
      notifyListeners();
    } on DatabaseException catch (e) {
      _logError('Error fetching transactions', e);
      rethrow;
    } catch (error) {
      _logError('Unexpected error fetching transactions', error);
      rethrow;
    }
    return _transactions;
  }

  /// Deletes a transaction with the given [id] and provides user feedback.
  Future<void> deleteTransaction(
      String id, Function(String) showSnackBarCallback) async {
    await _performTransactionOperation(
      () async {
        final transactionToDelete = _transactionMap[id];
        if (transactionToDelete == null) {
          logger.w('Transaction with id $id not found.');
          _showSnackBar(showSnackBarCallback, 'Transaction not found.');
          return;
        }
        _transactions.remove(transactionToDelete);
        _transactionMap.remove(id);
        await _databaseService.deleteTransaction(id);
        logger.i('Deleted transaction: $transactionToDelete');
      },
      showSnackBarCallback,
      'Transaction deleted successfully!',
      'Error deleting transaction',
    );
  }

  /// Updates an existing transaction and provides user feedback.
  Future<void> updateTransaction(Transaction updatedTransaction,
      Function(String) showSnackBarCallback) async {
    await _performTransactionOperation(
      () async {
        final index =
            _transactions.indexWhere((txn) => txn.id == updatedTransaction.id);
        if (index == -1) {
          throw TransactionNotFoundException(
              'Transaction with id ${updatedTransaction.id} not found.');
        }
        _transactions[index] = updatedTransaction;
        _transactionMap[updatedTransaction.id] = updatedTransaction;
        await _databaseService.updateTransaction(updatedTransaction);
        logger.i('Updated transaction: $updatedTransaction');
      },
      showSnackBarCallback,
      'Transaction updated successfully!',
      'Error updating transaction',
    );
  }

  /// Calculates the total expenses from all transactions.
  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (previousValue, element) => previousValue + element.amount);
  }

  /// Notifies listeners and shows a snackbar with the given [message].
  void _notifyAndShowSnackBar(
      Function(String) showSnackBarCallback, String message) {
    notifyListeners();
    showSnackBarCallback(message);
  }
}
