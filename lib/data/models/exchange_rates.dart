import '../../core/constants.dart';

/// Result of fetching USD-based FX rates from Frankfurter.
class ExchangeRates {
  const ExchangeRates({
    required this.usdToSar,
    required this.usdToEgp,
    required this.date,
  });

  final double usdToSar;
  final double usdToEgp;

  /// Snapshot date reported by the API (FX updates daily).
  final DateTime date;

  double convertFromUsd(double usdAmount, String target) {
    switch (target) {
      case AppConstants.sar:
        return usdAmount * usdToSar;
      case AppConstants.egp:
        return usdAmount * usdToEgp;
      default:
        return usdAmount;
    }
  }
}
