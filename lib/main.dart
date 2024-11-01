import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/providers/budget_provider.dart';
import 'package:money_tracker/providers/category_provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/screens/budget_overview_screen.dart';
import 'package:money_tracker/screens/home_screen.dart';
import 'package:money_tracker/screens/settings_screen.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/services/recurring_transaction_service.dart';
import 'package:provider/provider.dart';

void main() {
  // Making zone errors fatal can help in debugging
  BindingBase.debugZoneErrorsAreFatal = true;

  final Logger logger = Logger();

  // Run the app initialization in a guarded zone
  runZonedGuarded(() async {
    // Ensure Flutter binding is initialized in this zone
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize services or perform async operations here
    final databaseService = DatabaseService();

    // Set up a custom error handler for Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e(
        'Flutter error: ${details.exceptionAsString()}\n${details.stack}',
      );
      // Optionally, send the error to a monitoring service
      // sendErrorToMonitoringService(details.exception, details.stack);
    };

    // Fetch existing transactions from the database
    List<Transaction> transactions = await databaseService.getTransactions();

    // Run the app
    runApp(MyApp(
      databaseService: databaseService,
      initialTransactions: transactions,
    ));
  }, (error, stackTrace) {
    logger.e('Uncaught asynchronous error: $error\n$stackTrace');
    // Optionally, send the error to a monitoring service
    // sendErrorToMonitoringService(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  final List<Transaction> initialTransactions;

  const MyApp({
    super.key,
    required this.databaseService,
    required this.initialTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide DatabaseService first
        Provider<DatabaseService>.value(value: databaseService),

        // Other ChangeNotifierProviders
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) =>
              TransactionProvider(databaseService: databaseService),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<BudgetProvider>(
          create: (_) => BudgetProvider(),
        ),

        // ProxyProvider2 for RecurringTransactionService
        ProxyProvider2<TransactionProvider, DatabaseService,
            RecurringTransactionService>(
          update: (_, transactionProvider, dbService, __) =>
              RecurringTransactionService(
            transactionProvider: transactionProvider,
            databaseService: dbService,
          )..scheduleRecurringTransactions(
                  transactionProvider.transactions
                      .where((t) => t.isRecurring)
                      .toList(),
                ),
        ),
      ],
      child: MaterialApp(
        title: 'CashFlow - Money Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
          hintColor: Colors.amber,
          textTheme: TextTheme(
            displayLarge:
                TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontSize: 14.0),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.green,
            textTheme: ButtonTextTheme.primary,
          ),
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/budget': (context) => const BudgetOverviewScreen(),
          '/settings': (context) => const SettingsScreen(),
          // Add other routes here if needed
        },
      ),
    );
  }
}