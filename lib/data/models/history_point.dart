import '../../core/constants.dart';

/// A single historical data point for a metal's per-gram price curve.
class HistoryPoint {
  const HistoryPoint({required this.date, required this.perOunce});

  /// Rate quote date (weekend days are skipped by the source).
  final DateTime date;

  /// Price per troy ounce in the quote currency.
  final double perOunce;

  /// Convenience: price per gram in the quote currency.
  double get perGram => perOunce / AppConstants.gramsPerTroyOunce;

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: DateTime.parse(json['date'] as String),
      perOunce: (json['rate'] as num).toDouble(),
    );
  }
}
