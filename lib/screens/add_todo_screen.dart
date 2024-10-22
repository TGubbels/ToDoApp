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

  // Function to determine how to display the due date
  String _formatDueDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    // Compare only the date part (year, month, day)
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else if (date.isAfter(today) &&
        date.isBefore(tomorrow.add(Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day of the week
    } else {
      return DateFormat('dd MMM').format(date); // e.g., "30 Okt."
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final theme = Theme.of(context); // Get current theme

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 10), // Adjust padding
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
                      Expanded(
                        flex: 1, // Take 1 part
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3, // Set width to 1/3 of the total width
                          child: ElevatedButton(
                            onPressed: () => _selectDueDate(context),
                            child: Text('${_formatDueDate(_dueDate)}'), // Only show the formatted date
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Space between buttons
                      Expanded(
                        flex: 2, // Take 2 parts (remaining space)
                        child: DropdownButtonFormField<Category>(
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
                          // Prevent dropdown from closing the keyboard
                          onTap: () {
                            FocusScope.of(context).unfocus(); // Prevent closing of the keyboard
                            FocusScope.of(context).requestFocus(_titleFocusNode);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(
                      alignment: Alignment.bottomRight, // Align button to the right
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary, // Set background color to secondary
                          borderRadius: BorderRadius.circular(12), // Make the background circular
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // If editing, update the existing Todo
                              if (widget.todo != null) {
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
                                    category: _selectedCategory!, // Assign selected category
                                  ),
                                );
                              }
                            }
                          },
                          icon: Icon(Icons.arrow_forward, size: 30, weight: 800), // Thicker arrow
                          color: Colors.white, // Icon color
                          padding: EdgeInsets.all(2), // Adjust padding for the icon button
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
