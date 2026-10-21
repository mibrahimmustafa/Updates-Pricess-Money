import 'package:flutter/material.dart';

/// Design tokens for consistent spacing across Dahab Live.
/// Replaces arbitrary magic numbers and hardcoded widths/heights.
abstract final class AppSpacing {
  AppSpacing._();

  /// 0.0
  static const double none = 0.0;

  /// 2.0 - Micro spacing, badge internal gaps
  static const double xxs = 2.0;

  /// 3.0 - Micro gap
  static const double s3 = 3.0;

  /// 4.0 - Tight spacing, icon-to-label gaps
  static const double xs = 4.0;

  /// 5.0 - Compact horizontal tag spacing
  static const double s5 = 5.0;

  /// 6.0 - Compact horizontal gaps
  static const double s6 = 6.0;

  /// 8.0 - Small spacing, row item separation
  static const double sm = 8.0;

  /// 10.0 - Standard chip & small container spacing
  static const double s10 = 10.0;

  /// 12.0 - Medium spacing, card item separation
  static const double md = 12.0;

  /// 14.0 - Field gaps & medium card padding
  static const double s14 = 14.0;

  /// 16.0 - Standard screen & card padding
  static const double lg = 16.0;

  /// 18.0 - Intermediate section gap
  static const double s18 = 18.0;

  /// 20.0 - Section separation, prominent dividers
  static const double xl = 20.0;

  /// 22.0 - Table dividers
  static const double s22 = 22.0;

  /// 24.0 - Large section spacing, modal margins
  static const double xxl = 24.0;

  /// 32.0 - Extra large hero gaps
  static const double xxxl = 32.0;

  // ─── Pre-built Vertical Spacing Widgets ─────────────────────────────────────
  static const Widget vGapXxs = SizedBox(height: xxs);
  static const Widget vGap3 = SizedBox(height: s3);
  static const Widget vGapXs = SizedBox(height: xs);
  static const Widget vGap6 = SizedBox(height: s6);
  static const Widget vGapSm = SizedBox(height: sm);
  static const Widget vGap10 = SizedBox(height: s10);
  static const Widget vGapMd = SizedBox(height: md);
  static const Widget vGap14 = SizedBox(height: s14);
  static const Widget vGapLg = SizedBox(height: lg);
  static const Widget vGap18 = SizedBox(height: s18);
  static const Widget vGapXl = SizedBox(height: xl);
  static const Widget vGapXxl = SizedBox(height: xxl);
  static const Widget vGapXxxl = SizedBox(height: xxxl);

  // ─── Pre-built Horizontal Spacing Widgets ───────────────────────────────────
  static const Widget hGapXxs = SizedBox(width: xxs);
  static const Widget hGap3 = SizedBox(width: s3);
  static const Widget hGapXs = SizedBox(width: xs);
  static const Widget hGap5 = SizedBox(width: s5);
  static const Widget hGap6 = SizedBox(width: s6);
  static const Widget hGapSm = SizedBox(width: sm);
  static const Widget hGap10 = SizedBox(width: s10);
  static const Widget hGapMd = SizedBox(width: md);
  static const Widget hGap14 = SizedBox(width: s14);
  static const Widget hGapLg = SizedBox(width: lg);
  static const Widget hGapXl = SizedBox(width: xl);

  // ─── Semantic Pre-built Edge Insets ─────────────────────────────────────────
  static const EdgeInsets edgeAllXs = EdgeInsets.all(xs);
  static const EdgeInsets edgeAllSm = EdgeInsets.all(sm);
  static const EdgeInsets edgeAll10 = EdgeInsets.all(s10);
  static const EdgeInsets edgeAllMd = EdgeInsets.all(md);
  static const EdgeInsets edgeAll14 = EdgeInsets.all(s14);
  static const EdgeInsets edgeAllLg = EdgeInsets.all(lg);
  static const EdgeInsets edgeAllXl = EdgeInsets.all(xl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(s14);
}

/// Design tokens for corner radii across Dahab Live.
abstract final class AppRadius {
  AppRadius._();

  /// 4.0
  static const double xs = 4.0;

  /// 6.0
  static const double s6 = 6.0;

  /// 8.0 - Badges, small tags
  static const double sm = 8.0;

  /// 10.0 - Chips, compact cards
  static const double s10 = 10.0;

  /// 12.0 - Segmented buttons, intermediate controls
  static const double md = 12.0;

  /// 14.0 - Inputs, primary buttons
  static const double input = 14.0;
  static const double button = 14.0;

  /// 16.0 - Floating action buttons, secondary cards
  static const double fab = 16.0;

  /// 18.0 - Primary cards
  static const double card = 18.0;

  /// 20.0 - Badges, pill switches
  static const double s20 = 20.0;

  /// 22.0 - Rounded pills, filter chips
  static const double pill = 22.0;

  /// 999.0 - Full circular pill
  static const double circular = 999.0;

  // Pre-instantiated BorderRadius objects to eliminate magic numbers and allocations
  static final BorderRadius xsBorderRadius = BorderRadius.circular(xs);
  static final BorderRadius s6BorderRadius = BorderRadius.circular(s6);
  static final BorderRadius smBorderRadius = BorderRadius.circular(sm);
  static final BorderRadius s10BorderRadius = BorderRadius.circular(s10);
  static final BorderRadius mdBorderRadius = BorderRadius.circular(md);
  static final BorderRadius inputBorderRadius = BorderRadius.circular(input);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(button);
  static final BorderRadius fabBorderRadius = BorderRadius.circular(fab);
  static final BorderRadius cardBorderRadius = BorderRadius.circular(card);
  static final BorderRadius s20BorderRadius = BorderRadius.circular(s20);
  static final BorderRadius pillBorderRadius = BorderRadius.circular(pill);
  static final BorderRadius circularBorderRadius = BorderRadius.circular(circular);
}

/// Fixed visual component dimensions (icons, badges, boxes) across the app.
abstract final class AppSizes {
  AppSizes._();

  // Icon dimensions
  static const double iconXs = 12.0;
  static const double iconSm = 14.0;
  static const double iconBase = 16.0;
  static const double iconMd = 18.0;
  static const double iconLg = 20.0;
  static const double iconXl = 22.0;
  static const double iconXxl = 24.0;
  static const double iconHero = 40.0;

  // Icon container / Avatar dimensions
  static const double iconBoxSm = 32.0;
  static const double iconBoxMd = 36.0;
  static const double iconBoxLg = 42.0;

  // Component & indicator dimensions
  static const double liveDotSize = 7.0;
  static const double sliderThumbHeight = 8.0;
  static const double chipHeight = 44.0;
  static const double pillHeight = 36.0;
  static const double appBarIconSize = 30.0;
  static const double dividerThick = 24.0;
  static const double dividerHeight = 20.0;
  static const double dividerThin = 16.0;
  static const double chartDefaultHeight = 260.0;
  static const double chartLoadingHeight = 120.0;
  static const double chartPlaceholderHeight = 60.0;

  // Skeleton placeholders
  static const double skeletonHeightSm = 12.0;
  static const double skeletonHeightMd = 14.0;
  static const double skeletonHeightLg = 18.0;
  static const double skeletonWidthSm = 90.0;
  static const double skeletonWidthMd = 120.0;
}

/// Breakpoints, dynamic sizing helpers, and adaptive layout utilities.
abstract final class AppDimensions {
  AppDimensions._();

  /// Maximum readable content width on tablets, foldables, and desktops.
  static const double maxContentWidth = 720.0;

  /// Wider shell content constraint when needed.
  static const double maxWideContentWidth = 840.0;

  /// Compact phone breakpoint (e.g., iPhone SE, folded Galaxy Z Fold).
  static const double compactBreakpoint = 360.0;

  /// Medium tablet breakpoint.
  static const double tabletBreakpoint = 600.0;

  /// Desktop / large tablet breakpoint.
  static const double desktopBreakpoint = 900.0;

  /// Checks if the current viewport width is below [compactBreakpoint].
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  /// Checks if the current viewport width is a tablet or desktop display.
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns the system text scaler scale factor (defaults to 1.0).
  static double textScaleFactor(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1.0);

  /// Scales a base dimension by the system text scaler, clamped between [min] and [max].
  static double scaledByText(
    BuildContext context,
    double baseDimension, {
    double min = 0.0,
    double max = double.infinity,
  }) {
    final scale = textScaleFactor(context);
    return (baseDimension * scale).clamp(min, max);
  }
}
