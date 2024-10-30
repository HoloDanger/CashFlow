import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// A provider class for managing budgets and expenses.
class BudgetProvider with ChangeNotifier {
  final Logger logger = Logger();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Budget configuration
  final Map<String, BudgetCategory> _budgetCategories = {};
  final Map<String, double> _categoryExpenses = {};
  double _monthlyBudget = 1000.0;
  bool _globalNotify = false;

  // Constructor
  BudgetProvider() {
    _initNotifications();
  }

  // Getter for budget categories
  Map<String, BudgetCategory> get budgetCategories =>
      Map.unmodifiable(_budgetCategories);

  // Getter for category expenses
  Map<String, double> get categoryExpenses =>
      Map.unmodifiable(_categoryExpenses);

  // Getter for total monthly expenses
  double get totalMonthlyExpenses => _calculateTotalMonthlyExpenses();

  // Getter for monthly budget
  double get monthlyBudget => _monthlyBudget;

  // Notification Initialization
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
        }
      },
    );
  }

  // Budget Management Methods
  /// Sets the monthly budget.
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  /// Toggles global notifications.
  void toggleGlobalNotification(bool value) {
    _globalNotify = value;
    notifyListeners();
  }

  bool get globalNotify => _globalNotify;

  /// Adds a new budget category.
  void addBudgetCategory(
      String categoryName, double amount, bool notifyWhenExceeded) {
    if (!_budgetCategories.containsKey(categoryName)) {
      _budgetCategories[categoryName] = BudgetCategory(
          name: categoryName,
          amount: amount,
          notifyWhenExceeded: notifyWhenExceeded);
      _categoryExpenses[categoryName] = 0.0;
      notifyListeners();
    } else {
      logger.w('Category already exists: $categoryName');
      throw ArgumentError(
          'Category already exists. Please provide a unique category name.');
    }
  }

  /// Edits an existing budget category.
  void editBudgetCategory(String oldCategoryName, String newCategoryName,
      double newAmount, bool notifyWhenExceeded) {
    if (_budgetCategories.containsKey(oldCategoryName)) {
      _budgetCategories[newCategoryName] = BudgetCategory(
          name: newCategoryName,
          amount: newAmount,
          notifyWhenExceeded: notifyWhenExceeded);
      _categoryExpenses[newCategoryName] =
          _categoryExpenses.remove(oldCategoryName) ?? 0.0;
      _budgetCategories.remove(oldCategoryName);
      notifyListeners();
    } else {
      logger.e('Category not found: $oldCategoryName');
      throw ArgumentError(
          'Category not found. Please provide a valid category name.');
    }
  }

  /// Deletes a budget category.
  void deleteBudgetCategory(String category) {
    if (_budgetCategories.containsKey(category)) {
      _budgetCategories.remove(category);
      _categoryExpenses.remove(category);
      notifyListeners();
    } else {
      logger.e('Category not found: $category');
      throw ArgumentError(
          'Category not found. Please provide a valid category name.');
    }
  }

  // Expense Management
  /// Adds an expense to a category.
  void addExpense(String category, double amount) {
    if (_budgetCategories.containsKey(category)) {
      _categoryExpenses[category] =
          (_categoryExpenses[category] ?? 0.0) + amount;
      notifyListeners();
      updateAndCheckBudgets();
    }
  }

  // Budget Checking
  /// Updates and checks budgets.
  void updateAndCheckBudgets() {
    _categoryExpenses.forEach((category, expense) {
      checkCategoryBudgetExceeded(category);
    });
    _checkBudgetExceeded();
  }

  /// Checks if a category budgets is exceeded.
  void checkCategoryBudgetExceeded(String category) {
    var categoryBudget = _budgetCategories[category];
    if (categoryBudget != null &&
        _categoryExpenses[category]! > categoryBudget.amount &&
        categoryBudget.notifyWhenExceeded) {
      sendCategoryBudgetExceededNotification(category);
    }
  }

  /// Checks if the total budget is exceeded.
  void _checkBudgetExceeded() {
    if (totalMonthlyExpenses > _monthlyBudget) {
      notifyListeners();
      sendBudgetExceededNotification();
    }
  }

  // Notification Methods
  /// Sends a notification when the total budget is exceeded.
  Future<void> sendBudgetExceededNotification() async {
    if (_globalNotify) {
      final notificationDetails = _getAndroidNotificationDetails(
          'your channel id', 'your channel name');
      await _showNotification(0, 'Budget Exceeded',
          'You have spent more than your monthly budget!', notificationDetails);
    }
  }

  /// Sends a notification when a category budget is exceeded.
  Future<void> sendCategoryBudgetExceededNotification(String category) async {
    if (_globalNotify) {
      final notificationDetails = _getAndroidNotificationDetails(
          'category channel id', 'Category channel name');
      await _showNotification(
          1,
          '$category Budget Exceeded',
          'You have spent more than your budget for $category!',
          notificationDetails,
          payload: category);
    }
  }

  /// Gets Android notification details.
  NotificationDetails _getAndroidNotificationDetails(String id, String name) {
    return NotificationDetails(
        android: AndroidNotificationDetails(id, name,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false));
  }

  /// Shows a notification.
  Future<void> _showNotification(
      int id, String title, String body, NotificationDetails details,
      {String? payload}) async {
    await flutterLocalNotificationsPlugin.show(id, title, body, details,
        payload: payload);
  }

  // Helper Methods
  /// Calculates the total monthly expenses.
  double _calculateTotalMonthlyExpenses() {
    return _categoryExpenses.values.fold(0.0, (sum, expense) => sum + expense);
  }

  /// Checks if the total expenses are within the budget.
  bool isWithinBudget() => totalMonthlyExpenses <= _monthlyBudget;

  // Notification Callbacks
  /// Handles notification selection.
  Future<void> onSelectNotification(String payload) async {
    debugPrint('Notification payload: $payload');
  }

  /// Handles received local notifications.
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    logger.d(
        'Received notification: id=$id, title=$title, body=$body, payload=$payload');
  }
}

/// A class representing a budget category.
class BudgetCategory {
  String name;
  double amount;
  bool notifyWhenExceeded;

  BudgetCategory({
    required this.name,
    required this.amount,
    required this.notifyWhenExceeded,
  });

  @override
  String toString() {
    return name;
  }
}
