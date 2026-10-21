import 'package:flutter_test/flutter_test.dart';

import 'package:pricess_money/core/constants.dart';
import 'package:pricess_money/features/prices/data/models/exchange_rates.dart';
import 'package:pricess_money/features/prices/data/models/metal_price.dart';
import 'package:pricess_money/features/prices/data/repositories/price_repository.dart';
import 'package:pricess_money/features/alerts/domain/enums/alert_trigger_direction.dart';
import 'package:pricess_money/features/prices/domain/enums/metal_code.dart';
import 'package:pricess_money/features/time_machine/domain/usecases/calculate_investment_return_use_case.dart';
import 'package:pricess_money/features/jewelry_calculator/domain/usecases/calculate_jewelry_cost_use_case.dart';
import 'package:pricess_money/features/converter/domain/usecases/convert_asset_value_use_case.dart';

void main() {
  group('CalculateJewelryCostUseCase', () {
    const useCase = CalculateJewelryCostUseCase();

    test('calculates gross total and net payable with VAT and trade-in', () {
      final breakdown = useCase.execute(
        newWeightGrams: 10,
        karatPurityFactor: 0.875, // 21K
        pureGramPriceInQuoteCurrency: 5000,
        manufacturingFeePerGram: 100,
        vatRate: 0.14,
        includeVat: true,
        tradeInWeightGrams: 5,
        tradeInKaratPurityFactor: 0.875,
        quoteCurrencyCode: 'EGP',
      );

      // Effective pure gram price for 21K = 5000 * 0.875 = 4375
      // Metal cost = 4375 * 10 = 43750
      expect(breakdown.metalMaterialCost, 43750.0);

      // Manufacturing = 100 * 10 = 1000
      expect(breakdown.totalManufacturingFee, 1000.0);

      // VAT = (43750 + 1000) * 0.14 = 6265
      expect(breakdown.vatAmount, closeTo(6265.0, 0.001));

      // Gross total = 43750 + 1000 + 6265 = 51015
      expect(breakdown.grossTotalCost, closeTo(51015.0, 0.001));

      // Trade-in credit = 5 * 4375 = 21875
      expect(breakdown.tradeInCreditAmount, closeTo(21875.0, 0.001));

      // Net payable = 51015 - 21875 = 29140
      expect(breakdown.netPayableAmount, closeTo(29140.0, 0.001));
    });

    test('handles zero VAT when includeVat is false', () {
      final breakdown = useCase.execute(
        newWeightGrams: 10,
        karatPurityFactor: 1.0,
        pureGramPriceInQuoteCurrency: 5000,
        manufacturingFeePerGram: 50,
        vatRate: 0.14,
        includeVat: false,
        tradeInWeightGrams: 0,
        tradeInKaratPurityFactor: 1.0,
        quoteCurrencyCode: 'EGP',
      );

      expect(breakdown.vatAmount, 0.0);
      expect(breakdown.grossTotalCost, 50500.0);
      expect(breakdown.netPayableAmount, 50500.0);
    });
  });

  group('CalculateInvestmentReturnUseCase', () {
    const useCase = CalculateInvestmentReturnUseCase();

    test('calculates historical gain and multipliers accurately', () {
      final result = useCase.execute(
        historicalPricePerGram: 1000,
        currentPricePerGram: 4000,
        weightGrams: 20,
        selectedYear: 2018,
        quoteCurrencyCode: 'EGP',
      );

      expect(result.historicalTotalCost, 20000.0);
      expect(result.currentPortfolioValue, 80000.0);
      expect(result.growthMultiplier, 4.0);
      expect(result.percentageGain, 300.0);
      expect(result.isPositiveReturn, isTrue);
      expect(result.formattedMultiplier, '4.00×');
      expect(result.formattedPercentageGain, '+300%');
    });
  });

  group('ConvertAssetValueUseCase', () {
    const useCase = ConvertAssetValueUseCase();

    test('converts metal and currencies correctly', () {
      final rates = ExchangeRates(
        ratesFromUsd: const {'USD': 1.0, 'SAR': 3.75, 'EGP': 50.0},
        date: DateTime(2026, 1, 1),
      );
      final gold = MetalPrice(
        symbol: 'XAU',
        name: 'Gold',
        price: 3110.34768, // Exactly $100 / gram
        currency: 'USD',
        updatedAt: DateTime.now(),
      );
      final snapshot = MarketSnapshot(
        metals: {'XAU': gold},
        exchangeRates: rates,
        snapshotTimestamp: DateTime.now(),
      );

      final results = useCase.execute(
        assetCode: AppConstants.goldSymbol,
        amount: 2, // 2 grams
        karatPurityFactor: 1.0,
        snapshot: snapshot,
        targetCurrencyCodes: ['USD', 'SAR', 'EGP'],
      );

      expect(results.length, 3);
      // 2g * $100 = $200
      final usdRow = results.firstWhere((r) => r.currencyCode == 'USD');
      expect(usdRow.convertedValue, closeTo(200.0, 0.01));

      // $200 * 50 = 10,000 EGP
      final egpRow = results.firstWhere((r) => r.currencyCode == 'EGP');
      expect(egpRow.convertedValue, closeTo(10000.0, 0.01));
    });
  });

  group('Domain Enums', () {
    test('MetalCode checks precious and gram pricing support', () {
      expect(MetalCode.gold.isPreciousMetal, isTrue);
      expect(MetalCode.gold.supportsGramPricing, isTrue);
      expect(MetalCode.bitcoin.isPreciousMetal, isFalse);
      expect(MetalCode.bitcoin.supportsGramPricing, isFalse);
      expect(MetalCode.fromCode('XAU'), MetalCode.gold);
    });

    test('AlertTriggerDirection direction check', () {
      expect(
        AlertTriggerDirection.aboveTarget.isSatisfied(
          currentPrice: 105,
          target: 100,
        ),
        isTrue,
      );
      expect(
        AlertTriggerDirection.aboveTarget.isSatisfied(
          currentPrice: 95,
          target: 100,
        ),
        isFalse,
      );
      expect(
        AlertTriggerDirection.belowTarget.isSatisfied(
          currentPrice: 95,
          target: 100,
        ),
        isTrue,
      );
    });
  });
}
