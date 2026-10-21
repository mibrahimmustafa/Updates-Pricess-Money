import '../../../../core/constants.dart';

/// USD-based FX rates for the full currency pool, sourced from Frankfurter.
class ExchangeRates {
  const ExchangeRates({
    Map<String, double>? ratesFromUsd,
    Map<String, double>? usdRates,
    required this.date,
  }) : ratesFromUsd = ratesFromUsd ?? usdRates ?? const {};

  final Map<String, double> ratesFromUsd;
  final DateTime date;

  Map<String, double> get usdRates => ratesFromUsd;

  double get usdToSarRate => getRate(AppConstants.sar);
  double get usdToSar => usdToSarRate;

  double get usdToEgpRate => getRate(AppConstants.egp);
  double get usdToEgp => usdToEgpRate;

  double getRate(String currencyCode) => ratesFromUsd[currencyCode] ?? 1.0;
  double usdTo(String currencyCode) => getRate(currencyCode);

  double convertFromUsd(double usdAmount, String targetCurrencyCode) =>
      usdAmount * getRate(targetCurrencyCode);

  double convert(
          double amount, String fromCurrencyCode, String toCurrencyCode) =>
      amount / getRate(fromCurrencyCode) * getRate(toCurrencyCode);

  Map<String, dynamic> toJson() => {
        'rates': ratesFromUsd,
        'date': date.toIso8601String(),
      };

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      ratesFromUsd: (json['rates'] as Map)
          .cast<String, dynamic>()
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
