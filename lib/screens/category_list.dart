import 'package:flutter/material.dart';
import 'package:namer_app/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Make sure to import the color picker
import '../main.dart';

class CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;
    final theme = Theme.of(context); // Get the current theme

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: theme.colorScheme.surface,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color,
            ),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditCategoryDialog(context, category, index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Provider.of<CategoryProvider>(context, listen: false)
                        .removeCategory(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method to show the edit category dialog
  void _showEditCategoryDialog(BuildContext context, Category category, int index) {
    final TextEditingController _categoryNameController =
        TextEditingController(text: category.name);
    Color _selectedColor = category.color; // Initialize selected color

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryNameController,
                      decoration: InputDecoration(labelText: 'Category Name'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _pickColor(context, (color) {
                          setState(() {
                            _selectedColor = color; // Update the selected color
                          });
                        });
                      },
                      child: const Text('Pick Color'),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 50,
                      width: double.infinity,
                      color: _selectedColor, // Show the selected color
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  Provider.of<CategoryProvider>(context, listen: false).editCategory(
                    index,
                    Category(
                      name: _categoryNameController.text,
                      color: _selectedColor,
                    ),
                  );
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show the color picker
  void _pickColor(BuildContext context, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickedColor = Colors.blue; // Default color

        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickedColor,
              onColorChanged: (color) {
                pickedColor = color; // Update the picked color
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                onColorSelected(pickedColor); // Return the selected color
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
