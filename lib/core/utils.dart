import 'package:intl/intl.dart';

import 'constants.dart';

/// Formats an amount with the right symbol and readable digits.
/// Example: formatMoney(7141.724, 'EGP') -> 'ج.م 7,141.72'
String formatMoney(double value, String currency, {int decimals = 2}) {
  final symbol = AppConstants.currencySymbol(currency);
  final abs = value.abs();
  final fmt = NumberFormat.decimalPattern('en')
    ..minimumFractionDigits = abs < 100 ? 3 : (decimals <= 2 ? 2 : decimals)
    ..maximumFractionDigits = abs < 100 ? 3 : decimals;
  return '$symbol ${fmt.format(value)}';
}

/// Formats a DateTime as '2026-10-17'.
String formatDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}
