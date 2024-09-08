import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/services/database_service.dart';
import 'package:money_tracker/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database service
  final databaseService = DatabaseService();

  runApp(MyApp(databaseService: databaseService));
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
