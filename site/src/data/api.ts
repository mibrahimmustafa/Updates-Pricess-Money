import { CURRENCY_POOL, METALS } from '../core/constants';
import type { PriceSnapshot, SeriesPoint } from './types';

const GOLD_API = 'https://api.gold-api.com';
const FRANKFURTER = 'https://api.frankfurter.dev';

async function json<T>(url: string, timeoutMs = 12_000): Promise<T> {
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(url, { signal: ctrl.signal });
    if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
    return (await res.json()) as T;
  } finally {
    clearTimeout(timer);
  }
}

/** Latest USD/oz price for one metal symbol from gold-api. */
export async function fetchMetalPrice(symbol: string): Promise<number> {
  const data = await json<{ price: number }>(`${GOLD_API}/price/${symbol}`);
  if (typeof data.price !== 'number' || Number.isNaN(data.price)) {
    throw new Error(`Bad price payload for ${symbol}`);
  }
  return data.price;
}

/** All pool metals in parallel. */
export async function fetchAllMetals(): Promise<Record<string, number>> {
  const symbols = Object.keys(METALS);
  const prices = await Promise.all(
    symbols.map(async (s) => {
      // tolerate a single flaky symbol without losing the snapshot
      try {
        return [s, await fetchMetalPrice(s)] as const;
      } catch {
        return [s, NaN] as const;
      }
    }),
  );
  return Object.fromEntries(prices);
}

/** USD→quote rates for the whole pool in one Frankfurter call. */
export async function fetchFxRates(): Promise<Record<string, number>> {
  const quotes = CURRENCY_POOL.filter((c) => c !== 'USD').join(',');
  const data = await json<Array<{ quote: string; rate: number }>>(
    `${FRANKFURTER}/v2/rates?base=USD&quotes=${quotes}`,
  );
  const out: Record<string, number> = { USD: 1 };
  for (const row of data) if (row.rate > 0) out[row.quote] = row.rate;
  const missing = CURRENCY_POOL.filter((c) => !(c in out));
  if (missing.length === CURRENCY_POOL.length - 1) {
    throw new Error('Frankfurter returned no rates');
  }
  return out;
}

/** Fresh full snapshot + true network latency (ms). */
export async function fetchSnapshot(): Promise<{ snapshot: PriceSnapshot; latencyMs: number }> {
  const t0 = performance.now();
  const [metals, usdRates] = await Promise.all([fetchAllMetals(), fetchFxRates()]);
  return {
    snapshot: { metals, usdRates, ts: Date.now() },
    latencyMs: Math.round(performance.now() - t0),
  };
}

/** Currency timeseries (Frankfurter v1). Data exists back to 2015. */
export async function fetchCurrencyHistory(
  quote: string,
  start: string,
  end = '',
): Promise<SeriesPoint[]> {
  if (quote === 'USD') return [];
  const data = await json<{ rates: Record<string, Record<string, number>> }>(
    `${FRANKFURTER}/v1/${start}..${end}?base=USD&quotes=${quote}`,
  );
  return Object.entries(data.rates)
    .map(([date, m]) => ({ date, value: m[quote] }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

/** Central Bank of Egypt published USD rates (latest day, all quotes). */
export async function fetchCbeRates(
  base = 'USD',
): Promise<Array<{ quote: string; rate: number; date: string }>> {
  const data = await json<Array<{ date: string; base: string; quote: string; rate: number }>>(
    `${FRANKFURTER}/v2/providers/cbe/rates?base=${base}`,
  );
  const latest = data[data.length - 1]?.date ?? '';
  return data
    .filter((r) => r.date === latest && r.quote !== base)
    .map((r) => ({ quote: r.quote, rate: r.rate, date: r.date }));
}

/** Cache helpers (stale-while-revalidate). */
const CACHE_KEY = 'price_snapshot_v2';

export function loadCachedSnapshot(): PriceSnapshot | null {
  try {
    const raw = localStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    const p = JSON.parse(raw) as PriceSnapshot;
    return p && p.metals && p.usdRates ? p : null;
  } catch {
    return null;
  }
}

export function saveCachedSnapshot(p: PriceSnapshot): void {
  try {
    localStorage.setItem(CACHE_KEY, JSON.stringify(p));
  } catch {
    /* storage full/private mode — degrade silently */
  }
}
