import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Standard error display widget with retry action.
class NetworkErrorDisplay extends StatelessWidget {
  const NetworkErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: AppSizes.iconHero, color: theme.colorScheme.error),
            AppSpacing.vGapSm,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            if (onRetry != null) ...[
              AppSpacing.vGapMd,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: AppSizes.iconMd),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
