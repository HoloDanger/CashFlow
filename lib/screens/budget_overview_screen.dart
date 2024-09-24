import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/budget_provider.dart';

class BudgetOverviewScreen extends StatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  BudgetOverviewScreenState createState() => BudgetOverviewScreenState();
}

class BudgetOverviewScreenState extends State<BudgetOverviewScreen> {
  late Future<void> _fetchBudgetDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchBudgetDataFuture = _fetchBudgetData();
  }

  Future<void> _fetchBudgetData() async {
    // Here you might want to fetch initial data or perform any setup if needed
    // For now, we'll assume the data is already available through the provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Overview',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder(
        future: _fetchBudgetDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
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
                        budgetProvider.totalMonthlyExpenses.toStringAsFixed(2),
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
                      // Optionally, add more details or a list of categories here
                      Expanded(
                        child: ListView.builder(
                          itemCount: budgetProvider.budgetCategories.length,
                          itemBuilder: (context, index) {
                            var category =
                                budgetProvider.budgetCategories[index];
                            return ListTile(
                              title: Text(category),
                              trailing: Text(
                                '\$${budgetProvider.categoryExpenses[category]?.toStringAsFixed(2) ?? '0.00'}',
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
    );
  }

  Widget _buildBudgetCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₱$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
