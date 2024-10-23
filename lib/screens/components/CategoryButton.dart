import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart'; // Import Todo and CategoryProvider


class CategoryButton extends StatefulWidget {
  final Category? initialCategory;
  final Function(Category) onCategorySelected;

  CategoryButton({this.initialCategory, required this.onCategorySelected});

  @override
  _CategoryButtonState createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  Category? _selectedCategory;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _overlayEntry?.remove(); // Clean up overlay
    super.dispose();
  }

  // Function to create the overlay
  void _showOverlay(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        left: offset.dx,
        top: offset.dy - 230, // Place the overlay above the button
        child: Material(
          elevation: 4.0,
          child: Container(
            height: 150, // Set height of the dropdown
            color: Colors.grey.shade700.withOpacity(0.7),
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: Provider.of<CategoryProvider>(context)
                    .categories
                    .map((category) {
                  return ListTile(
                    leading: Container(
                     
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: category.color, // Show category color
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(category.name),
                    onTap: () {
                      _selectCategory(category);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
  }

  // Function to hide the overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Function to handle category selection
  void _selectCategory(Category category) {
    setState(() {
      _selectedCategory = category;
    });
    widget.onCategorySelected(category);
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          if (_overlayEntry == null) {
            _showOverlay(context);
          } else {
            _hideOverlay();
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _selectedCategory?.color ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10),
              Text(
                _selectedCategory?.name ?? 'Select Category',
                style: TextStyle(fontSize: 16),
              ),
              Spacer(),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}