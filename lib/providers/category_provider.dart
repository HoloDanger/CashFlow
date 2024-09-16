import 'package:flutter/material.dart';

class CategoryProvider with ChangeNotifier {
  final List<String> _categories = ['Food', 'Transportation', 'Entertainment', 'Utilities', 'Other'];

  List<String> get categories => _categories;

  void addCategory(String category) {
    _categories.add(category);
    notifyListeners();
  }

  void editCategory(int index, String newCategory) {
    _categories[index] = newCategory;
    notifyListeners();
  }

  void deleteCategory(int index) {
    _categories.removeAt(index);
    notifyListeners();
  }
}