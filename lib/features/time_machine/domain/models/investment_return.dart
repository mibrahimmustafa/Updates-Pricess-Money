/// Immutable result of a historical gold investment return calculation.
///
/// Compares the cost of buying [weightGrams] of gold in [selectedYear]
/// with its value today, expressed in [quoteCurrencyCode].
class InvestmentReturn {
  const InvestmentReturn({
    required this.historicalTotalCost,
    required this.currentPortfolioValue,
    required this.growthMultiplier,
    required this.percentageGain,
    required this.weightGrams,
    required this.selectedYear,
    required this.quoteCurrencyCode,
  });

  /// Total cost of the gold at the historical price (what was paid).
  final double historicalTotalCost;

  /// Current market value of the same gold holdings today.
  final double currentPortfolioValue;

  /// Ratio of current value to historical cost (e.g., 3.2× means 3.2x growth).
  final double growthMultiplier;

  /// Percentage gain/loss since purchase (e.g., 220.0 means +220%).
  final double percentageGain;

  /// Gold weight in grams (21K karat used for Egyptian market calculations).
  final double weightGrams;

  /// The year of the hypothetical purchase.
  final int selectedYear;

  /// ISO-4217 currency code for all monetary amounts.
  final String quoteCurrencyCode;

  /// True when the investment has grown in value.
  bool get isPositiveReturn => currentPortfolioValue >= historicalTotalCost;

  /// Formats the growth as a human-readable multiplier string (e.g., "3.20×").
  String get formattedMultiplier =>
      growthMultiplier > 0 ? '${growthMultiplier.toStringAsFixed(2)}×' : '—';

  /// Formats the gain as a percentage string with sign (e.g., "+220%").
  String get formattedPercentageGain {
    if (growthMultiplier <= 0) return '—';
    final sign = percentageGain >= 0 ? '+' : '';
    return '$sign${percentageGain.toStringAsFixed(0)}%';
  }
}
