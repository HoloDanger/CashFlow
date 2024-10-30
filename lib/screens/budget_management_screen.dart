import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/budget_provider.dart';
import 'package:logger/logger.dart';

class BudgetManagementScreen extends StatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  BudgetManagementScreenState createState() => BudgetManagementScreenState();
}

class BudgetManagementScreenState extends State<BudgetManagementScreen> {
  final TextEditingController _budgetAmountController = TextEditingController();
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Budget Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Fredoka',
            fontSize: 24,
            fontVariations: <FontVariation>[FontVariation('wght', 700)],
            shadows: <Shadow>[
              Shadow(
                offset: Offset(-2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.3),
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
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: budgetProvider.budgetCategories.length,
                  itemBuilder: (context, index) {
                    var category =
                        budgetProvider.budgetCategories.keys.elementAt(index);
                    var budgetCategory =
                        budgetProvider.budgetCategories[category]!;
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
                          category,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Budget: ₱${budgetCategory.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontFamily: 'Fredoka',
                            fontSize: 14,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () {
                                logger.i('Editing budget category: $category');
                                _editBudgetCategory(category);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                logger.i('Deleting budget category: $category');
                                _deleteBudgetCategory(category);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Global Budget Notifications:',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    Switch(
                      value: budgetProvider.globalNotify,
                      activeColor: Color(0xFF4CAD73),
                      onChanged: (value) {
                        logger.i('Toggling global notifications: $value');
                        budgetProvider.toggleGlobalNotification(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4CAF50),
        onPressed: _addBudgetCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addBudgetCategory() {
    String newCategory = '';
    double? newAmount;
    bool notifyWhenExceeded = false;
    final formKey = GlobalKey<FormState>();
    _budgetAmountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Budget Category',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  onChanged: (value) => newCategory = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetAmountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  onChanged: (value) => newAmount = double.tryParse(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  activeColor: Color(0xFF4CAD73),
                  title: const Text(
                    "Notify when budget is exceeded",
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                    ),
                  ),
                  value: notifyWhenExceeded,
                  onChanged: (bool? value) {
                    setState(() => notifyWhenExceeded = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Provider.of<BudgetProvider>(context, listen: false)
                      .addBudgetCategory(
                          newCategory, newAmount!, notifyWhenExceeded);
                  logger.i(
                      'Added new budget category: $newCategory with amount: $newAmount');
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editBudgetCategory(String oldCategory) {
    String updatedCategory = oldCategory;
    double? newAmount;
    bool notifyWhenExceeded =
        Provider.of<BudgetProvider>(context, listen: false)
            .budgetCategories[oldCategory]!
            .notifyWhenExceeded;
    final formKey = GlobalKey<FormState>();
    _budgetAmountController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Budget Category',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  initialValue: updatedCategory,
                  onChanged: (value) => updatedCategory = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'New Budget Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                  ),
                  onChanged: (value) => newAmount = double.tryParse(value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  activeColor: Color(0xFF4CAD73),
                  title: const Text(
                    "Notify when budget is exceeded",
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                    ),
                  ),
                  value: notifyWhenExceeded,
                  onChanged: (bool? value) {
                    setState(() => notifyWhenExceeded = value ?? false);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && newAmount != null) {
                  Provider.of<BudgetProvider>(context, listen: false)
                      .editBudgetCategory(
                    oldCategory,
                    updatedCategory,
                    newAmount!,
                    notifyWhenExceeded,
                  );
                  logger.i(
                      'Edited budget category: $oldCategory to $updatedCategory');
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteBudgetCategory(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Budget Category',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this budget category?',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<BudgetProvider>(context, listen: false)
                    .deleteBudgetCategory(category);
                logger.i('Deleted budget category: $category');
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
