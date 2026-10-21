import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants.dart';
import '../../../charts/data/models/history_point.dart';
import '../datasources/price_data_sources.dart';
import '../models/exchange_rates.dart';
import '../models/metal_price.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MarketSnapshot
// ─────────────────────────────────────────────────────────────────────────────

/// Backward compatibility alias.
typedef PriceSnapshot = MarketSnapshot;

/// A single immutable snapshot of the full market — every pool metal plus the
/// complete FX rate table — fetched in parallel at one instant in time.
///
/// Screens filter this by user preferences (visible metals, visible currencies).
class MarketSnapshot {
  MarketSnapshot({
    required this.metals,
    ExchangeRates? exchangeRates,
    ExchangeRates? rates,
    DateTime? snapshotTimestamp,
    DateTime? fetchedAt,
  })  : exchangeRates = (exchangeRates ?? rates)!,
        snapshotTimestamp = snapshotTimestamp ?? fetchedAt ?? DateTime.now();

  /// Map of metal symbol → live spot price (per troy ounce in USD).
  final Map<String, MetalPrice> metals;

  /// USD-based FX rates for the full currency pool.
  final ExchangeRates exchangeRates;

  /// The UTC moment at which this snapshot was assembled from the APIs.
  final DateTime snapshotTimestamp;

  /// Backward-compatible getters
  ExchangeRates get rates => exchangeRates;
  DateTime get fetchedAt => snapshotTimestamp;

  // ─── Convenience accessors ─────────────────────────────────────────────────

  /// Looks up a metal by [symbol]. Returns null if the symbol is not in the pool.
  MetalPrice? findMetal(String symbol) => metals[symbol];
  MetalPrice? metal(String symbol) => findMetal(symbol);

  /// Gold spot price. Throws [StateError] if the pool is missing XAU.
  MetalPrice get gold => metals[AppConstants.goldSymbol]!;

  /// Silver spot price. Throws [StateError] if the pool is missing XAG.
  MetalPrice get silver => metals[AppConstants.silverSymbol]!;

  // ─── Serialization ────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'metals': metals.map((key, value) => MapEntry(key, value.toJson())),
        'rates': exchangeRates.toJson(),
        'snapshotTimestamp': snapshotTimestamp.toIso8601String(),
      };

  factory MarketSnapshot.fromJson(Map<String, dynamic> json) {
    final metals = (json['metals'] as Map).cast<String, dynamic>().map(
          (key, value) =>
              MapEntry(key, MetalPrice.fromJson(value as Map<String, dynamic>)),
        );
    final timestampStr = (json['snapshotTimestamp'] ?? json['fetchedAt']) as String;
    return MarketSnapshot(
      metals: metals,
      exchangeRates:
          ExchangeRates.fromJson(json['rates'] as Map<String, dynamic>),
      snapshotTimestamp: DateTime.parse(timestampStr),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PriceRepository
// ─────────────────────────────────────────────────────────────────────────────

/// Coordinates the two remote data sources ([GoldApiDataSource] and
/// [FrankfurterDataSource]) and the local SharedPreferences cache.
///
/// Uses a **stale-while-revalidate** strategy:
///   1. [loadCachedSnapshot] returns any previously saved snapshot instantly.
///   2. [fetchLiveSnapshot] fetches fresh data in the background.
///   3. [saveCachedSnapshot] persists the new snapshot for the next launch.
class PriceRepository {
  PriceRepository({
    GoldApiDataSource? goldApi,
    FrankfurterDataSource? frankfurter,
  })  : _goldApi = goldApi ?? GoldApiDataSource(),
        _frankfurter = frankfurter ?? FrankfurterDataSource();

  final GoldApiDataSource _goldApi;
  final FrankfurterDataSource _frankfurter;

  // ─── Live data ─────────────────────────────────────────────────────────────

  /// Fetches all pool metals + the full FX rate table in parallel.
  ///
  /// All metal requests run concurrently via [Future.wait]. A single FX
  /// request covers all 48 pool currencies in one network call.
  Future<MarketSnapshot> fetchLiveSnapshot() async {
    final parallelResults = await Future.wait([
      for (final symbol in AppConstants.metalPool.keys)
        _goldApi.fetchMetalPrice(symbol),
      _frankfurter.fetchUsdExchangeRates(),
    ]);

    final fxResultIndex = parallelResults.length - 1;
    final metals = <String, MetalPrice>{
      for (var i = 0; i < AppConstants.metalPool.length; i++)
        AppConstants.metalPool.keys.elementAt(i): parallelResults[i]
            as MetalPrice,
    };

    return MarketSnapshot(
      metals: metals,
      exchangeRates: parallelResults[fxResultIndex] as ExchangeRates,
      snapshotTimestamp: DateTime.now(),
    );
  }

  /// Backward-compatible alias for fetchLiveSnapshot.
  Future<MarketSnapshot> fetchSnapshot() => fetchLiveSnapshot();

  // ─── Historical data ───────────────────────────────────────────────────────

  /// Fetches daily per-gram price history for [metalSymbol] vs
  /// [quoteCurrencyCode] over the last [periodDays] days.
  Future<List<HistoricalDataPoint>> fetchPriceHistory({
    required String metalSymbol,
    required String quoteCurrencyCode,
    required int periodDays,
  }) {
    return _frankfurter.fetchMetalPriceHistory(
      metalSymbol: metalSymbol,
      quoteCurrencyCode: quoteCurrencyCode,
      periodDays: periodDays,
    );
  }

  /// Backward-compatible alias for fetchPriceHistory.
  Future<List<HistoricalDataPoint>> fetchHistory(
    String symbol,
    String quote,
    int days,
  ) {
    return fetchPriceHistory(
      metalSymbol: symbol,
      quoteCurrencyCode: quote,
      periodDays: days,
    );
  }

  /// Fetches daily per-gram price history for [metalSymbol] vs
  /// [quoteCurrencyCode] between [fromDate] and [toDate] (inclusive).
  Future<List<HistoricalDataPoint>> fetchPriceHistoryRange({
    required String metalSymbol,
    required String quoteCurrencyCode,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    return _frankfurter.fetchMetalPriceHistoryRange(
      metalSymbol: metalSymbol,
      quoteCurrencyCode: quoteCurrencyCode,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  /// Backward-compatible alias for fetchPriceHistoryRange.
  Future<List<HistoricalDataPoint>> fetchHistoryRange(
    String symbol,
    String quote,
    DateTime from,
    DateTime to,
  ) {
    return fetchPriceHistoryRange(
      metalSymbol: symbol,
      quoteCurrencyCode: quote,
      fromDate: from,
      toDate: to,
    );
  }

  /// Fetches official Central Bank of Egypt (CBE) USD-based exchange rates.
  Future<List<HistoricalDataPoint>> fetchCentralBankRates() {
    return _frankfurter.fetchCentralBankRates();
  }

  /// Backward-compatible alias for fetchCentralBankRates.
  Future<List<HistoricalDataPoint>> fetchCbeRates() => fetchCentralBankRates();

  // ─── Local cache ───────────────────────────────────────────────────────────

  /// Loads the previously cached [MarketSnapshot] from local storage.
  /// Returns null on first launch or if the cache is corrupt.
  Future<MarketSnapshot?> loadCachedSnapshot() async {
    final rawJson = await SharedPreferencesAsync().getString(
      AppConstants.cacheKey,
    );
    if (rawJson == null) return null;
    try {
      return MarketSnapshot.fromJson(
          jsonDecode(rawJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Backward-compatible alias for loadCachedSnapshot.
  Future<MarketSnapshot?> loadCached() => loadCachedSnapshot();

  /// Serializes [snapshot] and persists it to local storage.
  Future<void> saveCachedSnapshot(MarketSnapshot snapshot) async {
    await SharedPreferencesAsync().setString(
      AppConstants.cacheKey,
      jsonEncode(snapshot.toJson()),
    );
  }

  /// Backward-compatible alias for saveCachedSnapshot.
  Future<void> saveCached(MarketSnapshot snapshot) =>
      saveCachedSnapshot(snapshot);
}
