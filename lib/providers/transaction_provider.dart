import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/utils/custom_exceptions.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  final DatabaseService _databaseService;
  final Logger logger = Logger();

  TransactionProvider({required DatabaseService databaseService})
      : _databaseService = databaseService;

  List<Transaction> get transactions =>
      List.unmodifiable(_transactions); // Prevent external modification

  void _showSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _logError(String message, dynamic error) {
    logger.e('$message: $error');
  }

  void _handleError(BuildContext context, String logMessage, dynamic error,
      String userMessage) {
    _logError(logMessage, error);
    if (context.mounted) {
      _showSnackBar(context, userMessage);
    }
  }

  // Add a new transaction with user feedback
  Future<void> addTransaction(
      Transaction transaction, BuildContext context) async {
    try {
      await _databaseService.insertTransaction(transaction);
      _transactions.add(transaction);
      logger.i('Added transaction: $transaction');
      if (context.mounted) {
        notifyListeners();
        _showSnackBar(context, 'Transaction added successfully!');
      }
    } on DatabaseException catch (e) {
      if (context.mounted) {
        _handleError(context, 'Failed to add transaction', e, e.message);
      }
    } catch (error) {
      _logError('Unexpected error adding transaction', error);
      if (context.mounted) {
        _showSnackBar(context, 'Unexpected error adding transaction.');
      }
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
    } on DatabaseException catch (e) {
      _logError('Error fetching transactions', e);
      rethrow;
    } catch (error) {
      _logError('Unexpected error fetching transactions', error);
      rethrow;
    }
    return _transactions;
  }

  // Delete a transaction with user feedback
  Future<void> deleteTransaction(String id, BuildContext context) async {
    try {
      final Transaction? transactionToDelete = _transactions.firstWhereOrNull(
        (txn) => txn.id == id,
      );
      if (transactionToDelete == null) {
        logger.w('Transaction with id $id not found.');
        _showSnackBar(context, 'Transaction not found.');
        return;
      }
      _transactions.remove(transactionToDelete);
      await _databaseService.deleteTransaction(id);
      logger.i('Deleted transaction: $transactionToDelete');
      if (context.mounted) {
        notifyListeners();
        _showSnackBar(context, 'Transaction deleted successfully!');
      }
    } on TransactionNotFoundException catch (e) {
      _logError(e.message, e);
      if (context.mounted) {
        _showSnackBar(context, e.message);
      }
    } on DatabaseException catch (e) {
      _logError('Error deleting transaction', e);
      if (context.mounted) {
        _showSnackBar(context, e.message);
      }
    } catch (error) {
      _logError('Unexpected error deleting transaction', error);
      if (context.mounted) {
        _showSnackBar(context, 'Unexpected error deleting transaction.');
      }
      rethrow;
    }
  }

  // Update an existing transaction
  Future<void> updateTransaction(
      Transaction updatedTransaction, BuildContext context) async {
    try {
      final int index =
          _transactions.indexWhere((txn) => txn.id == updatedTransaction.id);
      if (index == -1) {
        throw TransactionNotFoundException(
            'Transaction with id ${updatedTransaction.id} not found.');
      }
      _transactions[index] = updatedTransaction;
      await _databaseService.updateTransaction(updatedTransaction);
      logger.i('Updated transaction: $updatedTransaction');
      if (context.mounted) {
        notifyListeners();
        _showSnackBar(context, 'Transaction updated successfully!');
      }
    } on TransactionNotFoundException catch (e) {
      _logError(e.message, e);
      if (context.mounted) {
        _showSnackBar(context, e.message);
      }
    } on DatabaseException catch (e) {
      _logError('Error updating transaction', e);
      if (context.mounted) {
        _showSnackBar(context, e.message);
      }
    } catch (error) {
      _logError('Unexpected error updating transaction', error);
      if (context.mounted) {
        _showSnackBar(context, 'Unexpected error updating transaction.');
      }
      rethrow;
    }
  }

  double get totalExpenses {
    return _transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (previousValue, element) => previousValue + element.amount);
  }
}
