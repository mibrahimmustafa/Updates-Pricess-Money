import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants.dart';
import '../../../../core/services/notifications_service.dart';
import '../../../../core/utils.dart';
import '../../../prices/data/repositories/price_repository.dart';
import '../../domain/enums/alert_trigger_direction.dart';

/// Backward compatibility alias.
typedef PriceAlert = PriceThresholdAlert;

/// A user-defined price alert for one metal's per-gram price.
class PriceThresholdAlert {
  const PriceThresholdAlert({
    required this.id,
    required this.metalSymbol,
    required this.currency,
    required this.targetPerGram,
    AlertTriggerDirection? direction,
    bool? above,
    required this.createdAt,
    bool? isActive,
    bool? active,
  })  : direction = direction ??
            ((above ?? true)
                ? AlertTriggerDirection.aboveTarget
                : AlertTriggerDirection.belowTarget),
        isActive = isActive ?? active ?? true;

  final String id;
  final String metalSymbol; // XAU or XAG
  final String currency; // USD, SAR, EGP
  final double targetPerGram;
  final AlertTriggerDirection direction;

  /// Timestamp of creation.
  final int createdAt;
  final bool isActive;

  /// Backward-compatible getters
  bool get above => direction == AlertTriggerDirection.aboveTarget;
  bool get active => isActive;

  /// Pure evaluation: does this alert fire when per-gram equals [currentPricePerGram]?
  bool hasTriggered(double currentPricePerGram) =>
      direction.isSatisfied(currentPrice: currentPricePerGram, target: targetPerGram);

  bool isTriggered(double price) => hasTriggered(price);

  PriceThresholdAlert copyWith({
    bool? isActive,
    AlertTriggerDirection? direction,
  }) {
    return PriceThresholdAlert(
      id: id,
      metalSymbol: metalSymbol,
      currency: currency,
      targetPerGram: targetPerGram,
      direction: direction ?? this.direction,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'metal': metalSymbol,
        'currency': currency,
        'target': targetPerGram,
        'above': direction == AlertTriggerDirection.aboveTarget,
        'active': isActive,
        'createdAt': createdAt,
      };

  factory PriceThresholdAlert.fromJson(Map<String, dynamic> json) =>
      PriceThresholdAlert(
        id: json['id'] as String,
        metalSymbol: (json['metal'] ?? json['metalSymbol']) as String,
        currency: json['currency'] as String,
        targetPerGram: (json['target'] as num).toDouble(),
        direction: (json['above'] as bool? ?? true)
            ? AlertTriggerDirection.aboveTarget
            : AlertTriggerDirection.belowTarget,
        isActive: json['active'] as bool? ?? true,
        createdAt: (json['createdAt'] as num).toInt(),
      );
}

final alertsProvider =
    NotifierProvider<AlertsNotifier, List<PriceThresholdAlert>>(
  AlertsNotifier.new,
);

class AlertsNotifier extends Notifier<List<PriceThresholdAlert>> {
  static const _prefsKey = 'price_alerts_v1';

  @override
  List<PriceThresholdAlert> build() {
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
          .map((e) => PriceThresholdAlert.fromJson(e.cast<String, dynamic>()))
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

  Future<void> addAlert(PriceThresholdAlert alert) async {
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
        if (a.id == id) a.copyWith(isActive: !a.isActive) else a,
    ];
    await _save();
  }

  /// Evaluates active alerts on every fresh market snapshot.
  /// Fires notification for satisfied alerts, then disables them (one-shot).
  Future<void> evaluateAlerts(MarketSnapshot snapshot) async {
    String resolveMetalDisplayName(String symbol) =>
        AppConstants.metalPool[symbol] ?? symbol;

    final triggeredAlertIds = <String>[];
    for (final alert in state.where((x) => x.isActive)) {
      final metal = snapshot.findMetal(alert.metalSymbol);
      if (metal == null) continue;
      final currentPrice =
          snapshot.rates.convertFromUsd(metal.pricePerGram, alert.currency);
      if (alert.hasTriggered(currentPrice)) {
        triggeredAlertIds.add(alert.id);
        await showPriceAlertNotification(
          title: '${resolveMetalDisplayName(alert.metalSymbol)} — ${alert.currency}',
          body: alert.direction == AlertTriggerDirection.aboveTarget
              ? '${formatMoney(currentPrice, alert.currency)} ≥ '
                  '${formatMoney(alert.targetPerGram, alert.currency)}'
              : '${formatMoney(currentPrice, alert.currency)} ≤ '
                  '${formatMoney(alert.targetPerGram, alert.currency)}',
        );
      }
    }
    if (triggeredAlertIds.isNotEmpty) {
      state = [
        for (final a in state)
          if (triggeredAlertIds.contains(a.id)) a.copyWith(isActive: false) else a,
      ];
      await _save();
    }
  }

  /// Backward-compatible alias for evaluateAlerts
  Future<void> check(MarketSnapshot snapshot) => evaluateAlerts(snapshot);
}
