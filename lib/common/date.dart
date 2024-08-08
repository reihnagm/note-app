import 'package:intl/intl.dart';

class DateHelper {

  static String dateNameMonth(DateTime date) {
    return DateFormat.yMMMMd('id_ID').format(date.toLocal());
  }

  static String dateWithTime(DateTime date) {
    final f = DateFormat('yyyy-MM-dd hh:mm');
    return f.format(date);
  }

  static String createEventDate(DateTime date) {
    return DateFormat('yyyy-MM-d').format(date.toLocal());
  }

  static String createEventTime(DateTime data) {
    return DateFormat('HH:mm').format(data.toLocal());
  }

  static String dateNameTime(DateTime date) {
    return DateFormat.yMMMd('id_ID').add_jm().format(date.toLocal());
  }

}
