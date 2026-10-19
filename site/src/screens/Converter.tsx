import { useMemo, useState } from 'react';
import { CURRENCIES, currencyFlag, currencySymbol, METALS } from '../core/constants';
import { convert } from '../core/utils';
import { t } from '../core/l10n';
import { useApp } from '../store/useApp';
import { Money, Flag } from '../components/ui';

type Asset = { code: string; kind: 'metal' | 'currency'; label: string; labelAr: string; glyph: string };

export function Converter() {
  const lang = useApp((s) => s.prefs.lang);
  const snapshot = useApp((s) => s.snapshot);
  const currencies = useApp((s) => s.prefs.currencies);
  const metals = useApp((s) => s.prefs.metals);
  const defaultQuote = useApp((s) => s.prefs.defaultQuote);

  const assets: Asset[] = useMemo(() => {
    const m: Asset[] = metals.map((code) => ({
      code,
      kind: 'metal',
      label: METALS[code].name,
      labelAr: METALS[code].nameAr,
      glyph: METALS[code].glyph,
    }));
    const c: Asset[] = CURRENCIES.filter(
      (x) => currencies.includes(x.code) || x.code === defaultQuote,
    )
      .map((x) => ({
        code: x.code,
        kind: 'currency',
        label: x.code,
        labelAr: x.ar,
        glyph: currencyFlag(x.code),
      }));
    return [...m, ...c];
  }, [metals, currencies, defaultQuote]);

  const [assetCode, setAssetCode] = useState(defaultQuote);
  const [amount, setAmount] = useState('1');

  // keep selection valid when prefs change
  const selected = assets.find((a) => a.code === assetCode) ?? assets.find((a) => a.code === defaultQuote) ?? assets[0];
  const asset = selected ?? { code: 'USD', kind: 'currency' as const, label: 'USD', labelAr: 'دولار', glyph: '💵' };
  const amt = parseFloat(amount) || 0;
  const usdRates = snapshot?.usdRates ?? {};

  const value = (cur: string): number | null => {
    if (!snapshot) return null;
    if (asset.kind === 'metal') {
      const oz = snapshot.metals[asset.code];
      if (oz == null || Number.isNaN(oz)) return null;
      return (oz / 31.1034768) * amt * (cur === 'USD' ? 1 : (usdRates[cur] ?? NaN));
    }
    const v = convert(amt, asset.code, cur, usdRates);
    return Number.isNaN(v) ? null : v;
  };

  const others = currencies.filter((c) => c !== asset.code);

  return (
    <div className="card" style={{ maxWidth: 520, marginInline: 'auto' }}>
      <div className="section-title">{t(lang, 'convert_title')}</div>
      <div className="label">{t(lang, 'asset')}</div>
      <select
        className="input"
        value={asset.code}
        onChange={(e) => setAssetCode(e.target.value)}
      >
        {assets.map((a) => (
          <option key={a.code} value={a.code}>
            {a.glyph} {lang === 'ar' ? a.labelAr : a.label}
          </option>
        ))}
      </select>
      <div style={{ height: 10 }} />
      <div className="label">{t(lang, 'amount')}</div>
      <input
        className="input lnum"
        inputMode="decimal"
        value={amount}
        onChange={(e) => setAmount(e.target.value.replace(/[^\d.]/g, ''))}
      />
      <div className="chipwrap" style={{ marginTop: 10 }}>
        {['1', '10', '100', '1000'].map((q) => (
          <button key={q} className={`chip ${amount === q ? 'on' : ''}`} onClick={() => setAmount(q)}>
            <span className="lnum">{q}</span>
          </button>
        ))}
      </div>

      <hr className="divider" />
      <div className="section-title">{t(lang, 'results_in')}</div>
      {!snapshot && <div className="dim">…</div>}
      {snapshot &&
        others.map((c) => {
          const v = value(c);
          return (
            <div className="between" key={c} style={{ padding: '7px 0', borderBottom: '1px dashed var(--card-line-soft)' }}>
              <span className="dim row">
                <Flag code={c} /> {lang === 'ar' ? CURRENCIES.find((x) => x.code === c)?.ar : null}{' '}
                <span className="lcode">{c}</span>
              </span>
              {v != null ? <Money value={v} currency={c} /> : <span className="dim">—</span>}
            </div>
          );
        })}
    </div>
  );
}

void currencySymbol;
