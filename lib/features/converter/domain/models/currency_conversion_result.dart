/// Represents the result of converting an asset value into a specific quote currency.
class CurrencyConversionResult {
  const CurrencyConversionResult({
    required this.currencyCode,
    required this.convertedValue,
  });

  /// Target currency code (e.g., "USD", "EUR", "EGP").
  final String currencyCode;

  /// Calculated monetary value in the target currency.
  final double convertedValue;
}
