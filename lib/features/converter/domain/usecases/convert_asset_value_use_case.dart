import '../../../../core/constants.dart';
import '../../../prices/data/repositories/price_repository.dart';
import '../models/currency_conversion_result.dart';

/// Pure domain use case for multi-currency asset conversion.
class ConvertAssetValueUseCase {
  const ConvertAssetValueUseCase();

  List<CurrencyConversionResult> execute({
    required String assetCode,
    required double amount,
    required double karatPurityFactor,
    required MarketSnapshot snapshot,
    required List<String> targetCurrencyCodes,
  }) {
    final isMetal = AppConstants.metalPool.containsKey(assetCode);

    if (isMetal) {
      final metal = assetCode == AppConstants.goldSymbol
          ? snapshot.gold
          : (assetCode == AppConstants.silverSymbol
              ? snapshot.silver
              : snapshot.findMetal(assetCode));
      final pricePerGram = metal?.pricePerGram ?? 0.0;
      final totalUsd = pricePerGram * karatPurityFactor * amount;

      return [
        for (final currency in targetCurrencyCodes)
          CurrencyConversionResult(
            currencyCode: currency,
            convertedValue: snapshot.rates.convertFromUsd(totalUsd, currency),
          ),
      ];
    } else {
      // Currency to currencies
      final totalUsd =
          snapshot.rates.convert(amount, assetCode, AppConstants.usd);
      return [
        for (final currency in targetCurrencyCodes)
          if (currency != assetCode)
            CurrencyConversionResult(
              currencyCode: currency,
              convertedValue: snapshot.rates.convertFromUsd(totalUsd, currency),
            ),
      ];
    }
  }
}
