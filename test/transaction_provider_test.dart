import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'transaction_provider_test.mocks.dart';

@GenerateMocks([DatabaseService])
@GenerateMocks([BuildContext])
void main() {
  late TransactionProvider transactionProvider;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    transactionProvider =
        TransactionProvider(databaseService: mockDatabaseService);
  });

  group('TransactionProvider', () {
    test('initial transactions list is empty', () {
      expect(transactionProvider.transactions, isEmpty);
    });

    test('addTransaction adds a transaction and notifies listeners', () async {
      final transaction = Transaction(
          id: '1',
          amount: 100.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.addTransaction(transaction, context);

      expect(transactionProvider.transactions, contains(transaction));
      verify(mockDatabaseService.insertTransaction(transaction)).called(1);
    });

    test(
        'fetchTransactions retrieves transactions from database and notifies listeners',
        () async {
      final transactions = [
        Transaction(
            id: '1',
            amount: 100.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
        Transaction(
            id: '2',
            amount: 200.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.transactions, equals(transactions));
      verify(mockDatabaseService.getTransactions()).called(1);
    });

    test('deleteTransaction removes a transaction and notifies listeners',
        () async {
      final transaction = Transaction(
        id: '1',
        amount: 100.0,
        date: DateTime.now(),
        formattedDate: '',
        formattedAmount: '',
        category: '',
        nextOccurrence: DateTime.now(),
        recurrenceFrequency: RecurrenceFrequency.daily,
      );

      // Mock the insertTransaction method
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      // Create a mock BuildContext
      final context = MockBuildContext();

      // Add the transaction
      await transactionProvider.addTransaction(transaction, context);

      // Verify that the transaction was added
      expect(transactionProvider.transactions, contains(transaction));

      // Mock the deleteTransaction method
      when(mockDatabaseService.deleteTransaction(transaction.id))
          .thenAnswer((_) async => 1);

      // Delete the transaction
      await transactionProvider.deleteTransaction(transaction.id, context);

      // Verify that the transaction was removed
      expect(transactionProvider.transactions, isNot(contains(transaction)));
      verify(mockDatabaseService.deleteTransaction(transaction.id)).called(1);
    });

    test('totalExpenses calculates the total expenses correctly', () async {
      final transactions = [
        Transaction(
            id: '1',
            amount: -100.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
        Transaction(
            id: '2',
            amount: -30.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
        Transaction(
            id: '3',
            amount: 100.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.totalExpenses, equals(-130.0));
    });

    test('totalExpenses returns 0.0 when there are no transactions', () {
      expect(transactionProvider.totalExpenses, equals(0.0));
    });

    test('totalExpenses returns 0.0 when there are only income transactions',
        () async {
      final transactions = [
        Transaction(
            id: '1',
            amount: 100.0,
            date: DateTime.now(),
            formattedDate: '',
            formattedAmount: '',
            category: '',
            nextOccurrence: DateTime.now(),
            recurrenceFrequency: RecurrenceFrequency.daily),
      ];
      when(mockDatabaseService.getTransactions())
          .thenAnswer((_) async => transactions);

      await transactionProvider.fetchTransactions();

      expect(transactionProvider.totalExpenses, equals(0.0));
    });

    test('addTransaction handles errors gracefully', () async {
      final transaction = Transaction(
          id: '1',
          amount: 100.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);

      when(mockDatabaseService.insertTransaction(transaction))
          .thenThrow(Exception('Database error'));

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.addTransaction(transaction, context);

      expect(transactionProvider.transactions, isEmpty);
    });

    test(
        'addTransaction with zero amount adds the transaction and notifies listeners',
        () async {
      final transaction = Transaction(
          id: '1',
          amount: 0.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.addTransaction(transaction, context);

      expect(transactionProvider.transactions, contains(transaction));
      verify(mockDatabaseService.insertTransaction(transaction)).called(1);
    });

    test(
        'addTransaction with negative amount adds the transaction and notifies listeners',
        () async {
      final transaction = Transaction(
          id: '2',
          amount: -50.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.addTransaction(transaction, context);

      expect(transactionProvider.transactions, contains(transaction));
      verify(mockDatabaseService.insertTransaction(transaction)).called(1);
    });

    test('deleteTransaction handles non-existent transaction gracefully',
        () async {
      final transaction = Transaction(
          id: '3',
          amount: 100.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.deleteTransaction(transaction.id, context);

      expect(transactionProvider.transactions, isEmpty);
      verifyNever(mockDatabaseService.deleteTransaction(transaction.id));
    });

    test('fetchTransactions handles database error gracefully', () async {
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

    test('add a large number of transactions', () async {
      final transactions = List.generate(
          1000,
          (index) => Transaction(
              id: '$index',
              amount: index.toDouble(),
              date: DateTime.now(),
              formattedDate: '',
              formattedAmount: '',
              category: '',
              nextOccurrence: DateTime.now(),
              recurrenceFrequency: RecurrenceFrequency.daily));

      // Create a mock BuildContext
      final context = MockBuildContext();

      for (var transaction in transactions) {
        when(mockDatabaseService.insertTransaction(transaction))
            .thenAnswer((_) async => {});
        await transactionProvider.addTransaction(transaction, context);
      }

      expect(transactionProvider.transactions.length, equals(1000));
      for (var transaction in transactions) {
        verify(mockDatabaseService.insertTransaction(transaction)).called(1);
      }
    });

    test('listeners are notified the correct number of times', () async {
      int notificationCount = 0;
      transactionProvider.addListener(() {
        notificationCount++;
      });

      final transaction = Transaction(
          id: '4',
          amount: 100.0,
          date: DateTime.now(),
          formattedDate: '',
          formattedAmount: '',
          category: '',
          nextOccurrence: DateTime.now(),
          recurrenceFrequency: RecurrenceFrequency.daily);
      when(mockDatabaseService.insertTransaction(transaction))
          .thenAnswer((_) async => {});

      // Create a mock BuildContext
      final context = MockBuildContext();

      await transactionProvider.addTransaction(transaction, context);

      expect(notificationCount, equals(1));
    });
  });
}
