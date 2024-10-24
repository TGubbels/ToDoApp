import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:namer_app/main.dart';

class TodoProvider extends ChangeNotifier {
  List<dynamic> _todos = [];
  Todo? _lastRemovedTodo;
  int? _lastRemovedIndex;
  late Box _todoBox;

  List<dynamic> get todos => _todos;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
     var _todoBox = await Hive.openBox('todos');
    _todos = _todoBox.values.toList();
    notifyListeners();
  }

  Future<void> addTodo(Todo todo) async{
    var _todoBox = await Hive.openBox('todos');
    _todos.add(todo);
    _todoBox.add(todo); // Save to Hive
    notifyListeners();
  }

  Future <void> removeTodoWithUndo(BuildContext context, dynamic todo) async{
    var _todoBox = await Hive.openBox('todos');
    _lastRemovedTodo = todo;
    _lastRemovedIndex = _todos.indexOf(todo);

    _todoBox.deleteAt(_todos.indexOf(todo));
    _todos.remove(todo);
    // Remove from Hive by key (unique title)
    notifyListeners();

    
    // Show Snackbar for undo
    
  }

  Future<void> undoRemoveTodo() async{
    var _todoBox = await Hive.openBox('todos');
    if (_lastRemovedTodo != null && _lastRemovedIndex != null) {
      _todos.add(_lastRemovedTodo!);
      _todoBox.add(_lastRemovedTodo!); // Restore in Hive
      _lastRemovedTodo = null;
      _lastRemovedIndex = null;
      notifyListeners();
    }
  }

  Future<void> editTodo(int index, Todo updatedTodo) async{
    var _todoBox = await Hive.openBox('todos');
    _todos[index] = updatedTodo;
    _todoBox.putAt(index, updatedTodo); // Update in Hive
    notifyListeners();
  }
}
