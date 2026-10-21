import '../models/jewelry_cost_breakdown.dart';

/// Pure domain use case for calculating jewelry purchase cost and trade-in breakdown.
class CalculateJewelryCostUseCase {
  const CalculateJewelryCostUseCase();

  JewelryCostBreakdown execute({
    required double newWeightGrams,
    required double karatPurityFactor,
    required double pureGramPriceInQuoteCurrency,
    required double manufacturingFeePerGram,
    required double vatRate,
    required bool includeVat,
    required double tradeInWeightGrams,
    required double tradeInKaratPurityFactor,
    required String quoteCurrencyCode,
  }) {
    final effectiveKaratGramPrice =
        pureGramPriceInQuoteCurrency * karatPurityFactor;
    final metalMaterialCost = effectiveKaratGramPrice * newWeightGrams;
    final totalManufacturingFee = manufacturingFeePerGram * newWeightGrams;
    final effectiveVatMultiplier = includeVat ? vatRate : 0.0;
    final vatAmount =
        (metalMaterialCost + totalManufacturingFee) * effectiveVatMultiplier;
    final grossTotalCost = metalMaterialCost + totalManufacturingFee + vatAmount;

    final effectiveTradeInGramPrice =
        pureGramPriceInQuoteCurrency * tradeInKaratPurityFactor;
    final tradeInCreditAmount =
        effectiveTradeInGramPrice * tradeInWeightGrams;
    final netPayableAmount = grossTotalCost - tradeInCreditAmount;

    return JewelryCostBreakdown(
      metalMaterialCost: metalMaterialCost,
      totalManufacturingFee: totalManufacturingFee,
      vatAmount: vatAmount,
      grossTotalCost: grossTotalCost,
      tradeInCreditAmount: tradeInCreditAmount,
      netPayableAmount: netPayableAmount,
      quoteCurrencyCode: quoteCurrencyCode,
    );
  }
}
