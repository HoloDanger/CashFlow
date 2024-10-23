import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

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
  void setMonthlyBudget(double budget) {
    _monthlyBudget = budget;
    notifyListeners();
  }

  void toggleGlobalNotification(bool value) {
    _globalNotify = value;
    notifyListeners();
  }

  bool get globalNotify => _globalNotify;

  void addBudgetCategory(
      String categoryName, double amount, bool notifyWhenExceeded) {
    if (!_budgetCategories.containsKey(categoryName)) {
      _budgetCategories[categoryName] = BudgetCategory(
          name: categoryName,
          amount: amount,
          notifyWhenExceeded: notifyWhenExceeded);
      _categoryExpenses[categoryName] = 0.0;
      notifyListeners();
    }
  }

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
    }
  }

  void deleteBudgetCategory(String category) {
    _budgetCategories.remove(category);
    _categoryExpenses.remove(category);
    notifyListeners();
  }

  // Expense Management
  void addExpense(String category, double amount) {
    if (_budgetCategories.containsKey(category)) {
      _categoryExpenses[category] =
          (_categoryExpenses[category] ?? 0.0) + amount;
      notifyListeners();
      updateAndCheckBudgets();
    }
  }

  // Budget Checking
  void updateAndCheckBudgets() {
    _categoryExpenses.forEach((category, expense) {
      checkCategoryBudgetExceeded(category);
    });
    _checkBudgetExceeded();
  }

  void checkCategoryBudgetExceeded(String category) {
    var categoryBudget = _budgetCategories[category];
    if (categoryBudget != null &&
        _categoryExpenses[category]! > categoryBudget.amount &&
        categoryBudget.notifyWhenExceeded) {
      sendCategoryBudgetExceededNotification(category);
    }
  }

  void _checkBudgetExceeded() {
    if (totalMonthlyExpenses > _monthlyBudget) {
      notifyListeners();
      sendBudgetExceededNotification();
    }
  }

  // Notification Methods
  Future<void> sendBudgetExceededNotification() async {
    if (_globalNotify) {
      final notificationDetails = _getAndroidNotificationDetails(
          'your channel id', 'your channel name');
      await _showNotification(0, 'Budget Exceeded',
          'You have spent more than your monthly budget!', notificationDetails);
    }
  }

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

  NotificationDetails _getAndroidNotificationDetails(String id, String name) {
    return NotificationDetails(
        android: AndroidNotificationDetails(id, name,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false));
  }

  Future<void> _showNotification(
      int id, String title, String body, NotificationDetails details,
      {String? payload}) async {
    await flutterLocalNotificationsPlugin.show(id, title, body, details,
        payload: payload);
  }

  // Helper Methods
  double _calculateTotalMonthlyExpenses() {
    return _categoryExpenses.values.fold(0.0, (sum, expense) => sum + expense);
  }

  bool isWithinBudget() => totalMonthlyExpenses <= _monthlyBudget;

  // Notification Callbacks
  Future<void> onSelectNotification(String payload) async {
    debugPrint('Notification payload: $payload');
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    logger.d(
        'Received notification: id=$id, title=$title, body=$body, payload=$payload');
  }
}

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
