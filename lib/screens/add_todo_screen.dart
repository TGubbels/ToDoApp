import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/Functions.dart';
import 'package:namer_app/providers/category_provider.dart';
import 'package:namer_app/screens/components/CategoryButton.dart';
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
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);

    // Focus on the title text field when the screen is initiated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocusNode.requestFocus();
    });

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

    // Reopen the keyboard after the date picker closes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_titleFocusNode);
    });
  }



  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context); // Get current theme

    return Padding(
      padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 10), // Adjust padding
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    focusNode: _titleFocusNode, // Set focus node
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
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3, // Take 1 part
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          child: ElevatedButton(
                            onPressed: () => _selectDueDate(context),
                            child: Text(
                                '${utils.formatDueDate(_dueDate)}'), // Only show the formatted date
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Space between buttons
                      Container(
                        width: MediaQuery.of(context).size.width* 2 / 3 - 8, // Take 2 parts (remaining space)
                        child: CategoryButton(
                          initialCategory: _selectedCategory,
                          onCategorySelected: (Category category) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                _selectedCategory != null) {
                              // If editing, update the existing Todo
                              if (widget.todo != null &&
                                  _selectedCategory != null) {
                                widget.todo!.title = _title;
                                widget.todo!.dueDate = _dueDate;
                                widget.todo!.category = _selectedCategory!;
                                Navigator.pop(context, widget.todo);
                              } else {
                                // If adding a new Todo
                                Navigator.pop(
                                  context,
                                  Todo(
                                    title: _title,
                                    dueDate: _dueDate, // Set due date
                                    category:
                                        _selectedCategory!, // Assign selected category
                                  ),
                                );
                              }
                            }
                          },
                          icon:
                              Icon(Icons.arrow_forward, size: 30, weight: 800),
                          color: Colors.white,
                          padding: EdgeInsets.all(2),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
