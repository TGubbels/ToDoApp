import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'add_todo_screen.dart';
import '../main.dart'; // Importing the Todo class and TodoProvider
import 'todo_item_widget.dart';
import 'todo_app_bar.dart';
import 'todo_list_view.dart';
 // Ensure to import the TodoProvider

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Todo? _lastRemovedTodo;
  int? _lastRemovedIndex;

  DateTime _currentDate = DateTime.now();
  int _daysToLoad = 100;

  Map<String, List<Todo>> _groupTodosByDay(DateTime day, List<Todo> todos) {
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

  void _editTodo(int index) async {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final updatedTodo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todo: todoProvider.todos[index]),
      ),
    );

    if (updatedTodo != null) {
      setState(() {
        todoProvider.editTodo(index, updatedTodo); // Update via provider
      });
    }
  }

  void _removeTodoAt(int index) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    _lastRemovedTodo = todoProvider.todos[index];
    _lastRemovedIndex = index;

    setState(() {
      todoProvider.removeTodoAt(index); // Remove via provider
    });

    final snackBar = SnackBar(
      content: Text('Todo "${_lastRemovedTodo?.title}" removed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: _undoRemoveTodo,
      ),
      duration: Duration(seconds: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _undoRemoveTodo() {
    if (_lastRemovedTodo != null && _lastRemovedIndex != null) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      setState(() {
        todoProvider.addTodo(_lastRemovedTodo!); // Add back via provider
        _lastRemovedTodo = null;
        _lastRemovedIndex = null;
      });
    }
  }

  void _toggleTodoCompletion(int index, bool? value) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    if (value == true) {
      _lastRemovedTodo = todoProvider.todos[index];
      _lastRemovedIndex = index;

      setState(() {
        todoProvider.toggleTodoCompletion(index, value); // Toggle via provider
      });

      final snackBar = SnackBar(
        content: Text('Todo "${_lastRemovedTodo?.title}" completed and removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: _undoRemoveTodo,
        ),
        duration: Duration(seconds: 10),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos; // Get todos from provider

    return Scaffold(
      appBar: TodoAppBar(), // Reuse the AppBar
      body: TodoListView(
        groupTodosByDay: (day) => _groupTodosByDay(day, todos), // Group todos using the provider's todos
        toggleTodoCompletion: _toggleTodoCompletion,
        editTodo: _editTodo,
        removeTodoAt: _removeTodoAt,
        daysToLoad: _daysToLoad,
        onLoadMoreDays: () {
          setState(() {
            _daysToLoad += 7; // Load more days
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoScreen()),
          );
          if (newTodo != null) {
            setState(() {
              todoProvider.addTodo(newTodo); // Add new todo via provider
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
