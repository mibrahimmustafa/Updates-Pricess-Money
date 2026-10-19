import { useEffect, useMemo, useState } from 'react';
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';
import { CURRENCY_POOL, HISTORY_CURRENCIES, currencySymbol } from '../core/constants';
import { fetchCurrencyHistory } from '../data/api';
import { moneyDigits } from '../core/utils';
import { t } from '../core/l10n';
import { useApp } from '../store/useApp';
import type { SeriesPoint } from '../data/types';

const RANGES: Record<string, number> = {
  '1w': 7, '1m': 30, '3m': 90, '6m': 180, '1y': 365,
};

export function ChartScreen() {
  const lang = useApp((s) => s.prefs.lang);
  const defaultQuote = useApp((s) => s.prefs.defaultQuote);

  const [quote, setQuote] = useState(
    HISTORY_CURRENCIES.includes(defaultQuote) ? defaultQuote : 'EUR',
  );
  const [range, setRange] = useState<keyof typeof RANGES>('1m');
  const [data, setData] = useState<SeriesPoint[] | null>(null);
  const [noHistory, setNoHistory] = useState(false);
  const [error, setError] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!HISTORY_CURRENCIES.includes(quote)) {
      setData(null);
      setNoHistory(true);
      setLoading(false);
      setError(false);
      return;
    }
    setNoHistory(false);
    let alive = true;
    setLoading(true);
    setError(false);
    const start = new Date(Date.now() - RANGES[range] * 86_400_000)
      .toISOString()
      .slice(0, 10);
    fetchCurrencyHistory(quote, start)
      .then((pts) => {
        if (!alive) return;
        setData(pts.filter((p) => Number.isFinite(p.value)));
        setLoading(false);
      })
      .catch(() => {
        if (!alive) return;
        setError(true);
        setLoading(false);
      });
    return () => {
      alive = false;
    };
  }, [quote, range]);

  const stats = useMemo(() => {
    if (!data || data.length < 2) return null;
    const first = data[0].value;
    const last = data[data.length - 1].value;
    const min = Math.min(...data.map((d) => d.value));
    const max = Math.max(...data.map((d) => d.value));
    return { first, last, min, max, change: ((last - first) / first) * 100 };
  }, [data]);

  const fmtV = (v: number) => moneyDigits(v);

  return (
    <div className="card">
      <div className="section-title">📈 {t(lang, 'chart_title')}</div>
      <div className="row wrap" style={{ gap: 8, marginBottom: 12 }}>
        <select className="input" style={{ width: 130 }} value={quote} onChange={(e) => setQuote(e.target.value)}>
          {CURRENCY_POOL.filter((c) => c !== 'USD').map((c) => (
            <option key={c} value={c}>{c} · {currencySymbol(c)}</option>
          ))}
        </select>
        <div className="seg">
          {(Object.keys(RANGES) as Array<keyof typeof RANGES>).map((r) => (
            <button key={r} className={range === r ? 'on' : ''} onClick={() => setRange(r)}>
              {r}
            </button>
          ))}
        </div>
      </div>

      {loading && <div className="skeleton chart-box" style={{ height: 260 }} />}
      {noHistory && (
        <div className="dim" style={{ padding: '18px 0', fontSize: 13 }}>
          ℹ️ {t(lang, 'no_history_quote', { c: quote })}
        </div>
      )}
      {error && !noHistory && <div className="dim">⚠ {t(lang, 'network_error')}</div>}
      {!loading && !error && stats && (
        <>
          <div className="row wrap" style={{ gap: 14, marginBottom: 10 }}>
            <span className="dim">{t(lang, 'quote')}: <b className="lcode">{quote}</b></span>
            <span className={stats.change >= 0 ? 'badge' : 'badge off'}>
              {stats.change >= 0 ? '▲' : '▼'} {Math.abs(stats.change).toFixed(1)}%
            </span>
            <span className="dim lnum">min {fmtV(stats.min)} · max {fmtV(stats.max)}</span>
          </div>
          <div className="chart-box">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={data ?? []} margin={{ top: 6, right: 4, left: 4, bottom: 0 }}>
                <defs>
                  <linearGradient id="goldFill" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#d4a548" stopOpacity={0.45} />
                    <stop offset="100%" stopColor="#d4a548" stopOpacity={0.02} />
                  </linearGradient>
                </defs>
                <CartesianGrid stroke="var(--card-line-soft)" strokeDasharray="3 6" vertical={false} />
                <XAxis
                  dataKey="date"
                  tick={{ fill: 'var(--text-dim)', fontSize: 10 }}
                  tickFormatter={(d: string) => d.slice(5)}
                  minTickGap={40}
                />
                <YAxis
                  domain={['auto', 'auto']}
                  tick={{ fill: 'var(--text-dim)', fontSize: 10 }}
                  width={56}
                  tickFormatter={(v: number) => fmtV(v).replace(/,/g, '')}
                />
                <Tooltip
                  contentStyle={{
                    background: 'var(--card)', border: '1px solid var(--card-line)',
                    borderRadius: 12, color: 'var(--text)', fontSize: 12, fontWeight: 700,
                  }}
                  formatter={(v) => [fmtV(Number(v)), String(quote)] as [string, string]}
                />
                <Area
                  type="monotone"
                  dataKey="value"
                  stroke="#d4a548"
                  strokeWidth={2.4}
                  fill="url(#goldFill)"
                  animationDuration={700}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </>
      )}
    </div>
  );
}
