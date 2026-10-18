import 'package:flutter/material.dart';

import '../../main.dart';

/// Pulsing card placeholders shown during the first load (stale-first UX).
class PriceCardSkeleton extends StatefulWidget {
  const PriceCardSkeleton({super.key, this.height = 190});

  final double height;

  @override
  State<PriceCardSkeleton> createState() => _PriceCardSkeletonState();
}

class _PriceCardSkeletonState extends State<PriceCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: fade,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: PricessMoneyApp.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2C2820)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2820),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      height: 14,
                      width: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2820),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 18,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2820),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              for (var i = 0; i < 3; i++) ...[
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2820),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
