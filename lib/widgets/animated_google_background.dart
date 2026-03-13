import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/theme_service.dart';

class AnimatedGoogleBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedGoogleBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedGoogleBackground> createState() =>
      _AnimatedGoogleBackgroundState();
}

class _AnimatedGoogleBackgroundState extends State<AnimatedGoogleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slow 30-second loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    // Don't start yet, wait for build to check flags
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool enableAnimations = context.watch<ThemeService>().enableAnimations;

    if (enableAnimations && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!enableAnimations && _controller.isAnimating) {
      _controller.stop();
    }
    final Color baseColor =
        widget.isDark ? AppTheme.primaryDark : const Color(0xFFFAFCFF);

    return Container(
      color: baseColor,
      child: Stack(
        children: [
          // Background gradient layer — isolated in its own RepaintBoundary
          // so that its continuous repaints do NOT force the child to repaint.
          if (enableAnimations)
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _AmbientGlowPainter(
                      t: _controller.value * 2 * math.pi,
                      isDark: widget.isDark,
                      baseColor: baseColor,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          // Content payload — also isolated so scroll repaints stay local
          RepaintBoundary(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// A lightweight CustomPainter that draws the 3 ambient radial glows.
/// Much cheaper than rebuilding 3 Container widgets with BoxDecoration
/// every frame, since we skip the entire widget/element/render-object
/// creation pipeline.
class _AmbientGlowPainter extends CustomPainter {
  final double t;
  final bool isDark;
  final Color baseColor;

  _AmbientGlowPainter({
    required this.t,
    required this.isDark,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow positions — slow swirling orbits
    final x1 = cx + math.sin(t) * cx * 0.6;
    final y1 = cy + math.cos(t) * cy * 0.4;

    final x2 = cx + math.cos(t * 1.3 + math.pi / 2) * cx * 0.5;
    final y2 = cy + math.sin(t * 1.3) * cy * 0.6;

    final x3 = cx + math.sin(t * 0.7 + math.pi) * cx * 0.45;
    final y3 = cy + math.cos(t * 0.9 + math.pi) * cy * 0.5;

    final radius = size.longestSide * 0.9;

    // Purple glow
    _drawGlow(
      canvas,
      Offset(x1, y1),
      radius,
      AppTheme.accentPurple.withValues(alpha: isDark ? 0.30 : 0.08),
    );

    // Blue glow
    _drawGlow(
      canvas,
      Offset(x2, y2),
      radius * 0.85,
      AppTheme.accentBlue.withValues(alpha: isDark ? 0.25 : 0.06),
    );

    // Cyan glow
    _drawGlow(
      canvas,
      Offset(x3, y3),
      radius * 0.8,
      AppTheme.accentCyan.withValues(alpha: isDark ? 0.20 : 0.05),
    );
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, center.dx * 2 + radius, center.dy * 2 + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(_AmbientGlowPainter old) => true; // t changes every frame
}
