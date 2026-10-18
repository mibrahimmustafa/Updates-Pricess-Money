import '../../core/constants.dart';

/// USD-based FX rates for the whole currency pool (from Frankfurter).
class ExchangeRates {
  const ExchangeRates({required this.usdRates, required this.date});

  /// Map of quote currency code → "USD buys X of quote".
  final Map<String, double> usdRates;
  final DateTime date;

  double usdTo(String code) => usdRates[code] ?? 1.0;

  double get usdToSar => usdTo(AppConstants.sar);
  double get usdToEgp => usdTo(AppConstants.egp);

  double convertFromUsd(double usdAmount, String target) =>
      usdAmount * usdTo(target);

  /// Converts between any two pool currencies through USD.
  double convert(double amount, String from, String to) =>
      amount / usdTo(from) * usdTo(to);

  Map<String, dynamic> toJson() => {
        'rates': usdRates,
        'date': date.toIso8601String(),
      };

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      usdRates: (json['rates'] as Map)
          .cast<String, dynamic>()
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
