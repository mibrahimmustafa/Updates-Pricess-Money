import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Pulsing card placeholders shown during the first load (stale-first UX).
class PriceCardSkeleton extends StatefulWidget {
  const PriceCardSkeleton({super.key, this.height = 190});

  final double height;

  @override
  State<PriceCardSkeleton> createState() => _PriceCardSkeletonState();
}

class _PriceCardSkeletonState extends State<PriceCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerOpacity = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: shimmerOpacity,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.s20BorderRadius,
          border: Border.all(color: AppColors.skeletonBorder),
        ),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppSizes.iconBoxMd,
                    height: AppSizes.iconBoxMd,
                    decoration: BoxDecoration(
                      color: AppColors.skeletonPlaceholder,
                      borderRadius: AppRadius.cardBorderRadius,
                    ),
                  ),
                  AppSpacing.hGap10,
                  Flexible(
                    child: Container(
                      height: AppSizes.skeletonHeightMd,
                      width: AppSizes.skeletonWidthSm,
                      decoration: BoxDecoration(
                        color: AppColors.skeletonPlaceholder,
                        borderRadius: AppRadius.smBorderRadius,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      height: AppSizes.skeletonHeightLg,
                      width: AppSizes.skeletonWidthMd,
                      decoration: BoxDecoration(
                        color: AppColors.skeletonPlaceholder,
                        borderRadius: AppRadius.s10BorderRadius,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSizes.dividerThick),
              for (var i = 0; i < 3; i++) ...[
                Container(
                  height: AppSizes.skeletonHeightSm,
                  decoration: BoxDecoration(
                    color: AppColors.skeletonPlaceholder,
                    borderRadius: AppRadius.s6BorderRadius,
                  ),
                ),
                AppSpacing.vGapMd,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
