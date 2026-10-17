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

  /// Fetches `GET /rates?base=USD&quotes=SAR,EGP`.
  ///
  /// Frankfurter v2 returns an **array** of `{date, base, quote, rate}`
  /// objects (some deployments may still return a legacy map), so handle
  /// both shapes defensively.
  Future<ExchangeRates> getUsdRates() async {
    final res = await _dio.get<dynamic>(
      '/rates',
      queryParameters: {
        'base': AppConstants.usd,
        'quotes': '${AppConstants.sar},${AppConstants.egp}',
      },
    );

    double? sar;
    double? egp;
    DateTime? date;

    void readRate(Map<String, dynamic> entry) {
      final quote = entry['quote'] as String?;
      final rate = (entry['rate'] as num?)?.toDouble();
      if (quote == null || rate == null) return;
      final entryDate = entry['date'] is String
          ? DateTime.parse(entry['date'] as String)
          : null;
      date ??= entryDate;
      if (quote == AppConstants.sar) sar = rate;
      if (quote == AppConstants.egp) egp = rate;
    }

    final data = res.data;
    if (data is List) {
      for (final entry in data) {
        readRate((entry as Map).cast<String, dynamic>());
      }
    } else if (data is Map) {
      final map = data.cast<String, dynamic>();
      final rates = map['rates'];
      if (rates is Map) {
        for (final e in rates.entries) {
          readRate({
            'quote': e.key,
            'rate': e.value,
            'date': map['date'],
          });
        }
      }
    }

    if (sar == null || egp == null) {
      throw StateError('Frankfurter response missing SAR/EGP rates');
    }
    return ExchangeRates(
      usdToSar: sar!,
      usdToEgp: egp!,
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
  }) async {
    final from = DateTime.now().subtract(Duration(days: days));
    final res = await _dio.get<List<dynamic>>(
      '/rates',
      queryParameters: {
        'base': symbol,
        'quotes': quote,
        'from': '${from.year}-${from.month.toString().padLeft(2, '0')}-'
            '${from.day.toString().padLeft(2, '0')}',
      },
    );
    final points = (res.data ?? [])
        .cast<Map>()
        .map((e) => HistoryPoint.fromJson(e.cast<String, dynamic>()))
        .toList();
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
