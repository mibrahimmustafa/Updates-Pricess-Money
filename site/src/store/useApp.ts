import { create } from 'zustand';
import {
  DEFAULT_VISIBLE_CURRENCIES,
  DEFAULT_VISIBLE_METALS,
  GCC_CURRENCIES,
  GRAMS_PER_TROY_OZ,
  MENA_CURRENCIES,
  CURRENCY_POOL,
  METALS,
} from '../core/constants';
import type { Lang } from '../core/l10n';
import { perGram } from '../core/utils';
import {
  fetchSnapshot,
  loadCachedSnapshot,
  saveCachedSnapshot,
} from '../data/api';
import type { PriceSnapshot } from '../data/types';
import { currencySymbol } from '../core/constants';

// ---------- persistence ----------
const PREFS_KEY = 'pm_prefs_v2';

type Prefs = {
  currencies: string[];
  metals: string[];
  defaultQuote: string;
  lang: Lang;
  theme: 'system' | 'light' | 'dark';
};

function defaultPrefs(): Prefs {
  const region =
    (typeof navigator !== 'undefined' && navigator.language) || 'ar-EG';
  const fallbackQuote =
    region.includes('EG') ? 'EGP' : region.includes('SA') ? 'SAR'
    : CURRENCY_POOL.includes(region.split('-')[1]?.toUpperCase() ?? '')
      ? region.split('-')[1].toUpperCase()
      : 'EGP';
  return {
    currencies: [...DEFAULT_VISIBLE_CURRENCIES],
    metals: [...DEFAULT_VISIBLE_METALS],
    defaultQuote: fallbackQuote,
    lang: 'ar',
    theme: 'dark',
  };
}

function loadPrefs(): Prefs {
  try {
    const raw = localStorage.getItem(PREFS_KEY);
    if (!raw) return defaultPrefs();
    const p = JSON.parse(raw) as Partial<Prefs>;
    const d = defaultPrefs();
    return {
      currencies:
        Array.isArray(p.currencies) &&
        p.currencies.every((c) => CURRENCY_POOL.includes(c)) &&
        p.currencies.length > 0
          ? p.currencies
          : d.currencies,
      metals:
        Array.isArray(p.metals) &&
        p.metals.every((m) => m in METALS) &&
        p.metals.length > 0
          ? p.metals
          : d.metals,
      defaultQuote:
        p.defaultQuote && CURRENCY_POOL.includes(p.defaultQuote)
          ? p.defaultQuote
          : d.defaultQuote,
      lang: p.lang === 'en' ? 'en' : 'ar',
      theme: p.theme === 'light' || p.theme === 'dark' ? p.theme : 'system',
    };
  } catch {
    return defaultPrefs();
  }
}

// ---------- alerts ----------
export type PriceAlert = {
  id: string;
  metal: string; // symbol
  currency: string;
  target: number; // per gram
  above: boolean;
  active: boolean;
  firedAt?: number;
};

export type Toast = { id: number; text: string; kind: 'info' | 'alert' };

type AppStore = {
  // preferences
  prefs: Prefs;
  setLang(lang: Lang): void;
  toggleLang(): void;
  setTheme(theme: Prefs['theme']): void;
  toggleTheme(): void;
  toggleCurrency(code: string): void;
  toggleMetal(code: string): void;
  selectGroup(group: 'gcc' | 'mena'): void;
  resetCurrencies(): void;
  resetMetals(): void;
  setDefaultQuote(code: string): void;

  // live data
  snapshot: PriceSnapshot | null;
  loading: boolean;
  error: string | null;
  latencyMs: number | null;
  refresh(silent?: boolean): Promise<void>;

  // alerts
  alerts: PriceAlert[];
  addAlert(a: Omit<PriceAlert, 'id' | 'active' | 'firedAt'>): void;
  toggleAlert(id: string): void;
  removeAlert(id: string): void;
  checkAlerts(): void;

  // toasts
  toasts: Toast[];
  pushToast(text: string, kind?: Toast['kind']): void;
  dismissToast(id: number): void;
};

function persist(p: Prefs): void {
  try {
    localStorage.setItem(PREFS_KEY, JSON.stringify(p));
  } catch {
    /* ignore */
  }
}

export const useApp = create<AppStore>((set, get) => {
  const initialPrefs = loadPrefs();
  const savedAlerts: PriceAlert[] = (() => {
    try {
      return JSON.parse(localStorage.getItem('pm_alerts_v1') ?? '[]');
    } catch {
      return [];
    }
  })();

  const saveAlerts = (list: PriceAlert[]) => {
    try {
      localStorage.setItem('pm_alerts_v1', JSON.stringify(list));
    } catch {
      /* ignore */
    }
  };

  return {
    prefs: initialPrefs,
    setLang: (lang) => set({ prefs: { ...get().prefs, lang } }),
    toggleLang: () => set({ prefs: { ...get().prefs, lang: get().prefs.lang === 'ar' ? 'en' : 'ar' } }),
    setTheme: (theme) => set({ prefs: { ...get().prefs, theme } }),
    toggleTheme: () =>
      set({
        prefs: { ...get().prefs, theme: get().prefs.theme === 'dark' ? 'light' : 'dark' },
      }),
    toggleCurrency: (code) => {
      const p = get().prefs;
      const next = p.currencies.includes(code)
        ? p.currencies.filter((c) => c !== code)
        : [...p.currencies, code];
      if (next.length === 0) return; // never empty the list
      const updated = { ...p, currencies: next };
      // default quote must stay visible
      if (!next.includes(p.defaultQuote)) updated.defaultQuote = next[0];
      set({ prefs: updated });
      persist(updated);
    },
    toggleMetal: (code) => {
      const p = get().prefs;
      const next = p.metals.includes(code)
        ? p.metals.filter((m) => m !== code)
        : [...p.metals, code];
      if (next.length === 0) return;
      const updated = { ...p, metals: next };
      set({ prefs: updated });
      persist(updated);
    },
    selectGroup: (group) => {
      const codes = group === 'gcc' ? GCC_CURRENCIES : MENA_CURRENCIES;
      const p = get().prefs;
      const updated = { ...p, currencies: [...codes] };
      if (!codes.includes(p.defaultQuote)) updated.defaultQuote = codes[0];
      set({ prefs: updated });
      persist(updated);
    },
    resetCurrencies: () => {
      const p = get().prefs;
      const updated = {
        ...p,
        currencies: [...DEFAULT_VISIBLE_CURRENCIES],
        defaultQuote: DEFAULT_VISIBLE_CURRENCIES.includes('EGP')
          ? 'EGP'
          : DEFAULT_VISIBLE_CURRENCIES[0],
      };
      set({ prefs: updated });
      persist(updated);
    },
    resetMetals: () => {
      const updated = { ...get().prefs, metals: [...DEFAULT_VISIBLE_METALS] };
      set({ prefs: updated });
      persist(updated);
    },
    setDefaultQuote: (code) => {
      const updated = { ...get().prefs, defaultQuote: code };
      set({ prefs: updated });
      persist(updated);
    },

    snapshot: loadCachedSnapshot(),
    loading: false,
    error: null,
    latencyMs: null,

    refresh: async (silent = false) => {
      if (!silent && get().loading) return;
      set({ loading: true, error: null });
      try {
        const { snapshot, latencyMs } = await fetchSnapshot();
        saveCachedSnapshot(snapshot);
        set({ snapshot, latencyMs, loading: false, error: null });
        get().checkAlerts();
      } catch {
        set({
          loading: false,
          error: 'network',
        });
      }
    },

    alerts: savedAlerts,
    addAlert: (a) => {
      const alert: PriceAlert = { ...a, id: crypto.randomUUID(), active: true };
      const next = [alert, ...get().alerts];
      set({ alerts: next });
      saveAlerts(next);
    },
    toggleAlert: (id) => {
      const next = get().alerts.map((a) =>
        a.id === id ? { ...a, active: !a.active, firedAt: undefined } : a,
      );
      set({ alerts: next });
      saveAlerts(next);
    },
    removeAlert: (id) => {
      const next = get().alerts.filter((a) => a.id !== id);
      set({ alerts: next });
      saveAlerts(next);
    },
    checkAlerts: () => {
      const snap = get().snapshot;
      if (!snap) return;
      let fired = false;
      const next = get().alerts.map((a) => {
        if (!a.active || a.firedAt) return a;
        const oz = snap.metals[a.metal];
        if (!oz || Number.isNaN(oz)) return a;
        const gramInCur =
          (oz / GRAMS_PER_TROY_OZ) * (a.currency === 'USD' ? 1 : (snap.usdRates[a.currency] ?? NaN));
        const price = perGram(oz) * (a.currency === 'USD' ? 1 : (snap.usdRates[a.currency] ?? NaN));
        const value = a.currency === 'USD' ? price : gramInCur;
        if (Number.isNaN(value)) return a;
        const hit = a.above ? value >= a.target : value <= a.target;
        if (!hit) return a;
        fired = true;
        get().pushToast(
          `${METALS[a.metal]?.nameAr ?? a.metal} ${a.above ? 'تجاوز' : 'هبط تحت'} ${a.target} ${currencySymbol(a.currency)}`,
          'alert',
        );
        return { ...a, firedAt: Date.now(), active: false };
      });
      if (fired) {
        set({ alerts: next });
        saveAlerts(next);
      }
    },

    toasts: [],
    pushToast: (text, kind = 'info') => {
      const id = Date.now() + Math.random();
      set({ toasts: [...get().toasts, { id, text, kind }] });
      setTimeout(() => get().dismissToast(id), 5000);
    },
    dismissToast: (id) => set({ toasts: get().toasts.filter((t) => t.id !== id) }),
  };
});

/** Convenience selectors */
export const visibleCurrencies = (s: AppStore) => s.prefs.currencies;
export const visibleMetals = (s: AppStore) => s.prefs.metals;
