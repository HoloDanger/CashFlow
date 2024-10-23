import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CategoryProvider with ChangeNotifier {
  final Logger logger = Logger();
  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Utilities',
    'Other',
  ];

  List<String> get categories =>
      List.unmodifiable(_categories); // Prevent external modification

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      // Check for duplicates
      _categories.add(category);
      logger.i('Added category: $category');
      notifyListeners();
    } else {
      logger.w('Category already exists: $category');
    }
  }

  void editCategory(int index, String newCategory) {
    if (index >= 0 && index < _categories.length) {
      // Check for valid index
      String oldCategory = _categories[index];
      _categories[index] = newCategory;
      logger.i('Edited category: $oldCategory to $newCategory');
      notifyListeners();
    } else {
      logger.e('Invalid index for editing category: $index');
    }
  }

  void deleteCategory(int index) {
    if (index >= 0 && index < _categories.length) {
      // Check for valid index
      String removedCategory = _categories[index];
      _categories.removeAt(index);
      logger.i('Deleted category: $removedCategory');
      notifyListeners();
    } else {
      logger.e('Invalid index for deleting category: $index');
    }
  }
}
