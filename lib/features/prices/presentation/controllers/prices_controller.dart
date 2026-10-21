import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../../../alerts/presentation/controllers/alerts_controller.dart';
import '../../../charts/data/models/history_point.dart';
import '../../data/repositories/price_repository.dart';

/// Backward compatibility alias.
typedef PricesState = MarketPricesState;
typedef PricesNotifier = MarketPricesNotifier;

class MarketPricesState {
  const MarketPricesState({
    this.snapshot,
    this.error,
    this.isLoading = false,
    this.isAppInBackground = false,
    this.networkLatencyMs,
  });

  final MarketSnapshot? snapshot;
  final String? error;
  final bool isLoading;

  /// True while app is paused/lifecycle-hidden: polling is stopped.
  final bool isAppInBackground;

  /// Network round-trip time (ms) of the latest successful refresh —
  /// shown next to the LIVE badge as a connection-quality indicator.
  final int? networkLatencyMs;

  /// Backward compatibility getters
  bool get isBackground => isAppInBackground;
  int? get latencyMs => networkLatencyMs;
  bool get hasNoError => error == null;

  MarketPricesState copyWith({
    MarketSnapshot? snapshot,
    String? error,
    bool? isLoading,
    bool? isAppInBackground,
    int? networkLatencyMs,
  }) {
    return MarketPricesState(
      snapshot: snapshot ?? this.snapshot,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isAppInBackground: isAppInBackground ?? this.isAppInBackground,
      networkLatencyMs: networkLatencyMs ?? this.networkLatencyMs,
    );
  }
}

final marketRepositoryProvider = Provider<PriceRepository>((ref) {
  return PriceRepository();
});

/// Backward compatibility alias.
final priceRepositoryProvider = marketRepositoryProvider;

/// Central Bank of Egypt (CBE) official USD-based rates.
final centralBankRatesProvider =
    FutureProvider.autoDispose<List<HistoricalDataPoint>>((ref) {
  return ref.read(marketRepositoryProvider).fetchCentralBankRates();
});

/// Backward compatibility alias.
final cbeRatesProvider = centralBankRatesProvider;

final marketPricesProvider =
    NotifierProvider.autoDispose<MarketPricesNotifier, MarketPricesState>(
  MarketPricesNotifier.new,
);

/// Backward compatibility alias.
final pricesProvider = marketPricesProvider;

class MarketPricesNotifier extends Notifier<MarketPricesState>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;

  @override
  MarketPricesState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _pollingTimer?.cancel();
    });
    initialize();
    return const MarketPricesState(isLoading: true);
  }

  Future<void> initialize() async {
    final repo = ref.read(marketRepositoryProvider);

    // 1) Show cached data immediately (stale-while-revalidate).
    final cached = await repo.loadCachedSnapshot();
    if (cached != null) {
      state = MarketPricesState(snapshot: cached);
    }

    // 2) Fetch fresh data, then start polling.
    await refresh();
    _startPolling();
  }

  /// Backward compatibility alias for initialize().
  Future<void> init() => initialize();

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    final stopwatch = Stopwatch()..start();
    try {
      final snapshot =
          await ref.read(marketRepositoryProvider).fetchLiveSnapshot();
      stopwatch.stop();
      await ref.read(marketRepositoryProvider).saveCachedSnapshot(snapshot);
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        error: null,
        networkLatencyMs: stopwatch.elapsedMilliseconds,
      );

      // Decoupled alert evaluation out of widget tree
      await ref.read(alertsProvider.notifier).evaluateAlerts(snapshot);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error — showing last updated prices',
      );
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(AppConstants.pollInterval, (_) => refresh());
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // --- Lifecycle: poll only while the app is visible ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (this.state.isAppInBackground) {
          this.state = this.state.copyWith(isAppInBackground: false);
          refresh();
          _startPolling();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (!this.state.isAppInBackground) {
          this.state = this.state.copyWith(isAppInBackground: true);
          _stopPolling();
        }
    }
  }
}
