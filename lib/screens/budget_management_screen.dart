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
        title: const Text('Manage Budget Categories',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                    return ListTile(
                      title: Text(category),
                      subtitle: Text(
                          'Budget: \$${budgetCategory.amount.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              logger.i('Editing budget category: $category');
                              _editBudgetCategory(category);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              logger.i('Deleting budget category: $category');
                              _deleteBudgetCategory(category);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text('Global Budget Notifications:'),
                    Switch(
                      value: budgetProvider.globalNotify,
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
        backgroundColor: Colors.teal,
        onPressed: _addBudgetCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addBudgetCategory() {
    String newCategory = '';
    double? newAmount;
    bool notifyWhenExceeded = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Budget Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                    onChanged: (value) => newCategory = value,
                  ),
                  TextField(
                    controller: _budgetAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Budget Amount'),
                    onChanged: (value) => newAmount = double.tryParse(value),
                  ),
                  CheckboxListTile(
                    title: const Text("Notify when budget is exceeded"),
                    value: notifyWhenExceeded,
                    onChanged: (bool? value) {
                      setState(() => notifyWhenExceeded = value ?? false);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (newCategory.isNotEmpty && newAmount != null) {
                      Provider.of<BudgetProvider>(context, listen: false)
                          .addBudgetCategory(
                              newCategory, newAmount!, notifyWhenExceeded);
                      logger.i(
                          'Added new budget category: $newCategory with amount: $newAmount');
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Budget Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    decoration:
                        const InputDecoration(labelText: 'Category Name'),
                    controller: TextEditingController(text: updatedCategory),
                    onChanged: (value) => updatedCategory = value,
                  ),
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'New Budget Amount'),
                    onChanged: (value) => newAmount = double.tryParse(value),
                  ),
                  CheckboxListTile(
                    title: const Text("Notify when budget is exceeded"),
                    value: notifyWhenExceeded,
                    onChanged: (bool? value) {
                      setState(() => notifyWhenExceeded = value ?? false);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (updatedCategory.isNotEmpty && newAmount != null) {
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteBudgetCategory(String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Budget Category'),
          content: const Text(
              'Are you sure you want to delete this budget category?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<BudgetProvider>(context, listen: false)
                    .deleteBudgetCategory(category);
                logger.i('Deleted budget category: $category');
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
