import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/providers/todo_provider.dart';
import 'package:provider/provider.dart';
import 'add_todo_screen.dart';
import '../main.dart'; // Importing the Todo class and TodoProvider
import 'todo_item_widget.dart';
import 'todo_app_bar.dart';
import 'todo_list_view.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  int _daysToLoad = 100;

  Map<String, List<Todo>> _groupTodosByDay(DateTime day, List<dynamic> todos) {
    Map<String, List<Todo>> groupedTodos = {};
    for (var todo in todos) {
      if (DateFormat('yyyy-MM-dd').format(todo.dueDate) == DateFormat('yyyy-MM-dd').format(day)) {
        String dayKey = DateFormat('EEEE, MMM dd').format(todo.dueDate);
        if (!groupedTodos.containsKey(dayKey)) {
          groupedTodos[dayKey] = [];
        }
        groupedTodos[dayKey]?.add(todo);
      }
    }
    return groupedTodos;
  }

void _editTodo(Todo todo) async {
  final todoProvider = Provider.of<TodoProvider>(context, listen: false);
  
  // Show the modal bottom sheet with the existing todo
  final updatedTodo = await showModalBottomSheet<Todo>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return AddTodoScreen(todo: todo); // Pass the existing todo directly
    },
  );

  // Check if the updatedTodo is not null
  if (updatedTodo != null) {
    setState(() {
      // Find the index of the todo to update
      int index = todoProvider.todos.indexOf(todo); // Find the index using the todo object
      todoProvider.editTodo(index, updatedTodo); // Update the todo via the provider
    });
  }
}



  void _showAddTodoModal(BuildContext context) async {
    final newTodo = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true, // Allow the sheet to be scrollable
      builder: (BuildContext context) {
        return AddTodoScreen(); // For adding new todo
      },
    );
    if (newTodo != null) {
      setState(() {
        final todoProvider = Provider.of<TodoProvider>(context, listen: false);
        todoProvider.addTodo(newTodo); // Add new todo via provider
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos; // Get todos from provider

    return Scaffold(
      body: TodoListView(
        groupTodosByDay: (day) => _groupTodosByDay(day, todos), // Group todos using the provider's todos 
        editTodo: _editTodo,
        daysToLoad: _daysToLoad,
        onLoadMoreDays: () {
          setState(() {
            _daysToLoad += 7; // Load more days
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoModal(context), // Show the modal bottom sheet
        child: Icon(Icons.add),
      ),
    );
  }
}
