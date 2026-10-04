import 'package:intl/intl.dart';

final _kes = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);

/// Format integer shillings as KES currency string (e.g. 3300 -> 'KES 3,300').
String formatKes(int amount) => _kes.format(amount);
