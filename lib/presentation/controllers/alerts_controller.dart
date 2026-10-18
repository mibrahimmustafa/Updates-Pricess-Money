import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../services/notifications_service.dart';
import '../../data/repositories/price_repository.dart';

/// A user-defined price alert for one metal's per-gram price.
class PriceAlert {
  const PriceAlert({
    required this.id,
    required this.metalSymbol,
    required this.currency,
    required this.targetPerGram,
    required this.above,
    required this.active,
    required this.createdAt,
  });

  final String id;
  final String metalSymbol; // XAU or XAG
  final String currency; // USD, SAR, EGP
  final double targetPerGram;
  final bool above;

  /// Timestamp of creation.
  final int createdAt;
  final bool active;

  /// Pure evaluation: does this alert fire when per-gram equals [price]?
  bool isTriggered(double price) =>
      above ? price >= targetPerGram : price <= targetPerGram;

  PriceAlert copyWith({bool? active}) {
    return PriceAlert(
      id: id,
      metalSymbol: metalSymbol,
      currency: currency,
      targetPerGram: targetPerGram,
      above: above,
      active: active ?? this.active,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'metal': metalSymbol,
        'currency': currency,
        'target': targetPerGram,
        'above': above,
        'active': active,
        'createdAt': createdAt,
      };

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
        id: json['id'] as String,
        metalSymbol: json['metal'] as String,
        currency: json['currency'] as String,
        targetPerGram: (json['target'] as num).toDouble(),
        above: json['above'] as bool,
        active: json['active'] as bool,
        createdAt: json['createdAt'] as int,
      );
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<PriceAlert>>(
  AlertsNotifier.new,
);

class AlertsNotifier extends Notifier<List<PriceAlert>> {
  static const _prefsKey = 'price_alerts_v1';

  @override
  List<PriceAlert> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final prefs = SharedPreferencesAsync();
    final raw = await prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .cast<Map>()
          .map((e) => PriceAlert.fromJson(e.cast<String, dynamic>()))
          .toList();
      state = list;
    } catch (_) {}
  }

  Future<void> _save() async {
    await SharedPreferencesAsync().setString(
      _prefsKey,
      jsonEncode(state.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> addAlert(PriceAlert alert) async {
    state = [...state, alert];
    await _save();
  }

  Future<void> removeAlert(String id) async {
    state = List.of(state)..removeWhere((a) => a.id == id);
    await _save();
  }

  Future<void> toggleActive(String id) async {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(active: !a.active) else a,
    ];
    await _save();
  }

  /// Called on every fresh snapshot: fires active alerts, then disables them
  /// (one-shot). Per-gram price of the alert's metal converted to its currency.
  Future<void> check(PriceSnapshot snapshot) async {
    String metalName(String s) =>
        AppConstants.metalPool[s] ?? s;

    final fired = <String>[];
    for (final a in state.where((x) => x.active)) {
      final metal = snapshot.metal(a.metalSymbol);
      if (metal == null) continue;
      final now = snapshot.rates.convertFromUsd(metal.pricePerGram, a.currency);
      if (a.isTriggered(now)) {
        fired.add(a.id);
        await showPriceAlertNotification(
          title: '${metalName(a.metalSymbol)} — ${a.currency}',
          body: a.above
              ? '${formatMoney(now, a.currency)} ≥ '
                  '${formatMoney(a.targetPerGram, a.currency)}'
              : '${formatMoney(now, a.currency)} ≤ '
                  '${formatMoney(a.targetPerGram, a.currency)}',
        );
      }
    }
    if (fired.isNotEmpty) {
      state = [
        for (final a in state)
          if (fired.contains(a.id)) a.copyWith(active: false) else a,
      ];
      await _save();
    }
  }
}
