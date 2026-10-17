import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../models/history_point.dart';
import '../models/exchange_rates.dart';
import '../models/metal_price.dart';
import '../datasources/price_data_sources.dart';

/// Combined snapshot shown on the home screen.
class PriceSnapshot {
  const PriceSnapshot({
    required this.gold,
    required this.silver,
    required this.rates,
    required this.fetchedAt,
  });

  final MetalPrice gold;
  final MetalPrice silver;
  final ExchangeRates rates;
  final DateTime fetchedAt;

  Map<String, dynamic> toJson() => {
        'gold': gold.toJson(),
        'silver': silver.toJson(),
        'usdToSar': rates.usdToSar,
        'usdToEgp': rates.usdToEgp,
        'ratesDate': rates.date.toIso8601String(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    final rates = ExchangeRates(
      usdToSar: (json['usdToSar'] as num).toDouble(),
      usdToEgp: (json['usdToEgp'] as num).toDouble(),
      date: DateTime.parse(json['ratesDate'] as String),
    );
    return PriceSnapshot(
      gold: MetalPrice.fromJson(json['gold'] as Map<String, dynamic>),
      silver: MetalPrice.fromJson(json['silver'] as Map<String, dynamic>),
      rates: rates,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

class PriceRepository {  PriceRepository({
    GoldApiDataSource? goldApi,
    FrankfurterDataSource? frankfurter,
  })  : _goldApi = goldApi ?? GoldApiDataSource(),
        _frankfurter = frankfurter ?? FrankfurterDataSource();

  final GoldApiDataSource _goldApi;
  final FrankfurterDataSource _frankfurter;

  final _prefs = SharedPreferencesAsync();

  /// Fetches metals + FX in parallel.
  Future<PriceSnapshot> fetchSnapshot() async {
    final results = await Future.wait([
      _goldApi.getMetalPrice(AppConstants.goldSymbol),
      _goldApi.getMetalPrice(AppConstants.silverSymbol),
      _frankfurter.getUsdRates(),
    ]);
    return PriceSnapshot(
      gold: results[0] as MetalPrice,
      silver: results[1] as MetalPrice,
      rates: results[2] as ExchangeRates,
      fetchedAt: DateTime.now(),
    );
  }

  Future<List<HistoryPoint>> fetchHistory(
    String symbol,
    String quote,
    int days,
  ) {
    return _frankfurter.getMetalHistory(symbol: symbol, quote: quote, days: days);
  }

  /// Stale-while-revalidate cache: show last data instantly while refreshing.
  Future<PriceSnapshot?> loadCached() async {
    final raw = await _prefs.getString(AppConstants.cacheKey);
    if (raw == null) return null;
    try {
      return PriceSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCached(PriceSnapshot snapshot) async {
    await _prefs.setString(
      AppConstants.cacheKey,
      jsonEncode(snapshot.toJson()),
    );
  }
}
