import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final bool showGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.blur = 6.0,
    this.opacity = 0.05,
    this.borderRadius,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(16);

    if (!isDark) {
      return Container(
        padding: padding,
        decoration: AppTheme.glassCard(false),
        child: child,
      );
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9),
        borderRadius: radius,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: showGlow && isDark
            ? [
                BoxShadow(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
