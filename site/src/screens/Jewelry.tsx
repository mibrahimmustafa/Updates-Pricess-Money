import { useMemo, useState } from 'react';
import {
  DEFAULT_VISIBLE_CURRENCIES,
  GCC_CURRENCIES,
  KARATS,
  MENA_CURRENCIES,
  METALS,
  VAT_RATE,
  CURRENCIES,
  CURRENCY_POOL,
} from '../core/constants';
import { t, type Lang } from '../core/l10n';
import { useApp } from '../store/useApp';
import { perGram } from '../core/utils';

export function Jewelry() {
  const lang = useApp((s) => s.prefs.lang);
  const snapshot = useApp((s) => s.snapshot);
  const defaultQuote = useApp((s) => s.prefs.defaultQuote);
  const currencies = useApp((s) => s.prefs.currencies);

  const quoteOptions = useMemo(
    () => (currencies.includes(defaultQuote) ? currencies : [...currencies, defaultQuote]),
    [currencies, defaultQuote],
  );

  const [quote, setQuote] = useState(defaultQuote);
  const [weight, setWeight] = useState('10');
  const [karat, setKarat] = useState('21K');
  const [fee, setFee] = useState('60');
  const [vat, setVat] = useState(true);
  const [oldWeight, setOldWeight] = useState('0');

  const oz = snapshot?.metals.XAU ?? NaN;
  const rate = quote === 'USD' ? 1 : snapshot?.usdRates[quote] ?? NaN;
  const w = parseFloat(weight) || 0;
  const f = parseFloat(fee) || 0;
  const ow = parseFloat(oldWeight) || 0;
  const purity = KARATS[karat] ?? 1;
  const gramPrice = perGram(oz) * rate;

  const goldCost = gramPrice * w * purity;
  const mfg = f * w;
  const sub = goldCost + mfg;
  const vatValue = vat ? sub * VAT_RATE : 0;
  const oldCredit = gramPrice * ow * purity;
  const total = sub + vatValue - oldCredit;

  const L = (k: string) => t(lang, k);
  const num = (n: number) => n.toLocaleString('en', { maximumFractionDigits: 2, minimumFractionDigits: 2 });

  return (
    <div className="card" style={{ maxWidth: 560, marginInline: 'auto' }}>
      <div className="section-title">{L('calc_title')}</div>

      {!snapshot || Number.isNaN(gramPrice) ? (
        <div className="dim">… {L('live')}</div>
      ) : (
        <>
          <div className="row wrap" style={{ gap: 14, alignItems: 'flex-end' }}>
            <div style={{ flex: 1, minWidth: 130 }}>
              <label className="label">{L('weight')}</label>
              <input className="input lnum" inputMode="decimal" value={weight}
                onChange={(e) => setWeight(e.target.value.replace(/[^\d.]/g, ''))} />
            </div>
            <div style={{ flex: 1, minWidth: 130 }}>
              <label className="label">{L('karat')}</label>
              <select className="input" value={karat} onChange={(e) => setKarat(e.target.value)}>
                {Object.keys(KARATS).map((k) => <option key={k}>{k}</option>)}
              </select>
            </div>
            <div style={{ flex: 1, minWidth: 130 }}>
              <label className="label">{L('mfg_fee_per_gram')}</label>
              <input className="input lnum" inputMode="decimal" value={fee}
                onChange={(e) => setFee(e.target.value.replace(/[^\d.]/g, ''))} />
            </div>
          </div>

          <div style={{ height: 12 }} />
          <div className="row wrap" style={{ gap: 14, alignItems: 'center' }}>
            <div>
              <label className="label">{L('quote_display')}</label>
              <select className="input" value={quote} onChange={(e) => setQuote(e.target.value)} style={{ minWidth: 150 }}>
                {quoteOptions.map((c) => (
                  <option key={c} value={c}>{c}</option>
                ))}
              </select>
            </div>
            <label className="row" style={{ gap: 10, cursor: 'pointer' }}>
              <span className="switch">
                <input type="checkbox" checked={vat} onChange={(e) => setVat(e.target.checked)} />
                <span className="track" /><span className="thumb" />
              </span>
              <span style={{ fontSize: 13, fontWeight: 700 }}>{L('vat')}</span>
            </label>
          </div>

          <div style={{ height: 12 }} />
          <div className="row wrap" style={{ gap: 14 }}>
            <div style={{ flex: 1, minWidth: 130 }}>
              <label className="label">{L('moyaval_weight')}</label>
              <input className="input lnum" inputMode="decimal" value={oldWeight}
                onChange={(e) => setOldWeight(e.target.value.replace(/[^\d.]/g, ''))} />
            </div>
            <div style={{ minWidth: 150 }}>
              <span className="label">{L('gram_price_now')}</span>
              <div className="total-line lnum">{num(gramPrice)} {quote}</div>
            </div>
          </div>

          <hr className="divider" />
          <table className="rate">
            <tbody>
              <tr><td className="dim">{L('metal_cost')}</td><td>{num(goldCost)} {quote}</td></tr>
              <tr><td className="dim">{L('mfg_total')}</td><td>{num(mfg)} {quote}</td></tr>
              {vat && <tr><td className="dim">{L('vat')}</td><td>{num(vatValue)} {quote}</td></tr>}
              {ow > 0 && <tr><td className="dim" style={{ color: 'var(--ok)' }}>{L('old_gold_credit')} −</td><td style={{ color: 'var(--ok)' }}>− {num(oldCredit)} {quote}</td></tr>}
            </tbody>
          </table>
          <div className="between" style={{ marginTop: 14 }}>
            <span className="dim" style={{ fontSize: 13, fontWeight: 700 }}>{L('total_title')}</span>
            <span className="total-big lnum">{num(total < 0 ? 0 : total)} {quote}</span>
          </div>
        </>
      )}
    </div>
  );
}

void DEFAULT_VISIBLE_CURRENCIES;
void GCC_CURRENCIES;
void MENA_CURRENCIES;
void METALS;
void CURRENCIES;
void CURRENCY_POOL;
void t as unknown as Lang;
