/// Immutable result of a jewelry purchase cost calculation.
///
/// Contains an itemized breakdown of all cost components, including
/// optional VAT and old-gold (moyaval/kasr) trade-in credit.
class JewelryCostBreakdown {
  const JewelryCostBreakdown({
    required this.metalMaterialCost,
    required this.totalManufacturingFee,
    required this.vatAmount,
    required this.grossTotalCost,
    required this.tradeInCreditAmount,
    required this.netPayableAmount,
    required this.quoteCurrencyCode,
  });

  /// Cost of the raw metal based on weight, karat, and live gram price.
  final double metalMaterialCost;

  /// Total craftsmanship / manufacturing fee (fee per gram × weight).
  final double totalManufacturingFee;

  /// Egyptian VAT applied on (metal cost + manufacturing fee).
  /// Zero when VAT is disabled.
  final double vatAmount;

  /// Subtotal before deducting old-gold trade-in credit.
  final double grossTotalCost;

  /// Credit the buyer receives for trading in old gold (moyaval/kasr at spot).
  /// Zero when no old gold is provided.
  final double tradeInCreditAmount;

  /// Final amount the buyer must pay after all deductions.
  final double netPayableAmount;

  /// ISO-4217 currency code for all monetary amounts in this breakdown.
  final String quoteCurrencyCode;
}
