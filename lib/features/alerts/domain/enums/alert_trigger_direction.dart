/// Describes the direction in which a price alert should trigger.
///
/// Replaces the raw `bool above` field on [PriceThresholdAlert] with a
/// self-documenting enum. This eliminates boolean-blindness bugs where
/// callers pass `true` or `false` without understanding which means "above".
enum AlertTriggerDirection {
  /// Alert fires when the price rises at or above the target.
  aboveTarget,

  /// Alert fires when the price falls at or below the target.
  belowTarget;

  /// Returns true when [currentPrice] satisfies this direction against [target].
  bool isSatisfied({required double currentPrice, required double target}) {
    return switch (this) {
      AlertTriggerDirection.aboveTarget => currentPrice >= target,
      AlertTriggerDirection.belowTarget => currentPrice <= target,
    };
  }

  /// Returns the UI arrow indicator for this direction.
  String get arrowSymbol => switch (this) {
        AlertTriggerDirection.aboveTarget => '↑',
        AlertTriggerDirection.belowTarget => '↓',
      };
}
