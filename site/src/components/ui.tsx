import { useEffect, useRef, useState } from 'react';
import {
  METALS,
  KARATS,
  GRAMS_PER_TROY_OZ,
  currencyFlag,
  currencySymbol,
} from '../core/constants';
import { moneyParts, latencyColor, timeAgo } from '../core/utils';
import { t, type Lang } from '../core/l10n';
import { useApp } from '../store/useApp';

/* ---------- animated number (count-up + flash on change) ---------- */
export function Num({
  value,
  className,
  fixed,
}: {
  value: number;
  className?: string;
  fixed?: number;
}) {
  const ref = useRef<HTMLSpanElement>(null);
  const prev = useRef<number | null>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const from = prev.current ?? value;
    prev.current = value;
    if (value === from) return;

    const up = value > from;
    el.classList.remove('flash-up', 'flash-down');
    void el.offsetWidth;
    el.classList.add(up ? 'flash-up' : 'flash-down');

    const dur = 420;
    const t0 = performance.now();
    let raf = 0;
    const decimals = fixed ?? (Math.abs(value) < 100 ? 3 : 2);
    const fmt = (n: number) =>
      n.toLocaleString('en', {
        maximumFractionDigits: decimals,
        minimumFractionDigits: decimals,
      });
    const step = (now: number) => {
      const k = Math.min(1, (now - t0) / dur);
      const eased = 1 - Math.pow(1 - k, 3);
      el.textContent = fmt(from + (value - from) * eased);
      if (k < 1) raf = requestAnimationFrame(step);
      else el.textContent = fmt(value);
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [value, fixed]);

  const decimals = fixed ?? (Math.abs(value) < 100 ? 3 : 2);
  return (
    <span ref={ref} className={`lnum ${className ?? ''}`}>
      {value.toLocaleString('en', { maximumFractionDigits: decimals, minimumFractionDigits: decimals })}
    </span>
  );
}

/* ---------- "digits + symbol", direction-safe ---------- */
export function Money({
  value,
  currency,
  big,
}: {
  value: number;
  currency: string;
  big?: boolean;
}) {
  const { digits, sym } = moneyParts(value, currency);
  return (
    <span style={big ? { fontWeight: 800, color: 'var(--gold)' } : { fontWeight: 700 }}>
      <span className="lnum">{digits}</span> {sym}
    </span>
  );
}

export function Flag({ code, size = 15 }: { code: string; size?: number }) {
  return (
    <span role="img" aria-label={code} style={{ fontSize: size, lineHeight: 1 }}>
      {currencyFlag(code)}
    </span>
  );
}

/* ---------- LIVE badge + latency chip ---------- */
export function LiveBadge() {
  const lang = useApp((s) => s.prefs.lang);
  const latency = useApp((s) => s.latencyMs);
  const error = useApp((s) => s.error);
  const live = !error;
  const color = latencyColor(latency);
  return (
    <span className={`badge ${live ? '' : 'off'}`}>
      <span className="dot" />
      {t(lang, 'live')}
      {live && latency != null && (
        <span className="latency lnum" style={{ background: color + '2e', color }}>
          {latency} ms
        </span>
      )}
    </span>
  );
}

/* ---------- last-update text (auto-refreshing) ---------- */
export function Updated() {
  const lang = useApp((s) => s.prefs.lang);
  const ts = useApp((s) => s.snapshot?.ts);
  const [, tick] = useState(0);
  useEffect(() => {
    const i = setInterval(() => tick((x) => x + 1), 20_000);
    return () => clearInterval(i);
  }, []);
  if (!ts) return null;
  return (
    <span className="dim">
      {t(lang, 'last_update', { x: timeAgo(ts, lang) })}
    </span>
  );
}

/* ---------- FX bar: one tile per visible currency ---------- */
export function FxBar() {
  const snapshot = useApp((s) => s.snapshot);
  // NB: selectors must return stable snapshots — filter in render, not here.
  const currenciesAll = useApp((s) => s.prefs.currencies);
  if (!snapshot) return null;
  const currencies = currenciesAll.filter((c) => c !== 'USD');
  return (
    <div className="fxbar">
      {currencies.map((c, i) => {
        const rate = snapshot.usdRates[c];
        if (!rate) return null;
        return (
          <div className="fx-tile" key={c} style={{ animation: `fadeUp .5s var(--ease) ${i * 45}ms both` }}>
            <div className="fx-head">
              1 USD <span style={{ color: 'var(--gold)' }}>→</span>
              <Flag code={c} />
              <span style={{ color: 'var(--gold)', fontWeight: 800 }}>{c}</span>
            </div>
            <div className="fx-value">
              <Num value={rate} fixed={c === 'JPY' ? 3 : 4} />{' '}
              <span style={{ fontSize: 14 }}>{currencySymbol(c)}</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}

/* ---------- metal price card ---------- */
export function MetalCard({ symbol, delay }: { symbol: string; delay: number }) {
  const snapshot = useApp((s) => s.snapshot);
  const currencies = useApp((s) => s.prefs.currencies);
  const lang = useApp((s) => s.prefs.lang);
  if (!snapshot) return null;
  const oz = snapshot.metals[symbol];
  if (oz == null || Number.isNaN(oz)) return null;
  const meta = METALS[symbol];
  if (!meta) return null;
  const label = lang === 'ar' ? meta.nameAr : meta.name;
  const last = currencies[currencies.length - 1] ?? 'USD';
  const rateOf = (c: string) => (c === 'USD' ? 1 : snapshot.usdRates[c]);

  return (
    <div className="card" style={{ animation: `fadeUp .55s var(--ease) ${delay}ms both` }}>
      <div className="metal-head">
        <div className="metal-ico" style={{ color: meta.color }}>{meta.glyph}</div>
        <div>
          <div style={{ fontWeight: 800 }}>{label}</div>
          <div className="dim lcode" style={{ letterSpacing: 1 }}>{symbol}</div>
        </div>
        <div className="spacer" />
        <div className="row" style={{ gap: 4 }}>
          <Num value={oz} className="price-big" fixed={2} />
          <span style={{ color: 'var(--gold)', fontWeight: 800 }}>$</span>
        </div>
      </div>
      <div className="dim" style={{ textAlign: 'end' }}>{t(lang, 'per_oz')}</div>

      {meta.perGram ? (
        currencies.map((c) => {
          const rate = rateOf(c);
          if (!rate) return null;
          return (
            <div className="between" key={c} style={{ padding: '6px 0', borderBottom: '1px dashed var(--card-line-soft)' }}>
              <span className="dim">
                {t(lang, 'gram')} · <span className="lcode">{c}</span>
              </span>
              <Money value={(oz / GRAMS_PER_TROY_OZ) * rate} currency={c} />
            </div>
          );
        })
      ) : (
        <div className="dim" style={{ marginTop: 6 }}>
          {lang === 'ar' ? 'سعر لحظي (لا يُطرح لكل جرام)' : 'Spot price (not minted per gram)'}
        </div>
      )}

      {symbol === 'XAU' &&
        currencies.length > 0 &&
        Object.entries(KARATS)
          .filter(([k]) => k !== '24K')
          .map(([k, factor]) => (
            <div className="between" key={k} style={{ padding: '6px 0', borderBottom: '1px dashed var(--card-line-soft)' }}>
              <span className="dim">
                {t(lang, 'gram')} <span className="lcode">{k}</span> · <span className="lcode">{last}</span>
              </span>
              <Money value={(oz / GRAMS_PER_TROY_OZ) * factor * rateOf(last)} currency={last} />
            </div>
          ))}
    </div>
  );
}

/* ---------- skeleton ---------- */
export function SkeletonCard() {
  return (
    <div className="card" style={{ animation: 'none' }}>
      <div className="row" style={{ gap: 12 }}>
        <div className="skeleton" style={{ width: 44, height: 44, borderRadius: '50%' }} />
        <div style={{ flex: 1 }}>
          <div className="skeleton" style={{ height: 16, width: '40%', marginBottom: 8 }} />
          <div className="skeleton" style={{ height: 12, width: '25%' }} />
        </div>
        <div className="skeleton" style={{ height: 26, width: 110 }} />
      </div>
      <div style={{ height: 14 }} />
      <div className="skeleton" style={{ height: 110 }} />
    </div>
  );
}

/* ---------- error banner + retry ---------- */
export function ErrorBanner() {
  const lang = useApp((s) => s.prefs.lang) as Lang;
  const refresh = useApp((s) => s.refresh);
  const error = useApp((s) => s.error);
  if (!error) return null;
  return (
    <div className="error-banner">
      <span>⚠️</span>
      <span>{t(lang, 'network_error')}</span>
      <button className="btn btn-ghost btn-sm" onClick={() => void refresh()}>
        {t(lang, 'retry')}
      </button>
    </div>
  );
}
