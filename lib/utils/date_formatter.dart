import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y - hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatDay(DateTime date) {
    return DateFormat('EEE, MMM d').format(date);
  }

  static String formatSimpleDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
