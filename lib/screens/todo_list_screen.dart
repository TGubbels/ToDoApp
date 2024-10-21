import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/screens/category_screen.dart';
import 'add_todo_screen.dart';
import '../main.dart'; // Importing the Todo class and CategoryProvider
import 'todo_item_widget.dart';
import 'todo_app_bar.dart';
import 'todo_list_view.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  Todo? _lastRemovedTodo;
  int? _lastRemovedIndex;

  DateTime _currentDate = DateTime.now();
  int _daysToLoad = 100;

  Map<String, List<Todo>> _groupTodosByDay(DateTime day) {
    Map<String, List<Todo>> groupedTodos = {};
    for (var todo in _todos) {
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
    final updatedTodo = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(todo: _todos[index]),
      ),
    );

    if (updatedTodo != null) {
      setState(() {
        _todos[index] = updatedTodo;
      });
    }
  }

  void _removeTodoAt(int index) {
    _lastRemovedTodo = _todos[index];
    _lastRemovedIndex = index;

    setState(() {
      _todos.removeAt(index);
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
      setState(() {
        _todos.insert(_lastRemovedIndex!, _lastRemovedTodo!);
        _lastRemovedTodo = null;
        _lastRemovedIndex = null;
      });
    }
  }

  void _toggleTodoCompletion(int index, bool? value) {
    if (value == true) {
      _lastRemovedTodo = _todos[index];
      _lastRemovedIndex = index;

      setState(() {
        _todos.removeAt(index);
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
    return Scaffold(
      appBar: TodoAppBar(),  // Reuse the AppBar
      body: TodoListView(
        todos: _todos,
        groupTodosByDay: _groupTodosByDay,
        toggleTodoCompletion: _toggleTodoCompletion,
        editTodo: _editTodo,
        removeTodoAt: _removeTodoAt,
        daysToLoad: _daysToLoad,
        onLoadMoreDays: () {
          setState(() {
            _daysToLoad += 7;
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
              _todos.add(newTodo);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
