import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Reusable responsive two-column labeled row for key-value pairs across the app.
/// Safely scales long numeric strings and wraps long localized labels without overflow.
class AppLabeledValueRow extends StatelessWidget {
  const AppLabeledValueRow({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.xs),
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = isBold
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.primary,
          )
        : theme.textTheme.bodyMedium?.copyWith(color: valueColor);

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.hGapSm,
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(value, style: textStyle),
            ),
          ),
        ],
      ),
    );
  }
}
