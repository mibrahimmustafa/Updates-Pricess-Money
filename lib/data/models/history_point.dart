import '../../core/constants.dart';

/// A single historical data point for a metal's per-gram price curve.
class HistoryPoint {
  const HistoryPoint({
    required this.date,
    required this.perOunce,
    this.quote,
  });

  final DateTime date;

  /// Quote currency of [perOunce] (XAU→XAG rows give quote currency of rate).
  final String? quote;

  /// Price per troy ounce in the quote currency.
  final double perOunce;

  /// Convenience: price per gram in the quote currency.
  double get perGram => perOunce / AppConstants.gramsPerTroyOunce;

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: DateTime.parse(json['date'] as String),
      perOunce: (json['rate'] as num).toDouble(),
      quote: json['quote'] as String?,
    );
  }
}
