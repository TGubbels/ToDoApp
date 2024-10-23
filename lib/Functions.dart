// Function to determine how to display the due date
  import 'package:intl/intl.dart';

  class utils{
    static String formatDueDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(Duration(days: 1));

    // Compare only the date part (year, month, day)
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    } else if (date.isAfter(today) &&
        date.isBefore(tomorrow.add(Duration(days: 7)))) {
      return DateFormat('EEEE').format(date); // Day of the week
    } else {
      return DateFormat('dd MMM').format(date); // e.g., "30 Okt."
    }
  }

  }


