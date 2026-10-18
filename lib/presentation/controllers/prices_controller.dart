import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../data/models/history_point.dart';
import '../../data/repositories/price_repository.dart';

class PricesState {
  const PricesState({
    this.snapshot,
    this.error,
    this.isLoading = false,
    this.isBackground = false,
    this.latencyMs,
  });

  final PriceSnapshot? snapshot;
  final String? error;
  final bool isLoading;

  /// True while app is paused/lifecycle-hidden: polling is stopped.
  final bool isBackground;

  /// Network round-trip time (ms) of the latest successful refresh —
  /// shown next to the LIVE badge as a connection-quality indicator.
  final int? latencyMs;

  PricesState copyWith({
    PriceSnapshot? snapshot,
    String? error,
    bool? isLoading,
    bool? isBackground,
    int? latencyMs,
  }) {
    return PricesState(
      snapshot: snapshot ?? this.snapshot,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isBackground: isBackground ?? this.isBackground,
      latencyMs: latencyMs ?? this.latencyMs,
    );
  }
}

final priceRepositoryProvider = Provider<PriceRepository>((ref) {
  return PriceRepository();
});

/// CBE official USD-based rates (Central Bank of Egypt).
final cbeRatesProvider =
    FutureProvider.autoDispose<List<HistoryPoint>>((ref) {
  return ref.read(priceRepositoryProvider).fetchCbeRates();
});

final pricesProvider = NotifierProvider.autoDispose<PricesNotifier, PricesState>(
  PricesNotifier.new,
);

class PricesNotifier extends Notifier<PricesState> with WidgetsBindingObserver {
  Timer? _timer;

  @override
  PricesState build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
    });
    init();
    return const PricesState(isLoading: true);
  }

  Future<void> init() async {
    final repo = ref.read(priceRepositoryProvider);

    // 1) Show cached data immediately (stale-while-revalidate).
    final cached = await repo.loadCached();
    if (cached != null) {
      state = PricesState(snapshot: cached);
    }

    // 2) Fetch fresh data, then start polling.
    await refresh();
    _startPolling();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    final watch = Stopwatch()..start();
    try {
      final snapshot = await ref.read(priceRepositoryProvider).fetchSnapshot();
      watch.stop();
      await ref.read(priceRepositoryProvider).saveCached(snapshot);
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        error: null,
        latencyMs: watch.elapsedMilliseconds,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Network error — showing last updated prices',
      );
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.pollInterval, (_) => refresh());
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // --- Lifecycle: poll only while the app is visible ---
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (this.state.isBackground) {
          this.state = this.state.copyWith(isBackground: false);
          refresh();
          _startPolling();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (!this.state.isBackground) {
          this.state = this.state.copyWith(isBackground: true);
          _stopPolling();
        }
    }
  }
}
