import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:namer_app/main.dart';

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
