import { useEffect, useState } from 'react';
import { CURRENCIES, currencyFlag, currencySymbol } from '../core/constants';
import { fetchCbeRates } from '../data/api';
import { t } from '../core/l10n';
import { useApp } from '../store/useApp';
import { moneyDigits } from '../core/utils';

export function Banks() {
  const lang = useApp((s) => s.prefs.lang);
  const snapshot = useApp((s) => s.snapshot);
  const [rows, setRows] = useState<Array<{ quote: string; rate: number; date: string }> | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    let alive = true;
    fetchCbeRates()
      .then((r) => alive && setRows(r))
      .catch(() => alive && setError(true));
    return () => {
      alive = false;
    };
  }, []);

  return (
    <div className="card">
      <div className="section-title">🏦 {t(lang, 'banks_title2')}</div>
      <div className="dim" style={{ marginBottom: 10 }}>{t(lang, 'offered_by_cbe')}</div>
      {error && <div className="dim">⚠ {t(lang, 'network_error')}</div>}
      {!rows && !error && <div className="skeleton" style={{ height: 220 }} />}
      {rows && (
        <table className="rate">
          <thead>
            <tr>
              <td className="dim" style={{ fontWeight: 800 }}>{t(lang, 'cbe_official')}</td>
              <td className="dim" style={{ fontWeight: 800 }}>{t(lang, 'market')}</td>
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => {
              const market = snapshot?.usdRates[r.quote];
              const dev = market ? ((market - r.rate) / r.rate) * 100 : null;
              return (
                <tr key={r.quote}>
                  <td>
                    <span className="row" style={{ gap: 6 }}>
                      <span>{currencyFlag(r.quote)}</span>
                      <span className="lcode">{r.quote}</span>
                      <span className="lnum" style={{ fontWeight: 800 }}>
                        {moneyDigits(r.rate)}
                      </span>
                      <span className="dim">{currencySymbol(r.quote)}</span>
                    </span>
                  </td>
                  <td>
                    {market == null ? (
                      <span className="dim">—</span>
                    ) : (
                      <span className="row" style={{ gap: 6 }}>
                        <span className="lnum" style={{ fontWeight: 800 }}>
                          {moneyDigits(market)}
                        </span>
                        {dev != null && Math.abs(dev) > 0.05 && (
                          <span
                            className={dev > 0 ? 'badge' : 'badge off'}
                            style={{ fontSize: 10 }}
                          >
                            {dev > 0 ? '▲' : '▼'} {Math.abs(dev).toFixed(1)}%
                          </span>
                        )}
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

void CURRENCIES;
