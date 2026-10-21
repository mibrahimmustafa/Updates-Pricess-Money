import 'package:flutter/material.dart';

/// Standard centered loading indicator placeholder for charts and card views.
class LoadingChartPlaceholder extends StatelessWidget {
  const LoadingChartPlaceholder({
    super.key,
    this.height = 120,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
