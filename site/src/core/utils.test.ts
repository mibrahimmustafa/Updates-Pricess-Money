import { describe, it, expect } from 'vitest';
import { convert, moneyParts, perGram, latencyColor, timeAgo } from './utils';
import { currencyFlag, currencySymbol, GRAMS_PER_TROY_OZ, DEFAULT_VISIBLE_CURRENCIES, CURRENCY_POOL } from './constants';

describe('currency conversion (USD hub)', () => {
  it('converts USD→SAR with the real peg-ish input', () => {
    expect(convert(100, 'USD', 'SAR', { SAR: 3.75 })).toBeCloseTo(375);
  });
  it('converts EGP→SAR through USD', () => {
    const rates = { EGP: 50, SAR: 3.75 };
    expect(convert(50, 'EGP', 'SAR', rates)).toBeCloseTo(3.75);
  });
  it('same currency is identity and unknown pair is NaN', () => {
    expect(convert(5, 'EUR', 'EUR', {})).toBe(5);
    expect(Number.isNaN(convert(5, 'XXX', 'EUR', {}))).toBe(true);
  });
});

describe('money formatting is bidi-safe', () => {
  it('digits first then symbol', () => {
    const p = moneyParts(7141.724, 'EGP');
    expect(p.digits).toMatch(/7,141\.72/);
    expect(p.sym).toBe('ج.م');
  });
  it('extra precision under 100', () => {
    expect(moneyParts(3.75, 'SAR').digits).toMatch(/3\.750/);
  });
});

describe('physical constants', () => {
  it('troy ounce conversion', () => {
    expect(perGram(GRAMS_PER_TROY_OZ)).toBeCloseTo(1);
    expect(GRAMS_PER_TROY_OZ).toBeCloseTo(31.1034768);
  });
});

describe('display helpers', () => {
  it('flags derive from ISO codes', () => {
    expect(currencyFlag('EG')).toBeTruthy();
    expect(currencyFlag('EGP')).toBe(currencyFlag('EG'));
    expect(currencyFlag('EUR')).toBe('🇪🇺');
    expect(currencySymbol('EGP')).toBe('ج.م');
  });
  it('defaults cover Arab + world and all are in the pool', () => {
    expect(DEFAULT_VISIBLE_CURRENCIES.length).toBeGreaterThanOrEqual(15);
    for (const c of DEFAULT_VISIBLE_CURRENCIES) expect(CURRENCY_POOL).toContain(c);
  });
  it('latency colors respect thresholds', () => {
    expect(latencyColor(300)).toBe('#66BB6A');
    expect(latencyColor(900)).toBe('#FFB74D');
    expect(latencyColor(3000)).toBe('#E57373');
    expect(latencyColor(null)).toBe('#66BB6A');
  });
  it('timeAgo is branch-stable', () => {
    expect(timeAgo(Date.now() - 5000, 'en')).toBe('now');
    expect(timeAgo(Date.now() - 7000, 'ar')).toBe('الآن');
    expect(timeAgo(Date.now() - 120_000, 'en')).toBe('2m ago');
    expect(timeAgo(Date.now() - 3 * 3600_000, 'ar')).toBe('منذ 3 س');
  });
});
