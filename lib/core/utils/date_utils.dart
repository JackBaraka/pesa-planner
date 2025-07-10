import 'package:intl/intl.dart';

String formatKenyanDate(DateTime date) {
  return DateFormat('dd MMM yyyy', 'en_KE').format(date);
}
