import 'package:flutter/material.dart';
import 'package:namer_app/screens/category_screen.dart';
import 'package:namer_app/screens/todo_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(TodoAdapter()); // Register adapters
  Hive.registerAdapter(CategoryAdapter());
  runApp(MyApp());
}

// Todo class
class Todo {
  String title;
  DateTime dueDate;
  bool isCompleted;
  Category category;

  Todo({
    required this.title,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
  });
}

// Category class
class Category {
  String name;
  Color color;

  Category({required this.name, required this.color});
}

// Adapter for Todo
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final typeId = 1;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      title: reader.readString(),
      dueDate: DateTime.parse(reader.readString()),
      isCompleted: reader.readBool(),
      category: reader.read() as Category, // Read Category using its adapter
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.dueDate.toIso8601String());
    writer.writeBool(obj.isCompleted);
    writer.write(obj.category); // Write Category using its adapter
  }
}

// Adapter for Category
class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final typeId = 2;

  @override
  Category read(BinaryReader reader) {
    return Category(
      name: reader.readString(),
      color: Color(reader.readInt()), // Read color as int and convert to Color
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.color.value); // Write Color as int
  }
}

// CategoryProvider for managing categories
class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  late Box _categoryBox;

  List<Category> get categories => _categories;

  CategoryProvider() {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _categoryBox = await Hive.openBox('categories');
    _categories = _categoryBox.values
        .map((category) => category as Category)
        .toList();
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    _categoryBox.add(category); // Save to Hive
    notifyListeners();
  }

  void editCategory(int index, Category newCategory) {
    _categories[index] = newCategory;
    _categoryBox.putAt(index, newCategory); // Update in Hive
    notifyListeners();
  }

  void removeCategory(int index) {
    _categoryBox.deleteAt(index); // Remove from Hive
    _categories.removeAt(index);
    notifyListeners();
  }
}

// TodoProvider for managing todos
class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  Todo? _lastRemovedTodo;
  int? _lastRemovedIndex;
  late Box _todoBox;

  List<Todo> get todos => _todos;

  TodoProvider() {
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    _todoBox = await Hive.openBox('todos');
    _todos = _todoBox.values
        .map((todo) => todo as Todo)
        .toList();
    notifyListeners();
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    _todoBox.add(todo); // Save to Hive
    notifyListeners();
  }

  void removeTodoAt(int index) {
    _todoBox.deleteAt(index); // Remove from Hive
    _todos.removeAt(index);
    notifyListeners();
  }

  void removeTodoWithUndo(BuildContext context, Todo todo) {
    _lastRemovedTodo = todo;
    _lastRemovedIndex = _todos.indexOf(todo);

    _todos.remove(todo);
    _todoBox.delete(todo.title); // Remove from Hive by key (unique title)
    notifyListeners();

    // Show Snackbar for undo
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Todo "${todo.title}" removed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          _undoRemoveTodo();
        },
      ),
      duration: Duration(seconds: 10),
    ));
  }

  void _undoRemoveTodo() {
    if (_lastRemovedTodo != null && _lastRemovedIndex != null) {
      _todos.insert(_lastRemovedIndex!, _lastRemovedTodo!);
      _todoBox.putAt(_lastRemovedIndex!, _lastRemovedTodo!); // Restore in Hive
      _lastRemovedTodo = null;
      _lastRemovedIndex = null;
      notifyListeners();
    }
  }

  void toggleTodoCompletion(int index, bool? value) {
    _todos[index].isCompleted = value ?? false;
    _todoBox.putAt(index, _todos[index]); // Save to Hive
    notifyListeners();
  }

  void editTodo(int index, Todo updatedTodo) {
    _todos[index] = updatedTodo;
    _todoBox.putAt(index, updatedTodo); // Update in Hive
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => TodoProvider()),
      ],
      child: MaterialApp(
        title: 'Todo List App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.white,
            brightness: Brightness.dark,
            surface: Colors.grey[850],
            onSurface: Colors.white,
            secondary: Colors.green.shade900,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade700,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Colors.grey.shade500,
              ),
            ),
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 24,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Set the background color
        backgroundColor: Colors.green.shade700, // Set the text color
        shadowColor: Colors.black, // Set the shadow color
      ),
    ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

// Home Screen with Bottom Navigation Bar
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TodoListScreen(),
    CategoryScreen(),
  ];

  final List<String> _screensBars = [
    "ToDo list",
    "Categories",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.secondary ,
        
        title: Text(_screensBars[_currentIndex]),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.colorScheme.secondary,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
