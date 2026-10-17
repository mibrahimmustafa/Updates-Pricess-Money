/// Minimal bilingual string table (English / Arabic). MaterialApp uses
/// `flutter_localizations` delegates for Material widgets, and this class
/// provides app copy.
class AppL10n {
  const AppL10n(this.langCode);

  final String langCode;

  static const Map<String, String> _en = {
    'title': 'Pricess Money',
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
  };

  static const Map<String, String> _ar = {
    'title': 'بريسيس موني',
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
  };

  String t(String key) {
    final table = langCode == 'ar' ? _ar : _en;
    return table[key] ?? _en[key] ?? key;
  }
}
