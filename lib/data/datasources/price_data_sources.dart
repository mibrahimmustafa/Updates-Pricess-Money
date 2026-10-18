import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../models/exchange_rates.dart';
import '../models/history_point.dart';
import '../models/metal_price.dart';

/// Remote data sources for the two free APIs.
class GoldApiDataSource {
  GoldApiDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.goldApiBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'User-Agent': 'PricessMoneyApp/1.0'},
            ));

  final Dio _dio;

  static const _maxAttempts = 3;
  static const _retryDelay = Duration(seconds: 2);

  /// Fetches one metal price with simple retry on 429/transient errors.
  Future<MetalPrice> getMetalPrice(String symbol) async {
    var lastError = Exception('unknown error');
    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final res = await _dio.get<Map<String, dynamic>>('/price/$symbol');
        return MetalPrice.fromJson(res.data!);
      } on DioException catch (e) {
        lastError = e;
        final status = e.response?.statusCode ?? 0;
        final retryable = status == 429 || status >= 500 || status == 0;
        if (!retryable || attempt == _maxAttempts) rethrow;
        await Future<void>.delayed(_retryDelay * attempt);
      }
    }
    throw lastError;
  }
}

class FrankfurterDataSource {
  FrankfurterDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.frankfurterBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  /// Fetches USD → all requested pool currency rates:
  /// `GET /rates?base=USD&quotes=SAR,EGP,EUR,...`
  /// Frankfurter v2 returns an **array** of `{date, base, quote, rate}`.
  Future<ExchangeRates> getUsdRates({List<String>? quotes}) async {
    final list = quotes ?? AppConstants.currencyPool.keys.toList();
    final res = await _dio.get<List<dynamic>>(
      '/rates',
      queryParameters: {
        'base': AppConstants.usd,
        'quotes': list.join(','),
      },
    );

    final rates = <String, double>{AppConstants.usd: 1.0};
    DateTime? date;

    for (final entry in (res.data ?? []).cast<Map>()) {
      final map = entry.cast<String, dynamic>();
      final quote = map['quote'] as String?;
      final rate = (map['rate'] as num?)?.toDouble();
      if (quote == null || rate == null) continue;
      rates[quote] = rate;
      date ??=
          map['date'] is String ? DateTime.parse(map['date'] as String) : null;
    }

    if (rates[AppConstants.sar] == null ||
        rates[AppConstants.egp] == null) {
      throw StateError('Frankfurter response missing SAR/EGP rates');
    }
    return ExchangeRates(
      usdRates: rates,
      date: date ?? DateTime.now(),
    );
  }

  /// Historical daily rates for one metal/quote pair (e.g. XAU vs EGP).
  ///
  /// Example response for `GET /rates?base=XAU&quotes=EGP&from=2026-10-13`:
  /// `[{"date":"2026-10-13","base":"XAU","quote":"EGP","rate":220284}, ...]`
  Future<List<HistoryPoint>> getMetalHistory({
    required String symbol,
    required String quote,
    required int days,
  }) =>
      getMetalHistoryRange(
        symbol: symbol,
        quote: quote,
        from: DateTime.now().subtract(Duration(days: days)),
        to: DateTime.now(),
      );

  /// Historical daily rates for an explicit date range (inclusive).
  Future<List<HistoryPoint>> getMetalHistoryRange({
    required String symbol,
    required String quote,
    required DateTime from,
    DateTime? to,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/rates',
      queryParameters: {
        'base': symbol,
        'quotes': quote,
        'from': _isoDate(from),
        if (to != null) 'to': _isoDate(to),
      },
    );
    final points = (res.data ?? [])
        .cast<Map>()
        .map((e) => HistoryPoint.fromJson(e.cast<String, dynamic>()))
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  /// Central Bank of Egypt official daily rates (base USD).
  ///
  /// `GET /providers/cbe/rates?base=USD` returns entries like
  /// `{"date":"2026-10-15","base":"USD","quote":"EGP","rate":53.4614}`.
  Future<List<HistoryPoint>> getCbeUsdRates() async {
    final res = await _dio.get<List<dynamic>>(
      '/providers/cbe/rates',
      queryParameters: {'base': AppConstants.usd},
    );
    final points = (res.data ?? [])
        .cast<Map>()
        .map((e) => HistoryPoint.fromJson(e.cast<String, dynamic>()))
        .toList();
    points.sort((a, b) => (a.quote ?? '').compareTo(b.quote ?? ''));
    return points;
  }

  /// One fetch: rates of [base] against many [quotes], for the FX converter.
  /// Accepts both Frankfurter v2 array rows and legacy map formats.
  Future<Map<String, double>> getFxFamily({
    required String base,
    required List<String> quotes,
  }) async {
    final res = await _dio.get<dynamic>(
      '/rates',
      queryParameters: {'base': base, 'quotes': quotes.join(',')},
    );
    final out = <String, double>{};

    void read(Map<String, dynamic> e) {
      final q = e['quote'] as String?;
      final r = (e['rate'] as num?)?.toDouble();
      if (q != null && r != null) out[q] = r;
    }

    final data = res.data;
    if (data is List) {
      for (final e in data) {
        read((e as Map).cast<String, dynamic>());
      }
    } else if (data is Map && data['rates'] is Map) {
      ((data['rates'] as Map).cast<String, dynamic>()).forEach((q, v) {
        final r = (v as num?)?.toDouble();
        if (r != null) out[q] = r;
      });
    }
    return out;
  }

  static String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
