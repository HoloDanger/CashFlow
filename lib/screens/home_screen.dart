import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashFlow'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: Provider.of<TransactionProvider>(context, listen: false)
              .fetchTransactions(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('An error occurred: ${snapshot.error}'));
            } else {
              return Consumer<TransactionProvider>(
                builder: (ctx, transactionProvider, child) {
                  if (transactionProvider.transactions.isEmpty) {
                    return const Center(
                      child: Text('No transactions available.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: transactionProvider.transactions.length,
                    itemBuilder: (ctx, index) {
                      final transaction =
                          transactionProvider.transactions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5,
                        child: ListTile(
                          title: Text(
                            transaction.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${transaction.amount} - ${transaction.date}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              _deleteTransaction(context, transaction.id);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
    );
  }

  void _deleteTransaction(BuildContext context, String transactionId) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    transactionProvider.deleteTransaction(transactionId);
  }
}
