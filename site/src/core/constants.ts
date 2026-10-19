// Pricess Money — shared pools, symbols, flags. Single source of truth.

export const GRAMS_PER_TROY_OZ = 31.1034768;
export const POLL_INTERVAL_MS = 30_000;
export const VAT_RATE = 0.14;

export type MetalInfo = {
  name: string;
  nameAr: string;
  glyph: string;
  color: string;
  perGram: boolean;
};

export const METALS: Record<string, MetalInfo> = {
  XAU: { name: 'Gold', nameAr: 'ذهب', glyph: '🥇', color: '#D4A548', perGram: true },
  XAG: { name: 'Silver', nameAr: 'فضة', glyph: '🥈', color: '#B7C0CC', perGram: true },
  XPT: { name: 'Platinum', nameAr: 'بلاتين', glyph: '⚙️', color: '#9BA8B5', perGram: true },
  XPD: { name: 'Palladium', nameAr: 'بالاديوم', glyph: '🔹', color: '#8FA8C5', perGram: true },
  HG: { name: 'Copper', nameAr: 'نحاس', glyph: '🔩', color: '#C87848', perGram: true },
  BTC: { name: 'Bitcoin', nameAr: 'بيتكوين', glyph: '₿', color: '#F7931A', perGram: false },
  ETH: { name: 'Ethereum', nameAr: 'إيثريوم', glyph: 'Ξ', color: '#627EEA', perGram: false },
};

export const DEFAULT_VISIBLE_METALS = ['XAU', 'XAG'];

export type Currency = { code: string; sym: string; ar: string };

/** Curated pool of 48 world + Arab currencies (Frankfurter-backed). */
export const CURRENCIES: Currency[] = [
  { code: 'USD', sym: '$', ar: 'دولار أمريكي' },
  { code: 'EUR', sym: '€', ar: 'يورو' },
  { code: 'GBP', sym: '£', ar: 'جنيه إسترليني' },
  { code: 'JPY', sym: '¥', ar: 'ين ياباني' },
  { code: 'CNY', sym: '¥', ar: 'يوان صيني' },
  { code: 'CHF', sym: 'CHF', ar: 'فرنك سويسري' },
  { code: 'CAD', sym: 'C$', ar: 'دولار كندي' },
  { code: 'AUD', sym: 'A$', ar: 'دولار أسترالي' },
  { code: 'NZD', sym: 'NZ$', ar: 'دولار نيوزيلندي' },
  { code: 'SGD', sym: 'S$', ar: 'دولار سنغافوري' },
  { code: 'HKD', sym: 'HK$', ar: 'دولار هونغ كونغ' },
  { code: 'KRW', sym: '₩', ar: 'وون كوري' },
  { code: 'INR', sym: '₹', ar: 'روبية هندية' },
  { code: 'PKR', sym: '₨', ar: 'روبية باكستانية' },
  { code: 'IDR', sym: 'Rp', ar: 'روبية إندونيسية' },
  { code: 'MYR', sym: 'RM', ar: 'رينغيت ماليزي' },
  { code: 'THB', sym: '฿', ar: 'بات تايلندي' },
  { code: 'TWD', sym: 'NT$', ar: 'دولار تايواني' },
  { code: 'TRY', sym: '₺', ar: 'ليرة تركية' },
  { code: 'RUB', sym: '₽', ar: 'روبل روسي' },
  { code: 'BRL', sym: 'R$', ar: 'ريال برازيلي' },
  { code: 'MXN', sym: 'Mex$', ar: 'بيزو مكسيكي' },
  { code: 'ZAR', sym: 'R', ar: 'راند جنوب أفريقي' },
  { code: 'NGN', sym: '₦', ar: 'نايرا نيجيري' },
  { code: 'PLN', sym: 'zł', ar: 'زوتي بولندي' },
  { code: 'SEK', sym: 'kr', ar: 'كرونة سويدية' },
  { code: 'NOK', sym: 'kr', ar: 'كرونة نرويجية' },
  { code: 'DKK', sym: 'kr', ar: 'كرونة دنماركية' },
  { code: 'CZK', sym: 'Kč', ar: 'كورونا تشيكية' },
  { code: 'HUF', sym: 'Ft', ar: 'فورنت مجري' },
  { code: 'RON', sym: 'lei', ar: 'ليو روماني' },
  { code: 'ILS', sym: '₪', ar: 'شيكل إسرائيلي' },
  { code: 'RSD', sym: 'din', ar: 'دينار صربي' },
  { code: 'UAH', sym: '₴', ar: 'هريفنيا أوكرانية' },
  { code: 'BGN', sym: 'лв', ar: 'ليف بلغاري' },
  { code: 'SAR', sym: 'ر.س', ar: 'ريال سعودي' },
  { code: 'AED', sym: 'د.إ', ar: 'درهم إماراتي' },
  { code: 'EGP', sym: 'ج.م', ar: 'جنيه مصري' },
  { code: 'QAR', sym: 'ر.ق', ar: 'ريال قطري' },
  { code: 'KWD', sym: 'د.ك', ar: 'دينار كويتي' },
  { code: 'BHD', sym: 'د.ب', ar: 'دينار بحريني' },
  { code: 'OMR', sym: 'ر.ع', ar: 'ريال عماني' },
  { code: 'JOD', sym: 'د.أ', ar: 'دينار أردني' },
  { code: 'IQD', sym: 'ع.د', ar: 'دينار عراقي' },
  { code: 'LBP', sym: 'ل.ل', ar: 'ليرة لبنانية' },
  { code: 'YER', sym: 'ر.ي', ar: 'ريال يمني' },
  { code: 'MAD', sym: 'د.م', ar: 'درهم مغربي' },
  { code: 'DZD', sym: 'د.ج', ar: 'دينار جزائري' },
  { code: 'TND', sym: 'د.ت', ar: 'دينار تونسي' },
  { code: 'LYD', sym: 'د.ل', ar: 'دينار ليبي' },
  { code: 'SDG', sym: 'ج.س', ar: 'جنيه سوداني' },
];

export const CURRENCY_BY_CODE: Record<string, Currency> = Object.fromEntries(
  CURRENCIES.map((c) => [c.code, c]),
);

export const CURRENCY_POOL = CURRENCIES.map((c) => c.code);

/** Wide default display set: Arab + world majors (18). */
export const DEFAULT_VISIBLE_CURRENCIES = [
  'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'TRY',
  'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR',
  'EGP', 'JOD', 'MAD', 'DZD', 'TND', 'LYD',
];

export const GCC_CURRENCIES = ['SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR'];

export const MENA_CURRENCIES = [
  'EGP', 'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD',
  'IQD', 'LBP', 'YER', 'MAD', 'DZD', 'TND', 'LYD', 'SDG',
];

const FLAGS_WORLD: Record<string, string> = { EUR: '🇪🇺' };

/** ISO-3166 flag emoji from a currency code (USD→🇺🇸). */
export function currencyFlag(code: string): string {
  if (FLAGS_WORLD[code]) return FLAGS_WORLD[code];
  if (METALS[code]) return METALS[code].glyph;
  const upper = code.toUpperCase();
  const first = String.fromCharCode(0x1f1e6 + upper.charCodeAt(0) - 65);
  const second = String.fromCharCode(0x1f1e6 + upper.charCodeAt(1) - 65);
  return first + second;
}

export function currencySymbol(code: string): string {
  return CURRENCY_BY_CODE[code]?.sym ?? code;
}

export const KARATS: Record<string, number> = {
  '24K': 1.0,
  '22K': 0.9167,
  '21K': 0.875,
  '18K': 0.75,
};

/**
 * Currencies with free daily history (ECB reference list backing
 * Frankfurter v1). Arab currencies (EGP/SAR/…) have live rates but
 * no free keyless daily history — honest UI note instead of fake data.
 */
export const HISTORY_CURRENCIES: string[] = [
  'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'EUR', 'GBP',
  'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR',
  'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'ZAR',
];
