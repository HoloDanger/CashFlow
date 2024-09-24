import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  // List of budget categories
  final List<String> _budgetCategories = [];

  // Map to store expenses for each category
  final Map<String, double> _categoryExpenses = {};

  // Total monthly budget
  double _monthlyBudget = 1000.0;

  // Constructor
  BudgetProvider();

  // Getter for budget categories
  List<String> get budgetCategories => _budgetCategories;

  // Getter for total monthly expenses
  double get totalMonthlyExpenses => _calculateTotalMonthlyExpenses();

  // Public getter for monthly budget
  double get monthlyBudget => _monthlyBudget;

  // Public getter for category expenses
  Map<String, double> get categoryExpenses =>
      Map.unmodifiable(_categoryExpenses);

  // Set monthly budget
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  // Method to add a budget category
  void addBudgetCategory(String category) {
    if (!_budgetCategories.contains(category)) {
      _budgetCategories.add(category);
      _categoryExpenses[category] =
          0.0; // Initialize expense for the new category
      notifyListeners();
    }
  }

  // Method to edit a budget category
  void editBudgetCategory(int index, String newCategory) {
    String oldCategory = _budgetCategories[index];

    // Update the category name in the list and transfer the expense amount
    _budgetCategories[index] = newCategory;
    _categoryExpenses[newCategory] =
        _categoryExpenses.remove(oldCategory) ?? 0.0;

    notifyListeners();
  }

  // Method to delete a budget category
  void deleteBudgetCategory(int index) {
    String category = _budgetCategories[index];
    _budgetCategories.removeAt(index);
    _categoryExpenses.remove(category);
    notifyListeners();
  }

  // Add expense to a category
  void addExpense(String category, double amount) {
    if (_budgetCategories.contains(category)) {
      _categoryExpenses[category] =
          (_categoryExpenses[category] ?? 0.0) + amount;
      notifyListeners();

      // Check if the budget is exceeded after adding the expense
      _checkBudgetExceeded();
    }
  }

  // Calculate total monthly expenses
  double _calculateTotalMonthlyExpenses() {
    return _categoryExpenses.values.fold(0.0, (sum, expense) => sum + expense);
  }

  // Compare total monthly expenses with the budget
  bool isWithinBudget() {
    return totalMonthlyExpenses <= _monthlyBudget;
  }

  // Check if the monthly budget is exceeded and notify listeners
  void _checkBudgetExceeded() {
    if (totalMonthlyExpenses > _monthlyBudget) {
      // Notify listeners that the budget is exceeded
      notifyListeners();
    }
  }
}
