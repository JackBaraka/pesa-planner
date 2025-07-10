import 'package:intl/intl.dart';

String formatKSH(double amount) {
  return NumberFormat.currency(
    locale: 'sw_KE',
    symbol: 'KSh ',
    decimalDigits: 2,
  ).format(amount);
}
