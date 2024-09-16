import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:money_tracker/providers/category_provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/screens/home_screen.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:provider/provider.dart';

void main() {
  // Making zone errors fatal can help in debugging
  BindingBase.debugZoneErrorsAreFatal = true;

  // Capture the current zone
  final Zone currentZone = Zone.current;

  final Logger logger = Logger();
  // Run the app initialization in the current zone
  currentZone.run(() async {
    // Ensure Flutter binding is initialized in this zone
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize services or perform async operations here
    final databaseService = DatabaseService();

    FlutterError.onError = (FlutterErrorDetails details) {
      logger.e('Flutter error: ${details.exception}');
      // Optionally, send the error to a monitoring service
    };
    // Run the app
    runApp(MyApp(databaseService: databaseService));
  });
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MyApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(databaseService: databaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        )
      ],
      child: MaterialApp(
        title: 'CashFlow - Money Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
