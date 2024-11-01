import 'dart:async';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/recurrence_frequency.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:uuid/uuid.dart';

class RecurringTransactionService {
  final TransactionProvider transactionProvider;
  final DatabaseService databaseService;
  final Logger logger = Logger();
  final List<Timer> _timers = [];

  RecurringTransactionService({
    required this.transactionProvider,
    required this.databaseService,
  });

  /// Schedules recurring transactions based on existing transactions.
  void scheduleRecurringTransactions(List<Transaction> transactions) {
    for (var transaction in transactions) {
      if (transaction.isRecurring && transaction.recurrenceFrequency != null) {
        _scheduleTransaction(transaction);
      }
    }
  }

  /// Schedules a single recurring transaction.
  void scheduleRecurringTransaction(Transaction transaction) {
    if (!transaction.isRecurring || transaction.recurrenceFrequency == null) {
      return;
    }

    _scheduleTransaction(transaction);
    logger.i('Scheduled new recurring transaction with ID: ${transaction.id}');
  }

  void _scheduleTransaction(Transaction transaction) {
    Duration interval;
    switch (transaction.recurrenceFrequency!) {
      case RecurrenceFrequency.daily:
        interval = const Duration(days: 1);
        break;
      case RecurrenceFrequency.weekly:
        interval = const Duration(days: 7);
        break;
      case RecurrenceFrequency.monthly:
        // Approximation for monthly interval
        interval = const Duration(days: 30);
        break;
      default:
        logger.w(
            'Unknown recurrence frequency for transaction ID: ${transaction.id}');
        return;
    }

    try {
      Timer timer = Timer.periodic(interval, (timer) {
        logger.i(
            'Creating recurring transaction for category: ${transaction.category}');
        createTransaction(transaction);
      });
      _timers.add(timer);
    } catch (e) {
      logger.e('Error scheduling transaction: $e');
    }
  }

  void createTransaction(Transaction originalTransaction) {
    if (originalTransaction.recurrenceFrequency == null) {
      throw ArgumentError(
          'Recurrence frequency cannot be null for recurring transactions');
    }

    final newTransaction = Transaction(
      id: const Uuid().v4(),
      amount: originalTransaction.amount,
      formattedAmount: originalTransaction.formattedAmount,
      category: originalTransaction.category,
      date: DateTime.now(),
      formattedDate: '${DateTime.now()}'.split(' ')[0],
      isRecurring: originalTransaction.isRecurring,
      recurrenceFrequency: originalTransaction.recurrenceFrequency!,
      nextOccurrence: calculateNextOccurrence(
          DateTime.now(), originalTransaction.recurrenceFrequency!),
    );

    try {
      transactionProvider.addTransaction(newTransaction, (message) {
        logger.i('Recurring Transaction Added: $message');
      });
    } catch (e) {
      logger.e('Error inserting recurring transaction: $e');
    }
  }

  DateTime calculateNextOccurrence(
      DateTime date, RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        final int year = date.month == 12 ? date.year + 1 : date.year;
        final int month = date.month == 12 ? 1 : date.month + 1;
        final int day =
            date.day > 28 ? 28 : date.day; // To handle shorter months
        return DateTime(year, month, day);
      default:
        return date;
    }
  }

  /// Call this method to dispose all timers when they are no longer needed.
  void disposeTimers() {
    for (var timer in _timers) {
      timer.cancel();
    }
  }
}
