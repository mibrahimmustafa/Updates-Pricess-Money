import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../datasources/price_data_sources.dart';
import '../models/history_point.dart';
import '../models/exchange_rates.dart';
import '../models/metal_price.dart';

/// Combined snapshot shown across screens: every pool metal + every
/// pool currency rate in one object; screens filter by user prefs.
class PriceSnapshot {
  const PriceSnapshot({
    required this.metals,
    required this.rates,
    required this.fetchedAt,
  });

  /// symbol → live price (per troy ounce, USD)
  final Map<String, MetalPrice> metals;
  final ExchangeRates rates;
  final DateTime fetchedAt;

  MetalPrice? metal(String symbol) => metals[symbol];
  MetalPrice get gold => metals[AppConstants.goldSymbol]!;
  MetalPrice get silver => metals[AppConstants.silverSymbol]!;

  Map<String, dynamic> toJson() => {
        'metals': metals.map((k, v) => MapEntry(k, v.toJson())),
        'rates': rates.toJson(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    final metals = (json['metals'] as Map).cast<String, dynamic>().map(
          (k, v) => MapEntry(k, MetalPrice.fromJson(v as Map<String, dynamic>)),
        );
    return PriceSnapshot(
      metals: metals,
      rates: ExchangeRates.fromJson(json['rates'] as Map<String, dynamic>),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

class PriceRepository {
  PriceRepository({
    GoldApiDataSource? goldApi,
    FrankfurterDataSource? frankfurter,
  })  : _goldApi = goldApi ?? GoldApiDataSource(),
        _frankfurter = frankfurter ?? FrankfurterDataSource();

  final GoldApiDataSource _goldApi;
  final FrankfurterDataSource _frankfurter;

  /// Fetches every pool metal + the whole FX pool in parallel.
  Future<PriceSnapshot> fetchSnapshot() async {
    final results = await Future.wait([
      for (final symbol in AppConstants.metalPool.keys)
        _goldApi.getMetalPrice(symbol),
      _frankfurter.getUsdRates(),
    ]);

    final fxIndex = results.length - 1;
    final metals = <String, MetalPrice>{
      for (var i = 0; i < AppConstants.metalPool.length; i++)
        AppConstants.metalPool.keys.elementAt(i): results[i] as MetalPrice,
    };

    return PriceSnapshot(
      metals: metals,
      rates: results[fxIndex] as ExchangeRates,
      fetchedAt: DateTime.now(),
    );
  }

  Future<List<HistoryPoint>> fetchHistory(
    String symbol,
    String quote,
    int days,
  ) {
    return _frankfurter.getMetalHistory(
        symbol: symbol, quote: quote, days: days);
  }

  /// Historical rates for an explicit inclusive date range.
  Future<List<HistoryPoint>> fetchHistoryRange(
    String symbol,
    String quote,
    DateTime from,
    DateTime to,
  ) {
    return _frankfurter.getMetalHistoryRange(
      symbol: symbol,
      quote: quote,
      from: from,
      to: to,
    );
  }

  /// CBE (Central Bank of Egypt) official USD-based rates.
  Future<List<HistoryPoint>> fetchCbeRates() {
    return _frankfurter.getCbeUsdRates();
  }

  /// Stale-while-revalidate cache: show last data instantly while refreshing.
  Future<PriceSnapshot?> loadCached() async {
    final raw = await SharedPreferencesAsync().getString(
      AppConstants.cacheKey,
    );
    if (raw == null) return null;
    try {
      return PriceSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCached(PriceSnapshot snapshot) async {
    await SharedPreferencesAsync().setString(
      AppConstants.cacheKey,
      jsonEncode(snapshot.toJson()),
    );
  }
}
