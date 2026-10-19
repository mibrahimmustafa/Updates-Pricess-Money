import { useEffect, useMemo, useState } from 'react';
import { fetchCurrencyHistory } from '../data/api';
import { HISTORY_CURRENCIES, currencyFlag, currencySymbol } from '../core/constants';
import { t } from '../core/l10n';
import { useApp } from '../store/useApp';
import { moneyDigits } from '../core/utils';

const START_YEAR = 2015;

export function TimeMachine() {
  const lang = useApp((s) => s.prefs.lang);

  const options = useMemo(
    () => HISTORY_CURRENCIES.filter((c) => c !== 'USD'),
    [],
  );
  const [quote, setQuote] = useState('EUR');
  const [data, setData] = useState<Array<{ date: string; value: number }>>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    let alive = true;
    setLoading(true);
    setError(false);
    fetchCurrencyHistory(quote, `${START_YEAR}-01-01`)
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
  }, [quote]);

  const years = useMemo(() => {
    const set = new Set(data.map((d) => d.date.slice(0, 4)));
    return [...set].sort();
  }, [data]);

  const firstOf = (year: string) =>
    data.find((d) => d.date.startsWith(`${year}-`))?.value;
  const todays = data[data?.length - 1]?.value;
  const firstYear = years[0];

  return (
    <div className="card">
      <div className="section-title">🕰 {t(lang, 'tm_title')}</div>
      <div className="dim" style={{ marginBottom: 12 }}>
        {t(lang, 'tm_intro', { year: firstYear ?? START_YEAR })}
      </div>
      <div className="row wrap" style={{ gap: 8, marginBottom: 14 }}>
        <select
          className="input"
          style={{ width: 150 }}
          value={quote}
          onChange={(e) => setQuote(e.target.value)}
        >
          {options.map((c) => (
            <option key={c} value={c}>
              {currencyFlag(c)} {c} · {currencySymbol(c)}
            </option>
          ))}
        </select>
        {firstYear && <span className="badge off lnum">📉 since {firstYear}</span>}
      </div>

      {loading && <div className="skeleton" style={{ height: 220 }} />}
      {error && <div className="dim">⚠ {t(lang, 'network_error')}</div>}
      {!loading && !error && firstYear && (
        <table className="rate">
          <thead>
            <tr>
              <td className="dim" style={{ fontWeight: 800 }}>{t(lang, 'tm_year')}</td>
              <td className="dim" style={{ fontWeight: 800 }}>1 USD =</td>
            </tr>
          </thead>
          <tbody>
            {years.map((y) => {
              const v = firstOf(y);
              if (v == null) return null;
              const delta =
                todays && v !== todays ? ((todays - v) / v) * 100 : null;
              return (
                <tr key={y}>
                  <td className="dim lnum">{y}</td>
                  <td className="lnum" style={{ fontWeight: 700 }}>
                    {moneyDigits(v)} {currencySymbol(quote)}
                    {delta != null && (
                      <span
                        className={delta >= 0 ? 'badge lnum' : 'badge off lnum'}
                        style={{ marginInlineStart: 8, fontSize: 10 }}
                      >
                        {delta >= 0 ? '▲' : '▼'} {Math.abs(delta).toFixed(0)}%
                      </span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
    </div>
  );
}
