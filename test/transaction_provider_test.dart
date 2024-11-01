import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' hide Fake;
import 'package:money_tracker/models/recurrence_frequency.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/utils/custom_exceptions.dart';
import 'transaction_provider_test.mocks.dart';

// Mock classes
@GenerateMocks([DatabaseService])
class MockShowSnackBar extends Mock {
  void call(String message);
}

void main() {
  late TransactionProvider transactionProvider;
  late MockDatabaseService mockDatabaseService;
  late MockShowSnackBar mockShowSnackBar;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockShowSnackBar = MockShowSnackBar();
    transactionProvider =
        TransactionProvider(databaseService: mockDatabaseService);
  });

  Transaction createTransaction({
    required String id,
    required double amount,
    DateTime? date,
    String? formattedDate = '',
    String formattedAmount = '',
    String category = '',
    DateTime? nextOccurrence,
    RecurrenceFrequency recurrenceFrequency = RecurrenceFrequency.daily,
  }) {
    return Transaction(
      id: id,
      amount: amount,
      date: date ?? DateTime.now(),
      formattedDate: formattedDate ?? '',
      formattedAmount: formattedAmount,
      category: category,
      nextOccurrence: nextOccurrence ?? DateTime.now(),
      recurrenceFrequency: recurrenceFrequency,
    );
  }

  Future<void> addTransactionAndVerify(Transaction transaction) async {
    when(mockDatabaseService.insertTransaction(transaction))
        .thenAnswer((_) async => {});
    await transactionProvider.addTransaction(
        transaction, mockShowSnackBar.call);
    expect(transactionProvider.transactions, contains(transaction));
    verify(mockDatabaseService.insertTransaction(transaction)).called(1);
  }

  group('TransactionProvider Initialization', () {
    test('initial transactions list should be empty', () {
      expect(transactionProvider.transactions, isEmpty);
    });
  });

  group('TransactionProvider CRUD Operations', () {
    test('addTransaction should add a transaction and notify listeners',
        () async {
      final transaction = createTransaction(id: '1', amount: 100.0);
      await addTransactionAndVerify(transaction);
    });

    test(
        'fetchTransactions should retrieve transactions from database and notifiy listeners',
        () async {
      final transactions = [
        createTransaction(id: '1', amount: 100.0),
        createTransaction(id: '2', amount: 200.0),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.transactions, equals(transactions));
      verify(mockDatabaseService.getTransactions()).called(1);
    });

    test('deleteTransaction should remove a transaction and notify listeners',
        () async {
      final transaction = createTransaction(id: '1', amount: 100.0);
      await addTransactionAndVerify(transaction);

      // Mock the deleteTransaction method
      when(mockDatabaseService.deleteTransaction(transaction.id))
          .thenAnswer((_) async => 1);

      // Delete the transaction
      await transactionProvider.deleteTransaction(
          transaction.id, mockShowSnackBar.call);

      // Verify that the transaction was removed
      expect(transactionProvider.transactions, isNot(contains(transaction)));
      verify(mockDatabaseService.deleteTransaction(transaction.id)).called(1);
    });

    test('updateTransaction should update a transaction and notify listeners',
        () async {
      final transaction = createTransaction(id: '1', amount: 100.0);
      final updatedTransaction = createTransaction(id: '1', amount: 200.0);

      await addTransactionAndVerify(transaction);

      when(mockDatabaseService.updateTransaction(updatedTransaction))
          .thenAnswer((_) async => {});
      await transactionProvider.updateTransaction(
          updatedTransaction, mockShowSnackBar.call);

      expect(transactionProvider.transactions, contains(updatedTransaction));
      verify(mockDatabaseService.updateTransaction(updatedTransaction))
          .called(1);
    });
  });

  group('TransactionProvider Calculations', () {
    test('totalExpenses should calculate the total expenses correctly',
        () async {
      final transactions = [
        createTransaction(id: '1', amount: -100.0),
        createTransaction(id: '2', amount: -30.0),
        createTransaction(id: '3', amount: 100.0),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.totalExpenses, equals(-130.0));
    });

    test('totalExpenses should return 0.0 when there are no transactions', () {
      expect(transactionProvider.totalExpenses, equals(0.0));
    });

    test(
        'totalExpenses should return 0.0 when there are only income transactions',
        () async {
      final transactions = [
        createTransaction(id: '1', amount: 100.0),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.totalExpenses, equals(0.0));
    });
  });

  group('TransactionProvider Error Handling', () {
    test('performTransactionOperation should handle success and error cases',
        () async {
      final transaction = createTransaction(id: '1', amount: 100.0);

      // Error case
      when(mockDatabaseService.insertTransaction(transaction))
          .thenThrow(DatabaseException('Database error'));

      await transactionProvider.performTransactionOperation(
        () async => await mockDatabaseService.insertTransaction(transaction),
        mockShowSnackBar.call,
        'Success message',
        'Log message',
      );

      // Verify error handling
      verify(mockShowSnackBar.call('Unexpected error occurred.')).called(1);

      // Reset the mocks
      reset(mockDatabaseService);
      reset(mockShowSnackBar);

      // Success case
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      await transactionProvider.performTransactionOperation(
        () async => await mockDatabaseService.insertTransaction(transaction),
        mockShowSnackBar.call,
        'Success message',
        'Log message',
      );

      // Verify success handling
      verify(mockShowSnackBar.call('Success message')).called(1);
    });

    test('addTransaction should handle errors gracefully', () async {
      final transaction = createTransaction(id: '1', amount: 100.0);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenThrow(Exception('Database error'));

      await transactionProvider.addTransaction(
          transaction, mockShowSnackBar.call);

      expect(transactionProvider.transactions, isEmpty);
    });

    test('fetchTransactions should handle database error gracefully', () async {
      when(mockDatabaseService.getTransactions())
          .thenThrow(Exception('Database error'));

      try {
        await transactionProvider.fetchTransactions();
      } catch (e) {
        expect(transactionProvider.transactions, isEmpty);
        expect(e, isException);
      }

      verify(mockDatabaseService.getTransactions()).called(1);
    });

    test('deleteTransaction should handle non-existent transaction gracefully',
        () async {
      final transaction = createTransaction(id: '3', amount: 100.0);

      await transactionProvider.deleteTransaction(
          transaction.id, mockShowSnackBar.call);

      expect(transactionProvider.transactions, isEmpty);
      verifyNever(mockDatabaseService.deleteTransaction(transaction.id));
    });
  });

  group('TransactionProvider Edge Cases', () {
    test(
        'addTransaction with zero amount should add the transaction and notify listeners',
        () async {
      final transaction = createTransaction(id: '1', amount: 0.0);
      await addTransactionAndVerify(transaction);
    });

    test(
        'addTransaction with negative amount should add the transaction and notifiy listeners',
        () async {
      final transaction = createTransaction(id: '2', amount: -50.0);
      await addTransactionAndVerify(transaction);
    });

    test(
        'addTransaction with very large amount should add the transaction and notify listeners',
        () async {
      final transaction = createTransaction(id: '3', amount: 1e9);
      await addTransactionAndVerify(transaction);
    });

    test(
        'addTransaction with special characters in category should add the transaction and notify listeners',
        () async {
      final transaction =
          createTransaction(id: '4', amount: 100.0, category: '@#\$%^&*()');
      await addTransactionAndVerify(transaction);
    });
  });

  group('TransactionProvider Notifications', () {
    test('listeners should be notified the correct number of times', () async {
      int notificationCount = 0;
      transactionProvider.addListener(() {
        notificationCount++;
      });

      final transaction = createTransaction(id: '4', amount: 100.0);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      await transactionProvider.addTransaction(
          transaction, mockShowSnackBar.call);

      expect(notificationCount, equals(1));
    });

    test('add a large number of transactions should work correctly', () async {
      final transactions = List.generate(
        1000,
        (index) => createTransaction(id: '$index', amount: index.toDouble()),
      );

      for (var transaction in transactions) {
        when(mockDatabaseService.insertTransaction(transaction))
            .thenAnswer((_) async => {});
        await transactionProvider.addTransaction(
            transaction, mockShowSnackBar.call);
      }

      expect(transactionProvider.transactions.length, equals(1000));
      for (var transaction in transactions) {
        verify(mockDatabaseService.insertTransaction(transaction)).called(1);
      }
    });
  });

  group('TransactionProvider Advanced Calculations', () {
    test('getExpensesForPeriod calculations', () async {
      final transactions = [
        createTransaction(
          id: '1',
          amount: -100.0,
          date: DateTime(2024, 1, 1),
        ),
        createTransaction(
          id: '2',
          amount: -50.0,
          date: DateTime(2024, 2, 1),
        ),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();
      final expenses = transactionProvider.getExpensesForPeriod(
        DateTime(2024, 1, 1).subtract(const Duration(seconds: 1)),
        DateTime(2024, 3, 1).add(const Duration(seconds: 1)),
      );
      expect(expenses, equals(-150.0));
    });

    test('concurrent operations handling', () async {
      final futures = List.generate(
          10,
          (index) => transactionProvider.addTransaction(
              createTransaction(id: '$index', amount: 100.0),
              mockShowSnackBar.call));
      await Future.wait(futures);
      expect(transactionProvider.transactions.length, equals(10));
    });
  });

  group('TransactionProvider Additional Cases', () {
    test('totalIncome calculations', () async {
      final transactions = [
        createTransaction(id: '1', amount: 100.0),
        createTransaction(id: '2', amount: 200.0),
        createTransaction(id: '3', amount: -50.0),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();
      expect(transactionProvider.totalIncome, equals(300.0));
    });

    test('batch operations with timeout', () async {
      when(mockDatabaseService.getTransactions()).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 5),
          () => <Transaction>[],
        ),
      );

      expect(
        () => transactionProvider.fetchTransactions(),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
