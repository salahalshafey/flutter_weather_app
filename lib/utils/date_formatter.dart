import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFullDateTime(DateTime date) {
    return DateFormat('EEEE, MMMM d, y - hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDay(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }
}
