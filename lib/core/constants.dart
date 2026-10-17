/// App-wide constants: API endpoints, symbols, currencies, conversions.
class AppConstants {
  AppConstants._();

  // --- APIs ---
  static const goldApiBase = 'https://api.gold-api.com';
  static const frankfurterBase = 'https://api.frankfurter.dev/v2';

  /// gold-api asks consumers to cache for ~30s. We poll every 30s.
  static const pollInterval = Duration(seconds: 30);
  static const cacheKey = 'price_snapshot_v1';

  // --- Metals (gold-api symbols) ---
  static const goldSymbol = 'XAU';
  static const silverSymbol = 'XAG';

  // --- Display currencies ---
  static const usd = 'USD';
  static const sar = 'SAR';
  static const egp = 'EGP';

  // --- Conversion ---
  /// 1 troy ounce = 31.1034768 grams
  static const gramsPerTroyOunce = 31.1034768;

  /// Gold purity by karat.
  static const karats = <String, double>{
    '24K': 1.0,
    '22K': 0.9167,
    '21K': 0.875,
    '18K': 0.75,
  };

  /// Currency symbols for display.
  static const currencySymbols = <String, String>{
    usd: r'$', sar: 'ر.س', egp: 'ج.م',
  };
}
