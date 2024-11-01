import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/screens/add_transaction_screen.dart';
import 'package:money_tracker/widgets/side_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  final GlobalKey<SideNavigationState> _sideNavKey =
      GlobalKey<SideNavigationState>();
  final int _selectedIndex = 0; // Home index

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  /// Fetches transactions from the provider.
  Future<void> _fetchTransactions() async {
    try {
      await Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
    } catch (error) {
      logger.e('Error initializing transactions: $error');
      // Optionally, send the error to a monitoring service
      // sendErrorToMonitoringService(error);
    }
  }

  /// Shows a snackbar with the given message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SideNavigation(
      key: _sideNavKey,
      selectedIndex: _selectedIndex,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _sideNavKey.currentState?.toggleDrawer();
            },
          ),
          title: Text(
            'CASHFLOW',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka',
              fontSize: 24,
              fontVariations: const <FontVariation>[FontVariation('wght', 700)],
              shadows: const <Shadow>[
                Shadow(
                  offset: Offset(-2.0, 2.0),
                  blurRadius: 4.0,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAD73), Color(0xFFAABD36)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _buildContent(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4CAF50),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the main content of the HomeScreen.
  Widget _buildContent() {
    return Consumer<TransactionProvider>(
      builder: (ctx, transactionProvider, child) {
        if (transactionProvider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No transactions available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total Expenses: ₱${transactionProvider.totalExpenses.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: transactionProvider.transactions.length,
                  itemBuilder: (ctx, index) {
                    final transaction = transactionProvider.transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal[100],
                          child: Icon(
                            Icons.attach_money,
                            color: Colors.teal[600],
                          ),
                        ),
                        title: Text(
                          transaction.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '${transaction.formattedAmount} - ${transaction.formattedDate}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
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
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Deletes a transaction.
  void _deleteTransaction(BuildContext context, String transactionId) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    transactionProvider
        .deleteTransaction(transactionId, _showSnackBar)
        .catchError((error) {
      logger.e('Error deleting transaction: $error');
      // Optionally, send the error to a monitoring service
      // sendErrorToMonitoringService(error);
      if (mounted) {
        _showSnackBar('Error deleting transaction: $error');
      }
    });
  }
}
