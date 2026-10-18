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
    'XPD': 'Palladium',
    'HG': 'Copper',
    'BTC': 'Bitcoin',
    'ETH': 'Ethereum',
  };

  /// Metals whose per-gram price makes sense (precious metals + copper).
  static const gramMetals = {'XAU', 'XAG', 'XPT', 'XPD', 'HG'};

  /// Curated global currency pool (Frankfurter supports all of these).
  static const Set<String> currencyCodes = {
    // majors
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'NZD', 'CNY',
    'SGD', 'HKD', 'KRW', 'INR', 'PKR', 'IDR', 'MYR', 'THB', 'TWD',
    'TRY', 'RUB', 'BRL', 'MXN', 'ZAR', 'NGN', 'PLN', 'SEK', 'NOK',
    'DKK', 'CZK', 'HUF', 'RON', 'ILS', 'RSD', 'UAH', 'BGN',
    // GCC & MENA
    'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR', 'EGP', 'JOD',
    'IQD', 'LBP', 'YER', 'MAD', 'DZD', 'TND', 'LYD', 'SDG',
  };

  /// Currency symbols for display (falls back to the code itself).
  static const _symbols = <String, String>{
    'USD': r'$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CNY': '¥',
    'CAD': 'C\$', 'AUD': 'A\$', 'NZD': 'NZ\$', 'SGD': 'S\$',
    'HKD': 'HK\$', 'KRW': '₩', 'INR': '₹', 'PKR': '₨', 'IDR': 'Rp',
    'MYR': 'RM', 'THB': '฿', 'TWD': 'NT\$', 'TRY': '₺', 'RUB': '₽',
    'BRL': 'R\$', 'MXN': 'Mex\$', 'ZAR': 'R', 'NGN': '₦',
    'PLN': 'zł', 'SEK': 'kr', 'NOK': 'kr', 'DKK': 'kr', 'CZK': 'Kč',
    'HUF': 'Ft', 'RON': 'lei', 'ILS': '₪', 'UAH': '₴', 'BGN': 'лв',
    'SAR': 'ر.س', 'AED': 'د.إ', 'EGP': 'ج.م', 'QAR': 'ر.ق',
    'KWD': 'د.ك', 'BHD': 'د.ب', 'OMR': 'ر.ع', 'JOD': 'د.أ',
    'IQD': 'ع.د', 'LBP': 'ل.ل', 'YER': 'ر.ي', 'MAD': 'د.م',
    'DZD': 'د.ج', 'TND': 'د.ت', 'LYD': 'د.ل', 'SDG': 'ج.س',
  };

  static String currencySymbol(String code) => _symbols[code] ?? code;

  /// Flag emoji for an ISO currency code (EUR→🇪🇺, USD→🇺🇸 …).
  static String currencyFlag(String code) {
    if (code == 'EUR') return '🇪🇺';
    if (code == 'XAU' || code == 'XAG' || code == 'XPT' || code == 'XPD') {
      return '🥇';
    }
    if (code == 'BTC') return '₿';
    if (code == 'ETH') return 'Ξ';
    if (code == 'HG') return '🔩';
    final upper = code.toUpperCase();
    final first = String.fromCharCode(0x1F1E6 + upper.codeUnitAt(0) - 65);
    final second = String.fromCharCode(0x1F1E6 + upper.codeUnitAt(1) - 65);
    return '$first$second';
  }

  /// Currencies shown out of the box.
  static const defaultVisibleCurrencies = {usd, sar, egp};

  /// Quick-select grouping presets (Settings).
  static const gccCurrencies = {'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR'};
  static const menaCurrencies = {
    'EGP', 'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD',
    'IQD', 'LBP', 'YER', 'MAD', 'DZD', 'TND', 'LYD', 'SDG',
  };

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
}
