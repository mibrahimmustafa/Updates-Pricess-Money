import { currencySymbol, GRAMS_PER_TROY_OZ, CURRENCY_POOL } from './constants';

/** Number with thousands separators, western digits, bounded precision. */
export function num(value: number, maxFrac = 2, minFrac = 2): string {
  return new Intl.NumberFormat('en', {
    maximumFractionDigits: maxFrac,
    minimumFractionDigits: minFrac,
  }).format(value);
}

/** Digits rule: short for big numbers, extra precision for small ones. */
export function moneyDigits(value: number): string {
  const abs = Math.abs(value);
  if (abs >= 1000) return num(value, 2, 2);
  if (abs >= 100) return num(value, 2, 2);
  if (abs >= 1) return num(value, 3, 3);
  return num(value, 4, 4);
}

/**
 * Structured money: renders as `${digits} ${symbol}` with an explicitly
 * LTR digits span — direction-safe inside RTL text (the exact bug
 * "ج.مج.م / USD scrambling" came from naive string concat).
 */
export function moneyParts(value: number, currency: string): { digits: string; sym: string } {
  return { digits: moneyDigits(value), sym: currencySymbol(currency) };
}

/** Convert any amount between pool currencies through the USD hub. */
export function convert(amount: number, from: string, to: string, usdRates: Record<string, number>): number {
  if (from === to) return amount;
  const f = from === 'USD' ? 1 : usdRates[from];
  const t = to === 'USD' ? 1 : usdRates[to];
  if (!f || !t) return NaN;
  return (amount / f) * t;
}

/** USD price-per-ounce → price per gram. */
export function perGram(pricePerOz: number): number {
  return pricePerOz / GRAMS_PER_TROY_OZ;
}

export function formatDate(d: string | Date): string {
  const date = typeof d === 'string' ? new Date(d) : d;
  const mm = String(date.getMonth() + 1).padStart(2, '0');
  const dd = String(date.getDate()).padStart(2, '0');
  return `${date.getFullYear()}-${mm}-${dd}`;
}

export function timeAgo(ts: number, lang: 'en' | 'ar'): string {
  const s = Math.max(1, Math.round((Date.now() - ts) / 1000));
  if (s < 60) return lang === 'ar' ? 'الآن' : 'now';
  const m = Math.floor(s / 60);
  if (m < 60) return lang === 'ar' ? `منذ ${m} د` : `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return lang === 'ar' ? `منذ ${h} س` : `${h}h ago`;
  const d = Math.floor(h / 24);
  return lang === 'ar' ? `منذ ${d} ي` : `${d}d ago`;
}

/** Latency chip color: green / amber / red. */
export function latencyColor(ms: number | null | undefined): string {
  if (ms == null) return '#66BB6A';
  if (ms < 700) return '#66BB6A';
  if (ms < 1600) return '#FFB74D';
  return '#E57373';
}

export function isPoolCurrency(code: string): boolean {
  return CURRENCY_POOL.includes(code);
}
