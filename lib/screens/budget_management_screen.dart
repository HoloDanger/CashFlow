import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/budget_provider.dart';

class BudgetManagementScreen extends StatelessWidget {
  const BudgetManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);

    void addBudgetCategory() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String newBudgetCategory = '';
          return AlertDialog(
            title: const Text('Add Budget Category'),
            content: TextField(
              autofocus: true,
              decoration:
                  const InputDecoration(labelText: 'Budget Category Name'),
              onChanged: (value) {
                newBudgetCategory = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (newBudgetCategory.isNotEmpty) {
                    budgetProvider.addBudgetCategory(newBudgetCategory);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    void editBudgetCategory(int index) {
      String updatedBudgetCategory = budgetProvider.budgetCategories[index];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Budget Category'),
            content: TextField(
              autofocus: true,
              decoration:
                  const InputDecoration(labelText: 'Budget Category Name'),
              controller: TextEditingController(text: updatedBudgetCategory),
              onChanged: (value) {
                updatedBudgetCategory = value;
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (updatedBudgetCategory.isNotEmpty) {
                    budgetProvider.editBudgetCategory(
                        index, updatedBudgetCategory);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    void deleteBudgetCategory(int index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Budget Category'),
            content: const Text(
                'Are you sure you want to delete this budget category?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  budgetProvider.deleteBudgetCategory(index);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Budget Categories',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          return ListView.builder(
            itemCount: budgetProvider.budgetCategories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(budgetProvider.budgetCategories[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => editBudgetCategory(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteBudgetCategory(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: addBudgetCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
