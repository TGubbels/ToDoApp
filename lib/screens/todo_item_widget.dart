import 'package:flutter/material.dart';
import '../main.dart'; // Import the Todo class

class TodoItemWidget extends StatelessWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final ValueChanged<bool?> onToggleComplete;

  TodoItemWidget({
    required this.todo,
    required this.onEdit,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.colorScheme.surface, // Use surface color from the theme
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: onToggleComplete,
          activeColor: theme.colorScheme.primary, // Use primary color for the checkbox
          checkColor: theme.colorScheme.onPrimary, // Use color for the checkmark
          side: BorderSide(
            width: 2.0,
            color: theme.colorScheme.onSurface, // Use onSurface color for contrast
          ),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: theme.colorScheme.onSurface, // Ensure text is readable
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                todo.category.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: todo.category.color, // Set the category name color
                ),
              ),
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }
}
