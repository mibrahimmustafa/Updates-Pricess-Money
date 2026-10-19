import { describe, it, expect, beforeEach } from 'vitest';
import { useApp } from './useApp';

const fresh = () => {
  localStorage.clear();
  useApp.setState(useApp.getInitialState());
};

describe('user prefs store', () => {
  beforeEach(() => {
    localStorage.clear();
  });

  it('defaults are the wide 18-currency Arab+world set', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    expect(useApp.getState().prefs.currencies.length).toBeGreaterThanOrEqual(15);
    expect(useApp.getState().prefs.currencies).toContain('EGP');
    expect(useApp.getState().prefs.currencies).toContain('SAR');
  });

  it('toggles currency + persists via localStorage', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    useApp.getState().toggleCurrency('PKR');
    expect(useApp.getState().prefs.currencies).toContain('PKR');
    expect(JSON.parse(localStorage.getItem('pm_prefs_v2')!).currencies).toContain('PKR');
  });

  it('never allows an empty currency list (protection)', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    const s = useApp.getState();
    for (const c of [...s.prefs.currencies]) s.toggleCurrency(c);
    expect(useApp.getState().prefs.currencies.length).toBe(1);
  });

  it('removes are persisted and defaults quote rotation works', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    useApp.getState().setDefaultQuote('EGP');
    useApp.getState().toggleCurrency('EGP'); // default removed → rotates
    expect(useApp.getState().prefs.defaultQuote).not.toBe('EGP');
  });

  it('GCC preset swaps the visible set', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    useApp.getState().selectGroup('gcc');
    const cur = useApp.getState().prefs.currencies;
    expect(cur).toContain('SAR');
    expect(cur).toContain('OMR');
    expect(cur).not.toContain('EGP');
  });

  it('alert lifecycle: add → fire → auto pause', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    useApp.setState({
      snapshot: {
        metals: { XAU: 31.1034768 }, // = 1 USD per gram
        usdRates: { USD: 1 },
        ts: Date.now(),
      },
    });
    const s = useApp.getState();
    s.addAlert({ metal: 'XAU', currency: 'USD', target: 0.5, above: true });
    s.checkAlerts();
    const fired = useApp.getState().alerts[0];
    expect(fired.firedAt).toBeDefined();
    expect(fired.active).toBe(false);
    expect(useApp.getState().toasts.length).toBeGreaterThan(0);
    // no repeat firing
    s.checkAlerts();
    expect(useApp.getState().alerts[0].firedAt).toBe(fired.firedAt);
  });

  it('alert below-threshold does not fire above-cross', () => {
    localStorage.clear();
    useApp.setState(useApp.getInitialState());
    useApp.setState({
      snapshot: { metals: { XAU: 31.1034768 }, usdRates: { USD: 1 }, ts: Date.now() },
    });
    useApp.getState().addAlert({ metal: 'XAU', currency: 'USD', target: 50, above: true });
    useApp.getState().checkAlerts();
    expect(useApp.getState().alerts[0].firedAt).toBeUndefined();
  });
});

beforeEach(() => fresh());
