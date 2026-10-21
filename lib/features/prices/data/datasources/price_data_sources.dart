import 'package:dio/dio.dart';

import '../../../../core/constants.dart';
import '../../../charts/data/models/history_point.dart';
import '../models/exchange_rates.dart';
import '../models/metal_price.dart';

/// Fetches live metal spot prices from [https://api.gold-api.com].
class GoldApiDataSource {
  GoldApiDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.goldApiBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'User-Agent': 'DahabLiveApp/1.0'},
            ));

  final Dio _dio;

  static const int _maxRetryAttempts = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 2);

  Future<MetalPrice> fetchMetalPrice(String metalSymbol) async {
    var lastError = Exception('Unknown network error');
    for (var attempt = 1; attempt <= _maxRetryAttempts; attempt++) {
      try {
        final response =
            await _dio.get<Map<String, dynamic>>('/price/$metalSymbol');
        return MetalPrice.fromJson(response.data!);
      } on DioException catch (error) {
        lastError = error;
        final statusCode = error.response?.statusCode ?? 0;
        final isRetryable =
            statusCode == 429 || statusCode >= 500 || statusCode == 0;
        if (!isRetryable || attempt == _maxRetryAttempts) rethrow;
        await Future<void>.delayed(_baseRetryDelay * attempt);
      }
    }
    throw lastError;
  }
}

/// Fetches FX rates, historical price series, and CBE official rates
/// from [https://api.frankfurter.dev/v2].
class FrankfurterDataSource {
  FrankfurterDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.frankfurterBase,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  Future<ExchangeRates> fetchUsdExchangeRates({
    List<String>? quoteCurrencyCodes,
  }) async {
    final requestedCodes =
        quoteCurrencyCodes ?? AppConstants.currencyCodes.toList();

    final response = await _dio.get<List<dynamic>>(
      '/rates',
      queryParameters: {
        'base': AppConstants.usd,
        'quotes': requestedCodes.join(','),
      },
    );

    final ratesFromUsd = <String, double>{AppConstants.usd: 1.0};
    DateTime? publishDate;

    for (final entry in (response.data ?? []).cast<Map>()) {
      final row = entry.cast<String, dynamic>();
      final quoteCurrency = row['quote'] as String?;
      final rate = (row['rate'] as num?)?.toDouble();
      if (quoteCurrency == null || rate == null) continue;
      ratesFromUsd[quoteCurrency] = rate;
      publishDate ??= row['date'] is String
          ? DateTime.parse(row['date'] as String)
          : null;
    }

    if (ratesFromUsd[AppConstants.sar] == null ||
        ratesFromUsd[AppConstants.egp] == null) {
      throw StateError(
          'Frankfurter response is missing required SAR and/or EGP rates.');
    }

    return ExchangeRates(
      ratesFromUsd: ratesFromUsd,
      date: publishDate ?? DateTime.now(),
    );
  }

  Future<List<HistoricalDataPoint>> fetchMetalPriceHistory({
    required String metalSymbol,
    required String quoteCurrencyCode,
    required int periodDays,
  }) =>
      fetchMetalPriceHistoryRange(
        metalSymbol: metalSymbol,
        quoteCurrencyCode: quoteCurrencyCode,
        fromDate: DateTime.now().subtract(Duration(days: periodDays)),
        toDate: DateTime.now(),
      );

  Future<List<HistoricalDataPoint>> fetchMetalPriceHistoryRange({
    required String metalSymbol,
    required String quoteCurrencyCode,
    required DateTime fromDate,
    DateTime? toDate,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/rates',
      queryParameters: {
        'base': metalSymbol,
        'quotes': quoteCurrencyCode,
        'from': _formatIsoDate(fromDate),
        if (toDate != null) 'to': _formatIsoDate(toDate),
      },
    );

    final dataPoints = (response.data ?? [])
        .cast<Map>()
        .map((entry) =>
            HistoricalDataPoint.fromJson(entry.cast<String, dynamic>()))
        .toList();

    dataPoints.sort((a, b) => a.date.compareTo(b.date));
    return dataPoints;
  }

  Future<List<HistoricalDataPoint>> fetchCentralBankRates() async {
    final response = await _dio.get<List<dynamic>>(
      '/providers/cbe/rates',
      queryParameters: {'base': AppConstants.usd},
    );

    final dataPoints = (response.data ?? [])
        .cast<Map>()
        .map((entry) =>
            HistoricalDataPoint.fromJson(entry.cast<String, dynamic>()))
        .toList();

    dataPoints.sort(
        (a, b) => (a.quoteCurrencyCode ?? '').compareTo(b.quoteCurrencyCode ?? ''));
    return dataPoints;
  }

  Future<Map<String, double>> fetchFxFamilyRates({
    required String baseCurrencyCode,
    required List<String> quoteCurrencyCodes,
  }) async {
    final response = await _dio.get<dynamic>(
      '/rates',
      queryParameters: {
        'base': baseCurrencyCode,
        'quotes': quoteCurrencyCodes.join(','),
      },
    );

    final ratesMap = <String, double>{};

    void extractRate(Map<String, dynamic> row) {
      final quoteCurrency = row['quote'] as String?;
      final rate = (row['rate'] as num?)?.toDouble();
      if (quoteCurrency != null && rate != null) {
        ratesMap[quoteCurrency] = rate;
      }
    }

    final data = response.data;
    if (data is List) {
      for (final entry in data) {
        extractRate((entry as Map).cast<String, dynamic>());
      }
    } else if (data is Map && data['rates'] is Map) {
      ((data['rates'] as Map).cast<String, dynamic>()).forEach((quote, value) {
        final rate = (value as num?)?.toDouble();
        if (rate != null) ratesMap[quote] = rate;
      });
    }

    return ratesMap;
  }

  static String _formatIsoDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
