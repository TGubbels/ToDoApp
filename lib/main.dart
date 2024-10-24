import 'package:flutter/material.dart';
import 'package:namer_app/adapters/category_adapter.dart';
import 'package:namer_app/adapters/todo_adapter.dart';
import 'package:namer_app/providers/category_provider.dart';
import 'package:namer_app/providers/todo_provider.dart';
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
        backgroundColor: theme.colorScheme.secondary,
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
