import { useMemo, useState } from 'react';
import { METALS, CURRENCY_POOL, currencySymbol } from '../core/constants';
import { t } from '../core/l10n';
import { useApp, type PriceAlert } from '../store/useApp';
import { Money, Flag } from '../components/ui';
import { GRAMS_PER_TROY_OZ } from '../core/constants';

export function Alerts() {
  const lang = useApp((s) => s.prefs.lang);
  const prefs = useApp((s) => s.prefs);
  const alerts = useApp((s) => s.alerts);
  const snapshot = useApp((s) => s.snapshot);
  const store = useApp((a) => a);

  const [metal, setMetal] = useState(prefs.metals[0] ?? 'XAU');
  const [currency, setCurrency] = useState(prefs.defaultQuote);
  const [target, setTarget] = useState('');
  const [above, setAbove] = useState(true);
  const [dialog, setDialog] = useState(false);

  const current = useMemo(() => {
    if (!snapshot) return null;
    const oz = snapshot.metals[metal];
    if (oz == null || Number.isNaN(oz)) return null;
    const rate = currency === 'USD' ? 1 : snapshot.usdRates[currency];
    if (!rate) return null;
    return (oz / GRAMS_PER_TROY_OZ) * rate;
  }, [snapshot, metal, currency]);

  const submit = () => {
    const targetNum = parseFloat(target);
    if (!targetNum || targetNum <= 0) return;
    store.addAlert({ metal, currency, target: targetNum, above });
    setDialog(false);
    setTarget('');
  };

  return (
    <>
      <div className="between" style={{ marginBottom: 12 }}>
        <div className="section-title" style={{ margin: 0 }}>{t(lang, 'alerts_title')}</div>
        <button
          className="btn btn-sm"
          onClick={() => {
            setDialog(true);
            setMetal(prefs.metals[0] ?? 'XAU');
            setCurrency(prefs.defaultQuote);
          }}
        >
          ＋ {t(lang, 'add_alert')}
        </button>
      </div>

      {alerts.length === 0 && (
        <div className="card dim" style={{ textAlign: 'center', padding: 30 }}>
          🔔 {t(lang, 'no_alerts')}
        </div>
      )}

      {alerts.map((a: PriceAlert, i) => {
        const oz = snapshot?.metals[a.metal];
        const rate = a.currency === 'USD' ? 1 : snapshot?.usdRates[a.currency];
        const now = oz && rate ? (oz / GRAMS_PER_TROY_OZ) * rate : null;
        const progress =
          now != null && a.above
            ? Math.max(0, Math.min(1, now / a.target))
            : now != null
              ? Math.max(0, Math.min(1, a.target / now))
              : 0;
        return (
          <div className="card menu-card" key={a.id} style={{ animationDelay: `${i * 50}ms`, marginTop: 10 }}>
            <div className="menu-ico">{METALS[a.metal]?.glyph ?? '🥇'}</div>
            <div style={{ flex: 1 }}>
              <div className="between" style={{ gap: 10 }}>
                <span style={{ fontWeight: 800 }}>
                  {lang === 'ar' ? METALS[a.metal]?.nameAr : METALS[a.metal]?.name}{' '}
                  <span className="dim lcode">{a.metal}</span> ·{' '}
                  <span className="lcode">
                    {a.above ? '≥' : '≤'} <span className="dim">{a.target}</span> {currencySymbol(a.currency)}
                  </span>
                </span>
                <span className="row" style={{ gap: 6 }}>
                  <button
                    className="chip"
                    style={{ padding: '4px 10px', fontSize: 11 }}
                    onClick={() => store.toggleAlert(a.id)}
                  >
                    {a.active ? '⏸' : '▶️'} {a.active ? t(lang, 'active') : t(lang, 'paused')}
                  </button>
                  <button
                    className="chip"
                    style={{ padding: '4px 10px', fontSize: 11, color: 'var(--error)' }}
                    onClick={() => store.removeAlert(a.id)}
                  >
                    🗑
                  </button>
                </span>
              </div>
              {a.firedAt ? (
                <span className="badge off" style={{ marginTop: 6 }}>✅ {t(lang, 'triggered')}</span>
              ) : (
                <div style={{ marginTop: 8 }}>
                  <div style={{ height: 6, background: 'var(--chip)', borderRadius: 6, overflow: 'hidden' }}>
                    <div
                      style={{
                        height: '100%',
                        width: `${progress * 100}%`,
                        background: 'linear-gradient(90deg, var(--gold-deep), var(--gold))',
                        borderRadius: 6,
                        transition: 'width .6s var(--ease)',
                      }}
                    />
                  </div>
                  <span className="dim lnum" style={{ fontSize: 11 }}>
                    {now != null && <><Money value={now} currency={a.currency} /> → {a.target}</>}
                  </span>
                </div>
              )}
            </div>
          </div>
        );
      })}

      {dialog && (
        <div
          role="dialog"
          aria-modal="true"
          style={{
            position: 'fixed', inset: 0, zIndex: 120,
            background: 'rgba(0,0,0,.55)', backdropFilter: 'blur(4px)',
            display: 'grid', placeItems: 'center', padding: 16,
          }}
          onClick={(e) => e.target === e.currentTarget && setDialog(false)}
        >
          <div className="card" style={{ width: 'min(430px, 100%)', animation: 'fadeUp .35s var(--ease)' }}>
            <div className="section-title">{t(lang, 'add_alert')}</div>
            <div className="label">{t(lang, 'metal')}</div>
            <select className="input" value={metal} onChange={(e) => setMetal(e.target.value)}>
              {prefs.metals.map((m) => (
                <option key={m} value={m}>
                  {(lang === 'ar' ? METALS[m]?.nameAr : METALS[m]?.name) ?? m}
                </option>
              ))}
            </select>
            <div style={{ height: 10 }} />
            <div className="label">{t(lang, 'currency')}</div>
            <select className="input" value={currency} onChange={(e) => setCurrency(e.target.value)}>
              {prefs.currencies.map((c) => (
                <option key={c} value={c}>
                  {c} · {currencySymbol(c)}
                </option>
              ))}
            </select>
            <div style={{ height: 10 }} />
            <div className="between" style={{ marginBottom: 8 }}>
              <div className="seg">
                <button className={above ? 'on' : ''} onClick={() => setAbove(true)}>↑ {t(lang, 'above')}</button>
                <button className={!above ? 'on' : ''} onClick={() => setAbove(false)}>↓ {t(lang, 'below')}</button>
              </div>
              {current != null && (
                <span className="dim lnum">{t(lang, 'live')}: {current.toFixed(2)}</span>
              )}
            </div>
            <input
              className="input lnum"
              inputMode="decimal"
              placeholder={t(lang, 'target_price')}
              value={target}
              onChange={(e) => setTarget(e.target.value.replace(/[^\d.]/g, ''))}
            />
            <div className="row" style={{ justifyContent: 'flex-end', gap: 8, marginTop: 14 }}>
              <button className="btn btn-ghost btn-sm" onClick={() => setDialog(false)}>{t(lang, 'cancel')}</button>
              <button className="btn btn-sm" onClick={submit} disabled={!parseFloat(target)}>
                💾 {t(lang, 'save')}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

void CURRENCY_POOL;
void Flag;
