import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/utils/custom_exceptions.dart';

/// A provider class that manages transactions and notifies listeners of changes.
///
/// This class is responsible for performing CRUD operations on transactions,
/// handling errors, logging important events, and notify listeners of changes.
class TransactionProvider with ChangeNotifier {
  /// A list of transactions for easy iteration and display.
  final List<Transaction> _transactions = [];

  /// A map of transactions for quick lookup by ID.
  final Map<String, Transaction> _transactionMap = {};

  final DatabaseService _databaseService;
  final Logger _logger = Logger();

  /// Constructs a [TransactionProvider] with the given [DatabaseService].
  ///
  /// The [databaseService] parameter is required to perform database operations.
  TransactionProvider({
    required DatabaseService databaseService,
  }) : _databaseService = databaseService;

  /// Returns an unmodifiable list of transactions to prevent external modification.
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Shows a snackbar with the given [message].
  ///
  /// The [showSnackBarCallback] is a function that displays the snackbar,
  /// and [message] is the text to be displayed in the snackbar.
  void _showSnackBar(Function(String) showSnackBarCallback, String message) {
    showSnackBarCallback(message);
  }

  /// Logs the error with the given [message] and [error].
  ///
  /// The [message] parameter is a description of the error,
  /// and [error] is the error object.
  void logError(String message, Object error) {
    _logger.e('$message: $error');
  }

  /// Handles errors by logging them and showing a snackbar with a user-friendly message.
  ///
  /// The [showSnackBarCallback] is a function that displays the snackbar,
  /// [logMessage] is a description of the error for logging purposes,
  /// [error] is the error object, and [userMessage] is the message to be displayed in the snackbar.
  void handleTransactionError(Function(String) showSnackBarCallback,
      String logMessage, Object error, String userMessage) {
    logError(logMessage, error);
    _showSnackBar(showSnackBarCallback, userMessage);
  }

  /// Performs a transaction operation and handles success and error cases.
  ///
  /// The [operation] parameter is a function that performs the transaction operation,
  /// [showSnackBarCallback] is a function that displays the snackbar,
  /// [successMessage] is the message to be displayed on success,
  /// and [logMessage] is a description of the operation for logging purposes.
  ///
  /// This method abstracts the common logic for performing a transaction operation,
  /// handling errors, and notifying listeners. It ensures that the operation is
  /// executed, and appropriate feedback is provided to the user.
  Future<void> performTransactionOperation(
    Future<void> Function() operation,
    Function(String) showSnackBarCallback,
    String successMessage,
    String logMessage,
  ) async {
    try {
      await _executeOperation(operation, showSnackBarCallback, successMessage);
    } catch (error) {
      handleTransactionError(
          showSnackBarCallback,
          '$logMessage: ${error.runtimeType}',
          error,
          'Unexpected error occurred.');
    }
  }

  Future<void> _executeOperation(
    Future<void> Function() operation,
    Function(String) showSnackBarCallback,
    String successMessage,
  ) async {
    await operation();
    _notifyAndShowSnackBar(showSnackBarCallback, successMessage);
    _synchronizeCollections();
  }

  /// Adds a new transaction and provides user feedback.
  ///
  /// The [transaction] parameter is the transaction to be added,
  /// and [showSnackBarCallback] is a function that displays the snackbar.
  ///
  /// This method uses [performTransactionOperation] to handle the addition of a new transaction,
  /// ensuring that the transaction is added to the database and the local list,
  /// and appropriate feedback is provided to the user.
  Future<void> addTransaction(
      Transaction transaction, Function(String) showSnackBarCallback) async {
    await performTransactionOperation(
      () async {
        await _databaseService.insertTransaction(transaction);
        _transactions.add(transaction);
        _transactionMap[transaction.id] = transaction;
        _logger
            .i('addTransaction: Added transaction with ID ${transaction.id}');
      },
      showSnackBarCallback,
      'Transaction added successfully!',
      'Failed to add transaction',
    );
  }

  /// Fetches all transactions from the database.
  ///
  /// Returns a list of transactions fetched from the database.
  /// Throws a [DatabaseException] if there is an error fetching transactions.
  ///
  /// This method retrieves all transactions from the database, updates the local list,
  /// and notifies listeners of the changes. It handles any errors that occur during
  /// the fetching process.
  Future<List<Transaction>> fetchTransactions() async {
    try {
      _logger.i('Fetching transactions from database.');
      final fetchedTransactions = await _databaseService
          .getTransactions()
          .timeout(const Duration(seconds: 3));
      _transactions
        ..clear()
        ..addAll(fetchedTransactions);
      _synchronizeCollections();
      _logger.i(
          'fetchTransactions: Fetched ${_transactions.length} transactions.');
      notifyListeners();
    } on TimeoutException catch (e) {
      logError('fetchTransactions: Timeout fetching transactions', e);
      rethrow;
    } on DatabaseException catch (e) {
      logError('fetchTransactions: Error fetching transactions', e);
      rethrow;
    } catch (error) {
      logError(
          'fetchTransactions:Unexpected error fetching transactions', error);
      rethrow;
    }
    return _transactions;
  }

  /// Deletes a transaction with the given [id] and provides user feedback.
  ///
  /// The [id] parameter is the ID of the transaction to be deleted,
  /// and [showSnackBarCallback] is a function that displays the snackbar.
  ///
  /// This method uses [performTransactionOperation] to handle the deletion of a transaction,
  /// ensuring that the transaction is removed from the database and the local list,
  /// and appropriate feedback is provided to the user.
  Future<void> deleteTransaction(
      String id, Function(String) showSnackBarCallback) async {
    await performTransactionOperation(
      () async {
        final transactionToDelete = _transactionMap[id];
        if (transactionToDelete == null) {
          _logger.w('deleteTransaction: Transaction with id $id not found.');
          notifyListeners();
          showSnackBarCallback('Transaction not found.');
          return;
        }
        _transactions.remove(transactionToDelete);
        await _databaseService.deleteTransaction(id);
        _logger.i('deleteTransaction: Deleted transaction with ID $id');
      },
      showSnackBarCallback,
      'Transaction deleted successfully!',
      'Error deleting transaction',
    );
  }

  /// Updates an existing transaction and provides user feedback.
  ///
  /// The [updatedTransaction] parameter is the transaction to be updated,
  /// and [showSnackBarCallback] is a function that displays the snackbar.
  ///
  /// This method uses [performTransactionOperation] to handle the update of a transaction,
  /// ensuring that the transaction is updated in the database and the local list,
  /// and appropriate feedback is provided to the user.
  Future<void> updateTransaction(Transaction updatedTransaction,
      Function(String) showSnackBarCallback) async {
    await performTransactionOperation(
      () async {
        final index =
            _transactions.indexWhere((txn) => txn.id == updatedTransaction.id);
        if (index == -1) {
          throw TransactionNotFoundException(
              'Transaction with id ${updatedTransaction.id} not found.');
        }
        _transactions[index] = updatedTransaction;
        notifyListeners();
        await _databaseService.updateTransaction(updatedTransaction);
        _logger.i(
            'updateTransaction: Updated transaction with ID ${updatedTransaction.id}');
      },
      showSnackBarCallback,
      'Transaction updated successfully!',
      'Error updating transaction',
    );
  }

  /// Calculates the total expenses from all transactions.
  ///
  /// Returns the total expenses as a double.
  ///
  /// This method calculates the total expenses by summing up the amounts of all
  /// transactions that have a negative amount.
  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (previousValue, element) => previousValue + element.amount);
  }

  /// Calculates the total income from all transactions.
  ///
  /// Returns the total income as a double.
  ///
  /// This method calculates the total income by summing up the amounts of all
  /// transactions that have a positive amount.
  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.amount > 0)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Calculates the current balance from all transactions.
  ///
  /// Returns the current balance as a double.
  ///
  /// This method calculates the current balance by summing up the amounts of all
  /// transactions.
  double get currentBalance {
    return _transactions.fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Calculates the expenses for the given period.
  ///
  /// Returns the expenses for the given period as a double.
  ///
  /// This method calculates the expenses by summing up the amounts of all
  /// transactions that have a negative amount and occur within the given period.
  double getExpensesForPeriod(DateTime start, DateTime end) {
    return _transactions
        .where((tx) => tx.date.isAfter(start) && tx.date.isBefore(end))
        .where((tx) => tx.amount < 0)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  /// Notifies listeners and shows a snackbar with the given [message].
  ///
  /// The [showSnackBarCallback] is a function that displays the snackbar,
  /// and [message] is the text to be displayed in the snackbar.
  ///
  void _notifyAndShowSnackBar(
      Function(String) showSnackBarCallback, String message) {
    notifyListeners();
    showSnackBarCallback(message);
  }

  /// Synchronizes the transaction map with the current list of transactions.
  ///
  /// This method clears the existing transaction map and repopulates it
  /// with the current transactions from the list, ensuring that the map
  /// is always up-to-date with the latest transactions.
  void _synchronizeCollections() {
    _transactionMap
      ..clear()
      ..addEntries(_transactions
          .map((transaction) => MapEntry(transaction.id, transaction)));
  }
}
