import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  final List<String> _budgetCategories = [];

  List<String> get budgetCategories => _budgetCategories;

  void addBudgetCategory(String category) {
    _budgetCategories.add(category);
    notifyListeners();
  }

  void editBudgetCategory(int index, String newCategory) {
    _budgetCategories[index] = newCategory;
    notifyListeners();
  }

  void deleteBudgetCategory(int index) {
    _budgetCategories.removeAt(index);
    notifyListeners();
  }
}
