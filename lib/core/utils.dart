import 'package:intl/intl.dart';

import 'constants.dart';

/// Wraps a Latin/numeric/symbol token inside Unicode directional isolates
/// (LRI…PDI) so its order never flips when embedded in an RTL sentence.
/// Without this, "ج.م 7,141.72" renders scrambled ("7,141.72 ج.م" misplaced,
/// dashes jumping, codes reordering) in Arabic text.
String iso(String token) => '\u2066$token\u2069';

/// Formats an amount with the right symbol and readable digits.
/// Digits lead, then the symbol — natural in both LTR and RTL:
///   formatMoney(7141.72, 'EGP') -> '7,141.72 ج.م'
///   formatMoney(4166.1, 'USD')  -> '4,166.10 $'
/// The number is wrapped in directional isolates so it never reorders
/// when concatenated with Arabic text.
String formatMoney(double value, String currency, {int decimals = 2}) {
  final symbol = AppConstants.currencySymbol(currency);
  final abs = value.abs();
  final fmt = NumberFormat.decimalPattern('en')
    ..minimumFractionDigits = abs < 100 ? 3 : (decimals <= 2 ? 2 : decimals)
    ..maximumFractionDigits = abs < 100 ? 3 : decimals;
  return '${iso(fmt.format(value))} $symbol';
}

/// Formats a DateTime as '2026-10-17'.
String formatDate(DateTime d) {
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}
