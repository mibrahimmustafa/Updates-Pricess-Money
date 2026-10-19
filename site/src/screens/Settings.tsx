import { useMemo, useState } from 'react';
import {
  CURRENCY_BY_CODE,
  CURRENCY_POOL,
  GCC_CURRENCIES,
  MENA_CURRENCIES,
  METALS,
  currencyFlag,
  currencySymbol,
} from '../core/constants';
import { t } from '../core/l10n';
import { useApp } from '../store/useApp';

export function Settings() {
  const lang = useApp((s) => s.prefs.lang);
  const prefs = useApp((s) => s.prefs);
  const s = useApp((a) => a);
  const [filter, setFilter] = useState('');

  const filtered = useMemo(
    () =>
      CURRENCY_POOL.filter(
        (c) =>
          filter === '' ||
          c.includes(filter.toUpperCase()) ||
          (lang === 'ar' && (CURRENCY_BY_CODE[c]?.ar ?? '').includes(filter)),
      ),
    [filter, lang],
  );

  return (
    <>
      {/* language */}
      <div className="card">
        <div className="between">
          <div className="row" style={{ gap: 12 }}>
            <span style={{ fontSize: 20 }}>🌐</span>
            <div>
              <div style={{ fontWeight: 800 }}>{t(lang, 'language')}</div>
              <div className="dim">{lang === 'ar' ? 'العربية' : 'English'}</div>
            </div>
          </div>
          <label className="switch">
            <input
              type="checkbox"
              checked={lang === 'ar'}
              onChange={() => s.toggleLang()}
              aria-label="language"
            />
            <span className="track" />
            <span className="thumb" />
          </label>
        </div>
        <hr className="divider" />
        {/* theme */}
        <div style={{ fontWeight: 800, marginBottom: 8 }}>{t(lang, 'theme')}</div>
        <div className="seg">
          {(['system', 'light', 'dark'] as const).map((mode) => (
            <button
              key={mode}
              className={prefs.theme === mode ? 'on' : ''}
              onClick={() => s.setTheme(mode)}
            >
              {mode === 'system' ? '🖥️' : mode === 'light' ? '☀️' : '🌙'} {t(lang, `theme_${mode}`)}
            </button>
          ))}
        </div>
      </div>

      {/* default currency */}
      <div className="card" style={{ marginTop: 12 }}>
        <div className="section-title">{t(lang, 'default_currency')}</div>
        <div className="dim" style={{ marginBottom: 8 }}>
          {currencySymbol(prefs.defaultQuote)} · {lang === 'ar' ? CURRENCY_BY_CODE[prefs.defaultQuote]?.ar : prefs.defaultQuote}
        </div>
        <div className="chipwrap">
          {prefs.currencies.map((c) => (
            <button
              key={c}
              className={`chip ${prefs.defaultQuote === c ? 'on' : ''}`}
              onClick={() => s.setDefaultQuote(c)}
            >
              <span>{currencyFlag(c)}</span>
              <span className="lcode">{c}</span>
              <span>{currencySymbol(c)}</span>
            </button>
          ))}
        </div>
      </div>

      {/* visible currencies */}
      <div className="card" style={{ marginTop: 12 }}>
        <div className="between" style={{ marginBottom: 8 }}>
          <div className="section-title" style={{ margin: 0 }}>{t(lang, 'choose_currencies')}</div>
          <span className="gold lnum" style={{ fontWeight: 800 }}>
            {prefs.currencies.length} / {CURRENCY_POOL.length}
          </span>
        </div>
        <input
          className="input"
          placeholder={t(lang, 'settings_search')}
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          style={{ marginBottom: 10 }}
        />
        <div className="chipwrap" style={{ marginBottom: 10 }}>
          <button className="chip" onClick={() => s.selectGroup('gcc')}>⚡ {t(lang, 'preset_gcc')}</button>
          <button className="chip" onClick={() => s.selectGroup('mena')}>⚡ {t(lang, 'preset_mena')}</button>
          <button className="chip" onClick={() => s.resetCurrencies()}>↺ {t(lang, 'preset_default')}</button>
        </div>
        <div className="chipwrap">
          {filtered.map((c) => (
            <button
              key={c}
              className={`chip ${prefs.currencies.includes(c) ? 'on' : ''}`}
              onClick={() => s.toggleCurrency(c)}
              title={lang === 'ar' ? CURRENCY_BY_CODE[c]?.ar : undefined}
            >
              {prefs.currencies.includes(c) ? '✓ ' : ''}
              {currencyFlag(c)} <span className="lcode">{c}</span> · {currencySymbol(c)}
            </button>
          ))}
        </div>
      </div>

      {/* visible metals */}
      <div className="card" style={{ marginTop: 12 }}>
        <div className="between" style={{ marginBottom: 8 }}>
          <div className="section-title" style={{ margin: 0 }}>{t(lang, 'choose_assets')}</div>
          <button className="chip" onClick={() => s.resetMetals()}>↺ {t(lang, 'preset_default')}</button>
        </div>
        <div className="chipwrap">
          {Object.entries(METALS).map(([code, m]) => (
            <button
              key={code}
              className={`chip ${prefs.metals.includes(code) ? 'on' : ''}`}
              onClick={() => s.toggleMetal(code)}
            >
              {prefs.metals.includes(code) ? '✓ ' : ''}
              {m.glyph} {lang === 'ar' ? m.nameAr : m.name}
            </button>
          ))}
        </div>
      </div>
    </>
  );
}

void GCC_CURRENCIES;
void MENA_CURRENCIES;
