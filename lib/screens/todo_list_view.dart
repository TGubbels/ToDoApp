import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'todo_item_widget.dart';
import '../main.dart'; // Import the Todo class
 // Import the TodoProvider

class TodoListView extends StatelessWidget {
  final Map<String, List<Todo>> Function(DateTime) groupTodosByDay;
  final int daysToLoad;
  final void Function() onLoadMoreDays;
  final void Function(int index, bool? value) toggleTodoCompletion;
  final void Function(int index) editTodo;
  final void Function(int index) removeTodoAt;

  TodoListView({
    required this.groupTodosByDay,
    required this.daysToLoad,
    required this.onLoadMoreDays,
    required this.toggleTodoCompletion,
    required this.editTodo,
    required this.removeTodoAt,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!scrollInfo.metrics.atEdge && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMoreDays(); // Load more days
        }
        return false;
      },
      child: ListView.builder(
        itemCount: daysToLoad,
        itemBuilder: (context, index) {
          DateTime day = DateTime.now().add(Duration(days: index));
          Map<String, List<Todo>> groupedTodos = groupTodosByDay(day);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Text(
                  DateFormat('EEEE, MMM dd').format(day),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Divider(height: 1),
              ...groupedTodos.entries.map((entry) {
                List<Todo> todosForDay = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...todosForDay.map((todo) {
                      return TodoItemWidget(
                        todo: todo,
                        onEdit: () => editTodo(todosForDay.indexOf(todo)), // Use the correct index for editing
                        onToggleComplete: (value) => toggleTodoCompletion(todosForDay.indexOf(todo), value),
                      );
                    }).toList(),
                    Divider(height: 1),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
