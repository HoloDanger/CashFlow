import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// A provider class for managing categories.
class CategoryProvider with ChangeNotifier {
  final Logger logger = Logger();

  /// Default categories.
  static const List<String> defaultCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Utilities',
    'Other',
  ];

  /// List of categories.
  final List<String> _categories = List.from(defaultCategories);

  /// Returns an unmodifiable list of categories.
  List<String> get categories => List.unmodifiable(_categories);

  /// Validates if the category is not empty.
  bool _isValidCategory(String category) {
    if (category.isEmpty) {
      logger.e('Cannot add an empty category');
      return false;
    }
    return true;
  }

  /// Adds a new category.
  void addCategory(String category) {
    if (!_isValidCategory(category)) {
      throw ArgumentError(
          'Category cannot be empty. Please provide a valid category name.');
    }
    if (!_categories.contains(category)) {
      _categories.add(category);
      logger.i('Added category: $category');
      notifyListeners();
    } else {
      logger.w('Category already exists: $category');
      throw ArgumentError(
          'Category already exists. Please provide a unique category name.');
    }
  }

  /// Edits an existing category.
  void editCategory(int index, String newCategory) {
    if (!_isValidCategory(newCategory)) {
      throw ArgumentError(
          'Category cannot be empty. Please provide a valid category name.');
    }
    if (index >= 0 && index < _categories.length) {
      // Check for valid index
      String oldCategory = _categories[index];
      _categories[index] = newCategory;
      logger.i('Edited category: $oldCategory to $newCategory');
      notifyListeners();
    } else {
      logger.e('Invalid index for editing category: $index');
      throw RangeError(
          'Invalid index for editing category, Please provide a valid index.');
    }
  }

  /// Deletes a category.
  void deleteCategory(int index) {
    if (index >= 0 && index < _categories.length) {
      // Check for valid index
      String removedCategory = _categories[index];
      _categories.removeAt(index);
      logger.i('Deleted category: $removedCategory');
      notifyListeners();
    } else {
      logger.e('Invalid index for deleting category: $index');
      throw RangeError('Invalid index for deleting category. Please provide a valid index.');
    }
  }
}
