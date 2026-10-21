import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';

/// Adaptive container that centers content and limits maximum width on wide displays
/// (tablets, desktops, large foldables), while allowing natural full-width layout on phones.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxContentWidth = AppDimensions.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
