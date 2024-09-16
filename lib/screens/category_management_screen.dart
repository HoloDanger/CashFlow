import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:money_tracker/providers/category_provider.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    void addCategory() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String newCategory = '';
          return AlertDialog(
            title: const Text('Add Category'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Category Name'),
              onChanged: (value) {
                newCategory = value;
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
                  if (newCategory.isNotEmpty) {
                    categoryProvider.addCategory(newCategory);
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

    void editCategory(int index) {
      String updatedCategory = categoryProvider.categories[index];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Edit Category'),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Category Name'),
              controller: TextEditingController(text: updatedCategory),
              onChanged: (value) {
                updatedCategory = value;
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
                  if (updatedCategory.isNotEmpty) {
                    categoryProvider.editCategory(index, updatedCategory);
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

    void deleteCategory(int index) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Category'),
            content:
                const Text('Are you sure you want to delete this category?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  categoryProvider.deleteCategory(index);
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
          'Manage Categories',
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
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return ListView.builder(
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(categoryProvider.categories[index]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => editCategory(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteCategory(index),
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
        onPressed: addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
