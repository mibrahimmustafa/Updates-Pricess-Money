export type PriceSnapshot = {
  /** metal symbol → USD price per troy ounce. */
  metals: Record<string, number>;
  /** quote currency → units per 1 USD. */
  usdRates: Record<string, number>;
  /** epoch ms of the fetch. */
  ts: number;
};

export type SeriesPoint = { date: string; value: number };
