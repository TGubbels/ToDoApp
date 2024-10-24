// add_category_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:namer_app/providers/category_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class AddCategoryForm extends StatefulWidget {
  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<AddCategoryForm> {
  final TextEditingController _categoryNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  void _pickColor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color; // Update the selected color
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addCategory() {
    final categoryName = _categoryNameController.text;
    if (categoryName.isNotEmpty) {
      final newCategory = Category(name: categoryName, color: _selectedColor);
      Provider.of<CategoryProvider>(context, listen: false).addCategory(newCategory);
      _categoryNameController.clear();
      _selectedColor = Colors.blue; // Reset to default color
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a category name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _categoryNameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              suffixIcon: IconButton(
                icon: Icon(Icons.color_lens),
                onPressed: () {
                  _pickColor(context); // Pass context to color picker
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          // Color preview for adding a category
          Container(
            height: 50,
            width: double.infinity,
            color: _selectedColor,
            margin: EdgeInsets.only(bottom: 20),
          ),
          ElevatedButton(
            onPressed: _addCategory,
            child: Text('Add Category'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose(); // Dispose of the controller
    super.dispose();
  }
}
