// Flutter imports
import 'package:flutter/material.dart';

// Third-party packages
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// Local imports
import 'package:money_tracker/providers/transaction_provider.dart';
import 'package:money_tracker/screens/budget_overview_screen.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final Logger logger = Logger();
  int _selectedIndex = 0; // For bottom navigation
  bool _isDrawerOpen = false;

  // Constants
  static const double drawerWidth = 80.0;
  static const double iconSize = 28.0;
  static const double navItemPadding = 16.0;

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

  /// Handles navigation item taps.
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isDrawerOpen = false;
    });
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BudgetOverviewScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  /// Shows a snackbar with the given message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              setState(() {
                _isDrawerOpen = !_isDrawerOpen;
              });
            }),
        title: Text(
          'CASHFLOW',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontVariations: <FontVariation>[FontVariation('wght', 700)],
            shadows: <Shadow>[
              Shadow(
                offset: Offset(-2.0, 2.0), // Position of the shadow
                blurRadius: 4.0, // Blur radius
                color:
                    Colors.black.withOpacity(0.3), // Shadow color and opacity
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
      body: Stack(
        children: [
          // Main Content
          _buildContent(_selectedIndex),

          // Animated Side Navigation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: _isDrawerOpen ? 0 : -drawerWidth,
            top: 0,
            bottom: 0,
            child: Container(
              width: drawerWidth,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4CAD73),
                    Color(0xFFAABD36),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildNavItem(Icons.home, 0, 'Home'),
                  _buildNavItem(Icons.money, 1, 'Budget'),
                  _buildNavItem(Icons.show_chart, 2, 'Reports'),
                  _buildNavItem(Icons.settings, 3, 'Settings'),
                ],
              ),
            ),
          ),

          // Overlay when drawer is open
          if (_isDrawerOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDrawerOpen = false;
                  });
                },
                child: Container(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4CAF50),
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

  /// Builds a navigation item.
  Widget _buildNavItem(IconData icon, int index, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: navItemPadding),
      child: IconButton(
        icon: Icon(
          icon,
          color: _selectedIndex == index ? Colors.white : Colors.white70,
          size: iconSize,
        ),
        onPressed: () => _onNavItemTapped(index),
      ),
    );
  }

  /// Builds the content based on the selected index.
  Widget _buildContent(int index) {
    return switch (index) {
      0 => buildTransactionList(context),
      1 => const BudgetOverviewScreen(),
      2 => const Center(child: Text("Reports Page")),
      3 => const SettingsScreen(),
      _ => const Center(child: Text("Select an option")),
    };
  }

  /// Builds the transaction list.
  // After: Using Consumer<TransactionProvider>
  Widget buildTransactionList(BuildContext context) {
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
