import '../models/investment_return.dart';

/// Pure domain use case for calculating historical gold investment returns.
class CalculateInvestmentReturnUseCase {
  const CalculateInvestmentReturnUseCase();

  InvestmentReturn execute({
    required double historicalPricePerGram,
    required double currentPricePerGram,
    required double weightGrams,
    required int selectedYear,
    required String quoteCurrencyCode,
  }) {
    final historicalTotalCost = historicalPricePerGram * weightGrams;
    final currentPortfolioValue = currentPricePerGram * weightGrams;

    final growthMultiplier = historicalPricePerGram > 0
        ? currentPricePerGram / historicalPricePerGram
        : 0.0;

    final percentageGain = historicalTotalCost > 0
        ? ((currentPortfolioValue - historicalTotalCost) / historicalTotalCost) * 100.0
        : 0.0;

    return InvestmentReturn(
      historicalTotalCost: historicalTotalCost,
      currentPortfolioValue: currentPortfolioValue,
      growthMultiplier: growthMultiplier,
      percentageGain: percentageGain,
      weightGrams: weightGrams,
      selectedYear: selectedYear,
      quoteCurrencyCode: quoteCurrencyCode,
    );
  }
}
