import '../../../../core/constants.dart';

/// Backward compatibility alias.
typedef HistoryPoint = HistoricalDataPoint;

/// A single historical data point returned by the Frankfurter API.
class HistoricalDataPoint {
  const HistoricalDataPoint({
    required this.date,
    required this.valuePerUnit,
    this.quoteCurrencyCode,
  });

  final DateTime date;

  /// The raw value returned by the API for this data point.
  final double valuePerUnit;

  /// ISO-4217 quote currency code, or null when not applicable.
  final String? quoteCurrencyCode;

  /// Price per gram in [quoteCurrencyCode].
  double get valuePerGram => valuePerUnit / AppConstants.gramsPerTroyOunce;

  /// Backward-compatibility getters
  double get perOunce => valuePerUnit;
  double get perGram => valuePerGram;
  String? get quote => quoteCurrencyCode;

  factory HistoricalDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalDataPoint(
      date: DateTime.parse(json['date'] as String),
      valuePerUnit: (json['rate'] as num).toDouble(),
      quoteCurrencyCode: json['quote'] as String?,
    );
  }
}
