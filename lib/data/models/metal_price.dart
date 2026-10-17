import '../../core/constants.dart';

/// A metal price returned by gold-api.com.
/// Example: {"currency":"USD","currencySymbol":"$","exchangeRate":1.0,
///           "name":"Gold","price":4166.10,"symbol":"XAU",
///           "updatedAt":"2026-10-17T18:56:43Z","updatedAtReadable":"..."}
class MetalPrice {
  const MetalPrice({
    required this.symbol,
    required this.name,
    required this.price,
    required this.currency,
    required this.updatedAt,
  });

  final String symbol; // XAU, XAG
  final String name; // Gold, Silver
  final double price; // price per troy ounce in [currency]
  final String currency;
  final DateTime updatedAt;

  /// Price per gram in the same currency.
  double get pricePerGram => price / AppConstants.gramsPerTroyOunce;

  factory MetalPrice.fromJson(Map<String, dynamic> json) {
    return MetalPrice(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? AppConstants.usd,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'price': price,
        'currency': currency,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
