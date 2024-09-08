import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CashFlow')),
      body: FutureBuilder(
        future: Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions(),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator())
            : Consumer<TransactionProvider>(
                builder: (ctx, transactionProvider, child) => ListView.builder(
                  itemCount: transactionProvider.transactions.length,
                  itemBuilder: (ctx, index) {
                    final transaction = transactionProvider.transactions[index];
                    return ListTile(
                      title: Text(transaction.category),
                      subtitle:
                          Text('${transaction.amount} - ${transaction.date}'),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
      ),
    );
  }
}
