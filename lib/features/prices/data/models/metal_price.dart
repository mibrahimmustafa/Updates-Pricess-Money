import '../../../../core/constants.dart';

/// A single metal spot price, sourced from gold-api.com.
class MetalPrice {
  const MetalPrice({
    required this.symbol,
    required this.name,
    required this.price,
    required this.currency,
    required this.updatedAt,
  });

  final String symbol;
  final String name;
  final double price;
  final String currency;
  final DateTime updatedAt;

  /// Spot price per gram in [currency].
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
