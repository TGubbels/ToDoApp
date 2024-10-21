import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Ensure Todo class and CategoryProvider are accessible
// Access categories for dropdown

class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  EditTodoScreen({required this.todo});

  @override
  _EditTodoScreenState createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  late TextEditingController _titleController;
  DateTime? _selectedDate;
  Category? _selectedCategory; // Variable to hold the selected category

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _selectedDate = widget.todo.dueDate;
    _selectedCategory = widget.todo.category; // Set the selected category
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTodo() {
    if (_titleController.text.isNotEmpty && _selectedDate != null && _selectedCategory != null) {
      final updatedTodo = Todo(
        title: _titleController.text,
        dueDate: _selectedDate!,
        isCompleted: widget.todo.isCompleted,
        category: _selectedCategory!, // Save selected Category object
      );
      Navigator.pop(context, updatedTodo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context); // Assuming you have this provider

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Todo Title'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
              ),
            ),
            SizedBox(height: 10),
            // Category selection dropdown
            DropdownButton<Category>(
              value: _selectedCategory,
              hint: Text('Select Category'),
              items: categoryProvider.categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: category.color,
                        radius: 10,
                      ),
                      SizedBox(width: 10),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value; // Set selected category
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTodo,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
