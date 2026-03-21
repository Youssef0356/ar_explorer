import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class GlassShowcase extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String description;
  final Widget child;
  final double width;
  final double height;
  final IconData? icon;

  const GlassShowcase({
    super.key,
    required this.showcaseKey,
    required this.description,
    required this.child,
    this.width = 280,
    this.height = 100,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // The background is already blurred by ShowCaseWidget(blurValue: 1.5).
    // Standard Showcase handles screen edges natively so it never overflows.
    return Showcase(
      key: showcaseKey,
      description: description,
      descTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.2,
      ),
      tooltipBackgroundColor: Colors.white.withValues(alpha: 0.15),
      tooltipPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      targetBorderRadius: BorderRadius.circular(16),
      child: child,
    );
  }
}
