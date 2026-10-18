/// App-wide constants: API endpoints, asset pools, conversions.
class AppConstants {
  AppConstants._();

  // --- APIs ---
  static const goldApiBase = 'https://api.gold-api.com';
  static const frankfurterBase = 'https://api.frankfurter.dev/v2';

  /// gold-api asks consumers to cache for ~30s. We poll every 30s.
  static const pollInterval = Duration(seconds: 30);
  static const cacheKey = 'price_snapshot_v2';

  // --- Core currency codes ---
  static const usd = 'USD';
  static const sar = 'SAR';
  static const egp = 'EGP';

  // --- Metals (gold-api symbols) ---
  static const goldSymbol = 'XAU';
  static const silverSymbol = 'XAG';

  /// Metals shown out of the box (user can toggle more in Settings).
  static const defaultVisibleMetals = {goldSymbol, silverSymbol};

  /// Full asset pool offered to the user (gold-api symbols).
  static const metalPool = <String, String>{
    'XAU': 'Gold',
    'XAG': 'Silver',
    'XPT': 'Platinum',
    'BTC': 'Bitcoin',
  };

  /// Metals whose per-gram price makes sense (precious metals).
  static const gramMetals = {'XAU', 'XAG', 'XPT'};

  /// Full currency pool offered to the user (Frankfurter quotes).
  static const currencyPool = <String, String>{
    usd: r'$',
    sar: 'ر.س',
    egp: 'ج.م',
    'EUR': '€',
    'GBP': '£',
    'AED': 'د.إ',
    'KWD': 'د.ك',
    'QAR': 'ر.ق',
    'BHD': 'د.ب',
    'OMR': 'ر.ع',
    'JOD': 'د.أ',
    'TRY': '₺',
    'JPY': '¥',
    'CNY': '¥',
  };

  /// Currencies shown out of the box.
  static const defaultVisibleCurrencies = {usd, sar, egp};

  // --- Conversion ---
  /// 1 troy ounce = 31.1034768 grams
  static const gramsPerTroyOunce = 31.1034768;

  /// Egyptian VAT applied on gold jewellery purchases.
  static const vatRate = 0.14;

  /// Gold purity by karat.
  static const karats = <String, double>{
    '24K': 1.0,
    '22K': 0.9167,
    '21K': 0.875,
    '18K': 0.75,
  };

  /// Currency symbols for display (falls back to the code itself).
  static String currencySymbol(String code) =>
      currencyPool[code] ?? code;
}
