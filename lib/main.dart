import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/todo_list_screen.dart';
import 'screens/category_screen.dart';

void main() {
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

// Category model
class Category {
  String name;
  Color color;

  Category({required this.name, required this.color});
}

// CategoryProvider for managing categories
class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [
    Category(name: 'Work', color: Colors.blue),
    Category(name: 'Personal', color: Colors.green),
  ];

  List<Category> get categories => _categories;

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void editCategory(int index, Category newCategory) {
    _categories[index] = newCategory;
    notifyListeners();
  }

  void removeCategory(int index) {
    _categories.removeAt(index);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CategoryProvider(),
      child: MaterialApp(
        title: 'Todo List App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, // Base color of the app
            primary: Colors.white,
            brightness: Brightness.dark,
            //surface: Colors.grey[850] // Ensures a dark theme
            //secondary: Colors.grey.shade800,
            surface: Colors.grey[850],
            onSurface: Colors.white,
            secondary: Colors.green.shade900,

            // secondaryContainer: Colors.white
          ),
          inputDecorationTheme: InputDecorationTheme(
            
            filled: true, // Enables filling the background of the text field
            fillColor: Colors.grey.shade700, // Background color of text field
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(
                color: Colors.grey.shade500, // Border color
              ),
            ),
            labelStyle: TextStyle(
              color: Colors.white,
               
            ),
            hintStyle: TextStyle(
              color: Colors.white, 
            ),
          ),
          
           iconTheme: IconThemeData(
            color: Colors.white, // Set your desired icon color here
            size: 24, // You can also set the default size
          ),
          // Optionally, you can set specific icon colors for light and dark themes
          primaryIconTheme: IconThemeData(
            color: Colors.white, // Change this to your preferred color
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

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
