import 'package:intl/intl.dart';

import 'constants.dart';
import 'l10n.dart';

/// Wraps a Latin/numeric/symbol token inside Unicode directional isolates
/// (LRI…PDI) so its order never flips when embedded in an RTL sentence.
///
/// Without this, mixed text like "ج.م 7,141.72" renders scrambled in Arabic
/// contexts — dashes jump, currency codes reorder, and numbers flip direction.
///
/// Usage:
///   Text('${wrapBidiIsolate('USD')} ${wrapBidiIsolate('1,234.56')} ج.م')
String wrapBidiIsolate(String token) => '\u2066$token\u2069';

/// Formats a monetary amount with the correct symbol and locale-aware digits.
///
/// Digits always lead, symbol trails — natural reading order in both LTR and RTL.
/// The numeric part is wrapped in directional isolates for bidi safety.
///
/// Examples:
///   formatMoney(7141.72, 'EGP') → '7,141.72 ج.م'
///   formatMoney(4166.1,  'USD') → '4,166.10 $'
String formatMoney(double value, String currencyCode, {int decimals = 2}) {
  final symbol = AppConstants.currencySymbol(currencyCode);
  final absValue = value.abs();
  final formatter = NumberFormat.decimalPattern('en')
    ..minimumFractionDigits =
        absValue < 100 ? 3 : (decimals <= 2 ? 2 : decimals)
    ..maximumFractionDigits = absValue < 100 ? 3 : decimals;
  return '${wrapBidiIsolate(formatter.format(value))} $symbol';
}

/// Formats a [DateTime] as an ISO-8601 date string: 'YYYY-MM-DD'.
String formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// Formats a [DateTime] as a localized human-readable relative time (e.g., 'just now', '5m ago').
String formatRelativeTime(DateTime timestamp, AppLocalizations l10n) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return '${diff.inMinutes}${l10n.minutesAgo}';
  if (diff.inHours < 24) return '${diff.inHours}${l10n.hoursAgo}';
  return '${diff.inDays}${l10n.daysAgo}';
}
