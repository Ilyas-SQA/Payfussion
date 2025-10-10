import 'package:intl/intl.dart';

class DatesUtils{

  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh : mm a');
    return formatter.format(date);
  }
}