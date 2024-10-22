import 'package:flutter/material.dart';
import 'package:namer_app/screens/category_screen.dart';

class TodoAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme
    return AppBar(
      backgroundColor: theme.colorScheme.secondary,
      title: Text('Todo List',style: TextStyle(color: theme.colorScheme.onSurface),),
      actions: [
        IconButton(
          icon: Icon(Icons.category),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryScreen()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
