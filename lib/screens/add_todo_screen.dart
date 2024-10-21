import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Import Todo and CategoryProvider

class AddTodoScreen extends StatefulWidget {
  final Todo? todo;

  AddTodoScreen({this.todo});

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  DateTime _dueDate = DateTime.now(); // Default to today's date
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if (widget.todo != null) {
      // If editing an existing todo, initialize the fields with its values
      _title = widget.todo!.title;
      _dueDate = widget.todo!.dueDate;
      _selectedCategory = widget.todo!.category;
    } else {
      // If adding a new todo, select the first available category by default
      if (categoryProvider.categories.isNotEmpty) {
        _selectedCategory = categoryProvider.categories.first;
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo != null ? 'Edit Todo' : 'Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Due Date: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectDueDate(context),
                child: Text('Select Due Date'),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: categoryProvider.categories.map((category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: category.color, // Show category color
                            shape: BoxShape.circle, // Circle for color display
                          ),
                        ),
                        SizedBox(width: 10), // Space between circle and text
                        Text(category.name), // Category name
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      Todo(
                        title: _title,
                        dueDate: _dueDate, // Set due date
                        category: _selectedCategory!, // Assign selected category
                      ),
                    );
                  }
                },
                child: Text(widget.todo != null ? 'Update Todo' : 'Add Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
