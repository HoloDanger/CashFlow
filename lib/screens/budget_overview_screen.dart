import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/budget_provider.dart';
import 'package:money_tracker/widgets/side_navigation.dart';

class BudgetOverviewScreen extends StatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  BudgetOverviewScreenState createState() => BudgetOverviewScreenState();
}

class BudgetOverviewScreenState extends State<BudgetOverviewScreen> {
  final GlobalKey<SideNavigationState> _sideNavKey =
      GlobalKey<SideNavigationState>();
  final int _selectedIndex = 1; // Budget index

  late Future<void> _fetchBudgetDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchBudgetDataFuture = _fetchBudgetData();
  }

  Future<void> _fetchBudgetData() async {
    // Implement your data fetching logic here
    // For example:
    // await Provider.of<BudgetProvider>(context, listen: false).fetchBudgetData();
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
            'Budget Overview',
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
        body: FutureBuilder(
          future: _fetchBudgetDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              );
            } else {
              return Consumer<BudgetProvider>(
                builder: (context, budgetProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Monthly Budget
                        _buildBudgetCard(
                          'Monthly Budget',
                          budgetProvider.monthlyBudget.toStringAsFixed(2),
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        // Total Expenses
                        _buildBudgetCard(
                          'Total Expenses',
                          budgetProvider.totalMonthlyExpenses
                              .toStringAsFixed(2),
                          Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        // Remaining Budget
                        _buildBudgetCard(
                          'Remaining Budget',
                          (budgetProvider.monthlyBudget -
                                  budgetProvider.totalMonthlyExpenses)
                              .toStringAsFixed(2),
                          budgetProvider.isWithinBudget()
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(height: 20),
                        // Categories
                        Expanded(
                          child: ListView.builder(
                            itemCount: budgetProvider.budgetCategories.length,
                            itemBuilder: (context, index) {
                              String categoryName = budgetProvider
                                  .budgetCategories.keys
                                  .elementAt(index);
                              var category =
                                  budgetProvider.budgetCategories[categoryName];
                              return Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.teal[100],
                                    child: Icon(
                                      Icons.category,
                                      color: Colors.teal[600],
                                    ),
                                  ),
                                  title: Text(
                                    category!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Text(
                                    '\u20B1${(budgetProvider.categoryExpenses[categoryName]?.toStringAsFixed(2) ?? '0.00')}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBudgetCard(String title, String value, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAD73), Color(0xFFAABD36)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fredoka',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\u20B1$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
