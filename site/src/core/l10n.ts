// Bilingual strings — EN/AR dictionaries (~90 keys). Only `t()` touches them.
export type Lang = 'en' | 'ar';

const en: Record<string, string> = {
  title: 'Pricess Money',
  tagline: 'Live precious metal & currency rates',
  tab_prices: 'Prices', tab_jewelry: 'Jewelry', tab_converter: 'Converter',
  tab_settings: 'Settings', tab_more: 'More',
  more_title: 'More', settings_title: 'Settings',
  tab_chart: 'Chart', alerts_title: 'Alerts', calc_title: 'Jewelry calculator',
  timemachine_title: 'Value over time', banks_title: 'CBE official rates',
  live: 'LIVE', retry: 'Retry', last_update_now: 'Updated just now',
  last_update: 'Updated {x}', network_error: 'Network error — showing last updated prices',
  per_oz: 'per oz', gram: 'Gram', per_gram: 'per gram',
  convert_title: 'Converter', amount: 'Amount', asset: 'Asset',
  results_in: 'Value in your currencies', quick: 'Quick amounts',
  weight: 'Weight (g)', karat: 'Karat', mfg_fee_per_gram: 'Manufacturing (per gram)',
  vat: 'VAT (14%)', with_vat: 'With VAT', without_vat: 'Without VAT',
  moyaval: 'Old gold (trade-in)', moyaval_weight: 'Old gold weight (g)',
  total_title: 'Total to pay', old_gold_credit: 'Old gold credit',
  metal_cost: 'Gold cost', mfg_total: 'Manufacturing total',
  add_alert: 'Add alert', metal: 'Metal', currency: 'Currency',
  target_price: 'Target price (per gram)', above: 'Above', below: 'Below',
  save: 'Save', cancel: 'Cancel', no_alerts: 'No alerts yet. Create one to be notified.',
  active: 'Active', paused: 'Paused', triggered: 'Triggered',
  alert_fired: '{metal} crossed {target} {cur}',
  chart_title: 'Historical chart', range: 'Range', quote: 'Display currency',
  quote_display: 'Display currency', gram_price_now: 'Gold gram now',
  range_1w: '1W', range_1m: '1M', range_3m: '3M', range_6m: '6M', range_1y: '1Y',
  no_history_quote: 'No free daily history for {c} — pick a major currency (EUR, JPY, GBP, TRY…) for full charts.',
  metals_history_note: 'Metal history needs a paid provider — currency history is fully live.',
  tm_title: 'Value over time', tm_intro: 'How much did 1 USD buy in {year}, and today?',
  tm_year: 'Year', tm_now: 'Today', tm_then: 'In {year}', tm_change: 'Change since {year}',
  banks_title2: 'CBE vs Live Market', cbe_official: 'CBE official', market: 'Live market',
  offered_by_cbe: 'Published by the Central Bank of Egypt',
  language: 'Language', default_currency: 'Default currency',
  choose_currencies: 'Currencies shown', choose_assets: 'Assets shown',
  preset_gcc: 'GCC', preset_mena: 'MENA', preset_default: 'Reset',
  theme: 'Theme', theme_system: 'System', theme_light: 'Light', theme_dark: 'Dark',
  settings_search: 'Search 50 currencies (SAR, EUR, AED…)',
  more_subtitle: 'Extra tools & insights',
  you_must_show: 'At least one must stay visible',
};

const ar: Record<string, string> = {
  title: 'بريسيس موني',
  tagline: 'أسعار حية للمعادن النفيسة والعملات',
  tab_prices: 'الأسعار', tab_jewelry: 'المجوهرات', tab_converter: 'المحولة',
  tab_settings: 'الإعدادات', tab_more: 'المزيد',
  more_title: 'المزيد', settings_title: 'الإعدادات',
  tab_chart: 'المخطط', alerts_title: 'التنبيهات', calc_title: 'حاسبة المجوهرات',
  timemachine_title: 'القيمة عبر الزمن', banks_title: 'أسعار البنك المركزي',
  live: 'مباشر', retry: 'إعادة المحاولة', last_update_now: 'آخر تحدّث الآن',
  last_update: 'آخر تحدّث {x}', network_error: 'خطأ شبكة — تُعرض آخر أسعار محدّثة',
  per_oz: 'للأونصة', gram: 'جرام', per_gram: 'للجرام',
  convert_title: 'المُحوِّل', amount: 'المقدار', asset: 'الأصل',
  results_in: 'القيمة بعملاتك المعروضة', quick: 'مقادير سريعة',
  weight: 'الوزن (جم)', karat: 'العيار', mfg_fee_per_gram: 'المصنعية (للجرام)',
  vat: 'ضريبة القيمة المضافة (14%)', with_vat: 'بالضريبة', without_vat: 'بدون ضريبة',
  moyaval: 'المبشَّت (ذهب قديم)', moyaval_weight: 'وزن المبشَّت (جم)',
  total_title: 'الإجمالي المستحق', old_gold_credit: 'قيمة المبشَّت',
  metal_cost: 'تكلفة الذهب', mfg_total: 'إجمالي المصنعية',
  add_alert: 'إضافة تنبيه', metal: 'المعدن', currency: 'العملة',
  target_price: 'السعر المستهدف (للجرام)', above: 'فوق', below: 'تحت',
  save: 'حفظ', cancel: 'إلغاء', no_alerts: 'لا تنبيهات بعد. أضف أولاً ليخبرك.',
  active: 'نشط', paused: 'متوقف', triggered: 'تمّ',
  alert_fired: '{metal} تجاوز {target} {cur}',
  chart_title: 'المخطط التاريخي', range: 'الفترة', quote: 'عملة العرض',
  quote_display: 'عملة العرض', gram_price_now: 'سعر الجرام الآن',
  range_1w: 'أسبوع', range_1m: 'شهر', range_3m: '3 أشهر', range_6m: '6 أشهر', range_1y: 'سنة',
  no_history_quote: 'لا يوجد تاريخ مجاني لـ {c} — اختر عملة كبرى (EUR، JPY، GBP، TRY…) للمخطط الكامل.',
  metals_history_note: 'تاريخ المعادن يحتاج مزوّداً مدفوعاً — تاريخ العملات متاح كاملاً ومباشر.',
  tm_title: 'القيمة عبر الزمن', tm_intro: 'كم كان يشتري 1 دولار في {year}، وكم اليوم؟',
  tm_year: 'السنة', tm_now: 'اليوم', tm_then: 'في {year}', tm_change: 'التغيّر منذ {year}',
  banks_title2: 'المركزي مقابل السوق الحي', cbe_official: 'الرسمي (المركزي)', market: 'السوق الحي',
  offered_by_cbe: 'تنشره。البوابة الرسمية للبنك المركزي المصري',
  language: 'اللغة', default_currency: 'العملة الافتراضية',
  choose_currencies: 'العملات المعروضة', choose_assets: 'الأصول المعروضة',
  preset_gcc: 'الخليج', preset_mena: 'الشرق الأوسط', preset_default: 'استعادة الافتراضي',
  theme: 'المظهر', theme_system: 'النظام', theme_light: 'فاتح', theme_dark: 'داكن',
  settings_search: 'ابحث في 50 عملة (SAR، EUR، AED…)',
  more_subtitle: 'أدوات وإحصاءات إضافية',
  you_must_show: 'ي يجب إظهار عنصر واحد على الأقل',
};

const dicts: Record<Lang, Record<string, string>> = { en, ar };

export function t(
  lang: Lang,
  key: string,
  vars?: Record<string, string | number>,
): string {
  let s = dicts[lang][key] ?? dicts.en[key] ?? key;
  if (vars) {
    for (const [k, v] of Object.entries(vars)) s = s.replace(`{${k}}`, String(v));
  }
  return s;
}
