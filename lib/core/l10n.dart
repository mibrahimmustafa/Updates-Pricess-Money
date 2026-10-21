/// Minimal bilingual string table (English / Arabic).
///
/// [MaterialApp] uses `flutter_localizations` delegates for Material widgets.
/// This class provides all application-specific copy with compile-time typed
/// getters to eliminate magic-string lookup errors at call sites.
///
/// Usage:
///   final l10n = AppLocalizations(languageCode);
///   Text(l10n.title)
///   Text(l10n.translate('custom_key'))  // fallback for dynamic keys
class AppLocalizations {
  const AppLocalizations(this.languageCode);

  final String languageCode;

  // ─── Private string tables ────────────────────────────────────────────────

  static const Map<String, String> _en = {
    'title': 'Dahab Live',
    'tagline': 'Gold, Currency & Banks',
    'tagline_full': 'Dahab Live – Gold, Currency & Banks',
    'tab_prices': 'Prices',
    'tab_converter': 'Converter',
    'tab_chart': 'Chart',
    'gold': 'Gold',
    'silver': 'Silver',
    'per_oz': 'per oz',
    'gram': 'Gram',
    'karat': 'Karat',
    'updated': 'Updated',
    'just_now': 'just now',
    'minutes_ago': 'm ago',
    'hours_ago': 'h ago',
    'days_ago': 'd ago',
    'error_network': 'Network error — showing last updated prices',
    'loading': 'Loading prices…',
    'pull_refresh': 'Pull down to refresh',
    'weight_grams': 'Weight (grams)',
    'result': 'Result',
    'metal': 'Metal',
    'currency': 'Currency',
    'range': 'Range',
    'range_7d': '7 days',
    'range_30d': '30 days',
    'range_90d': '90 days',
    'price_per_gram': 'Price per gram',
    'enter_weight': 'Enter weight in grams',
    'metal_rates_note': 'Live metal prices vs USD, SAR and EGP',
    'live': 'LIVE',
    'retry': 'Retry',
    // Navigation & more menu
    'tab_more': 'More',
    'tab_jewelry': 'Jewelry',
    'more_title': 'More',
    'asset': 'Asset',
    'amount': 'Amount',
    'convert_from': 'Convert',
    // Jewelry calculator
    'calc_title': 'Jewelry calculator',
    'mfg_fee_per_gram': 'Manufacturing (per gram)',
    'vat_label': 'VAT (14%)',
    'metal_value': 'Metal value',
    'mfg_total': 'Total manufacturing',
    'vat_total': 'VAT',
    'total_cost': 'Total cost',
    'old_gold_weight': 'Old gold weight (grams)',
    'old_gold_note': 'Old-gold karat',
    'metals_mode': 'Metals',
    'currency_mode': 'Currencies',
    'old_gold_section': 'Trade-in old gold (scrap / exchange)',
    'old_gold_credit': 'Credit for old gold',
    'net_payable': 'Net payable',
    // Alerts
    'alerts_title': 'Alerts',
    'add_alert': 'New alert',
    'alert_when': 'Alert when price goes',
    'above': 'above',
    'below': 'below',
    'target_price': 'Target price (per gram)',
    'no_alerts': 'No alerts yet — add one to get notified',
    'alert_active': 'On',
    'alert_fired': 'Fired',
    // Banks
    'banks_title': 'CBE official rates',
    'official': 'Official (CBE)',
    'market': 'Market (blend)',
    'updated_date': 'Source date',
    // Time machine
    'timemachine_title': 'Value over time',
    'then_price': 'Price back then',
    'now_price': 'Today',
    'change': 'Change',
    'select_year': 'Year',
    'since': 'Value of your grams in',
    // Settings
    'settings_title': 'Settings',
    'default_currency': 'Default currency',
    'language': 'Language',
    'choose_currencies': 'Currencies shown',
    'choose_assets': 'Assets shown',
    'preset_gcc': 'GCC',
    'preset_mena': 'MENA',
    'preset_default': 'Reset',
    'theme': 'Theme',
    'theme_system': 'System',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
  };

  static const Map<String, String> _ar = {
    'title': 'ذهب لايف',
    'tagline': 'الذهب والعملات والبنوك',
    'tagline_full': 'دهب لايف – الذهب والعملات والبنوك',
    'tab_prices': 'الأسعار',
    'tab_converter': 'الحاسبة',
    'tab_chart': 'الرسم',
    'gold': 'ذهب',
    'silver': 'فضة',
    'per_oz': 'للأونصة',
    'gram': 'جرام',
    'karat': 'العيار',
    'updated': 'آخر تحديث',
    'just_now': 'الآن',
    'minutes_ago': 'د مضت',
    'hours_ago': 'س مضت',
    'days_ago': 'يوم مضت',
    'error_network': 'خطأ في الشبكة — يتم عرض آخر أسعار محفوظة',
    'loading': 'جارٍ تحميل الأسعار…',
    'pull_refresh': 'اسحب للأسفل للتحديث',
    'weight_grams': 'الوزن (جرام)',
    'result': 'النتيجة',
    'metal': 'المعدن',
    'currency': 'العملة',
    'range': 'المدة',
    'range_7d': '٧ أيام',
    'range_30d': '٣٠ يوم',
    'range_90d': '٩٠ يوم',
    'price_per_gram': 'سعر الجرام',
    'enter_weight': 'أدخل الوزن بالجرام',
    'metal_rates_note': 'أسعار المعادن مباشرة بالدولار والريال والجنيه',
    'live': 'مباشر',
    'retry': 'إعادة المحاولة',
    'tab_more': 'المزيد',
    'tab_jewelry': 'المجوهرات',
    'more_title': 'المزيد',
    'asset': 'الأصل',
    'amount': 'المبلغ',
    'convert_from': 'تحويل',
    'calc_title': 'حاسبة المجوهرات',
    'mfg_fee_per_gram': 'المصنعية (للجرام)',
    'vat_label': 'ضريبة القيمة المضافة (١٤٪)',
    'metal_value': 'قيمة المعدن',
    'mfg_total': 'إجمالي المصنعية',
    'vat_total': 'الضريبة',
    'total_cost': 'التكلفة الإجمالية',
    'old_gold_weight': 'وزن الكسر (جرام)',
    'old_gold_note': 'عيار الكسر',
    'old_gold_section': 'الكسر (مجوهرات قديمة للاستبدال)',
    'metals_mode': 'المعادن',
    'currency_mode': 'العملات',
    'old_gold_credit': 'صافي قيمة الكسر',
    'net_payable': 'المطلوب دفعه',
    'alerts_title': 'التنبيهات',
    'add_alert': 'تنبيه جديد',
    'alert_when': 'التنبيه عندما يصبح السعر',
    'above': 'فوق',
    'below': 'تحت',
    'target_price': 'السعر المستهدف (للجرام)',
    'no_alerts': 'لا توجد تنبيهات — أضف تنبيه ليصلك إشعار',
    'alert_active': 'شغّال',
    'alert_fired': 'تم التنبيه',
    'banks_title': 'أسعار البنك المركزي',
    'official': 'رسمي (المركزي)',
    'market': 'السوق',
    'updated_date': 'تاريخ المصدر',
    'timemachine_title': 'قيمة الذهب عبر الزمن',
    'then_price': 'السعر وقتها',
    'now_price': 'اليوم',
    'change': 'التغير',
    'select_year': 'السنة',
    'since': 'قيمة جراماتك في',
    'settings_title': 'الإعدادات',
    'default_currency': 'العملة الافتراضية',
    'language': 'اللغة',
    'choose_currencies': 'العملات المعروضة',
    'choose_assets': 'الأصول المعروضة',
    'preset_gcc': 'الخليج',
    'preset_mena': 'الشرق الأوسط',
    'preset_default': 'استعادة الافتراضي',
    'theme': 'المظهر',
    'theme_system': 'النظام',
    'theme_light': 'فاتح',
    'theme_dark': 'داكن',
  };

  // ─── Core lookup ──────────────────────────────────────────────────────────

  /// Looks up [key] in the current language table, falling back to English.
  String translate(String key) {
    final table = languageCode == 'ar' ? _ar : _en;
    return table[key] ?? _en[key] ?? key;
  }

  /// Backward-compatible alias for [translate].
  String t(String key) => translate(key);

  /// Index operator for convenient lookup: `l10n['key']`.
  String operator [](String key) => translate(key);

  // ─── Typed getters — compile-time safe, no magic strings at call sites ────

  // General
  String get title => translate('title');
  String get tagline => translate('tagline');
  String get taglineFull => translate('tagline_full');
  String get liveLabel => translate('live');
  String get retryLabel => translate('retry');
  String get loadingLabel => translate('loading');
  String get networkError => translate('error_network');
  String get pullToRefresh => translate('pull_refresh');
  String get updatedLabel => translate('updated');
  String get justNow => translate('just_now');
  String get minutesAgo => translate('minutes_ago');
  String get hoursAgo => translate('hours_ago');
  String get daysAgo => translate('days_ago');

  // Navigation tabs
  String get tabPrices => translate('tab_prices');
  String get tabConverter => translate('tab_converter');
  String get tabChart => translate('tab_chart');
  String get tabJewelry => translate('tab_jewelry');
  String get tabMore => translate('tab_more');
  String get moreTitle => translate('more_title');
  String get settingsTitle => translate('settings_title');

  // Metals & units
  String get gold => translate('gold');
  String get silver => translate('silver');
  String get perOz => translate('per_oz');
  String get gram => translate('gram');
  String get karat => translate('karat');
  String get metalRatesNote => translate('metal_rates_note');

  // Chart
  String get range7d => translate('range_7d');
  String get range30d => translate('range_30d');
  String get range90d => translate('range_90d');
  String get pricePerGram => translate('price_per_gram');
  String get enterWeight => translate('enter_weight');
  String get metal => translate('metal');
  String get currency => translate('currency');
  String get range => translate('range');

  // Converter
  String get asset => translate('asset');
  String get amount => translate('amount');
  String get convertFrom => translate('convert_from');
  String get result => translate('result');
  String get weightGrams => translate('weight_grams');

  // Jewelry calculator
  String get calculatorTitle => translate('calc_title');
  String get manufacturingFeePerGram => translate('mfg_fee_per_gram');
  String get vatLabel => translate('vat_label');
  String get metalValue => translate('metal_value');
  String get manufacturingTotal => translate('mfg_total');
  String get vatTotal => translate('vat_total');
  String get totalCost => translate('total_cost');
  String get oldGoldWeight => translate('old_gold_weight');
  String get oldGoldKarat => translate('old_gold_note');
  String get oldGoldSection => translate('old_gold_section');
  String get oldGoldCredit => translate('old_gold_credit');
  String get netPayable => translate('net_payable');
  String get metalsMode => translate('metals_mode');
  String get currencyMode => translate('currency_mode');

  // Alerts
  String get alertsTitle => translate('alerts_title');
  String get addAlert => translate('add_alert');
  String get alertWhen => translate('alert_when');
  String get above => translate('above');
  String get below => translate('below');
  String get targetPrice => translate('target_price');
  String get noAlerts => translate('no_alerts');
  String get alertActive => translate('alert_active');
  String get alertFired => translate('alert_fired');

  // Banks / CBE
  String get banksTitle => translate('banks_title');
  String get officialRate => translate('official');
  String get marketRate => translate('market');
  String get updatedDate => translate('updated_date');

  // Time machine
  String get timeMachineTitle => translate('timemachine_title');
  String get historicalPrice => translate('then_price');
  String get currentPrice => translate('now_price');
  String get change => translate('change');
  String get selectYear => translate('select_year');
  String get since => translate('since');

  // Settings
  String get defaultCurrency => translate('default_currency');
  String get language => translate('language');
  String get chooseCurrencies => translate('choose_currencies');
  String get chooseAssets => translate('choose_assets');
  String get presetGcc => translate('preset_gcc');
  String get presetMena => translate('preset_mena');
  String get presetDefault => translate('preset_default');
  String get theme => translate('theme');
  String get themeSystem => translate('theme_system');
  String get themeLight => translate('theme_light');
  String get themeDark => translate('theme_dark');
}
