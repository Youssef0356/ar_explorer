import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AnimatedGoogleBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const AnimatedGoogleBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  State<AnimatedGoogleBackground> createState() => _AnimatedGoogleBackgroundState();
}

class _AnimatedGoogleBackgroundState extends State<AnimatedGoogleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 20 second loop for a very slow, relaxing, smooth animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // T goes from 0 to 2*PI smoothly wrapping around
        final double t = _controller.value * 2 * math.pi;

        // Creating elegant, slow swirling motion paths mimicking ambient glow
        final double x1 = math.sin(t) * 1.2;
        final double y1 = math.cos(t) * 0.8;
        
        // Secondary glow moving at a slightly different phase/speed
        final double x2 = math.cos(t * 1.3 + math.pi / 2) * 1.0;
        final double y2 = math.sin(t * 1.3) * 1.2;
        
        // Tertiary glow for added depth
        final double x3 = math.sin(t * 0.7 + math.pi) * 0.9;
        final double y3 = math.cos(t * 0.9 + math.pi) * 1.0;

        // Use a slightly softer base color in light mode to let the gradients blend gracefully
        final Color baseColor =
            widget.isDark ? AppTheme.primaryDark : const Color(0xFFFAFCFF);
            
        // The requested palette: Purple, Sky Blue, and Cyan
        // Opacities are significantly reduced in light mode to be comforting and not dominating
        final Color purpleGlow =
            AppTheme.accentPurple.withValues(alpha: widget.isDark ? 0.30 : 0.08);
        final Color blueGlow =
            AppTheme.accentBlue.withValues(alpha: widget.isDark ? 0.25 : 0.06);
        final Color cyanGlow =
            AppTheme.accentCyan.withValues(alpha: widget.isDark ? 0.20 : 0.05);
        final Color whiteGlow =
            Colors.white.withValues(alpha: widget.isDark ? 0.05 : 0.30);

        return Container(
          color: baseColor,
          child: Stack(
            children: [
              // Layer 1: Purple sweeping glow
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(x1, y1),
                    radius: 1.8,
                    colors: [
                      purpleGlow,
                      baseColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              // Layer 2: Blue sweeping glow with a touch of white/brightness in the center
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(x2, y2),
                    radius: 1.6,
                    colors: [
                      widget.isDark ? blueGlow : whiteGlow,
                      widget.isDark ? baseColor.withValues(alpha: 0.0) : blueGlow,
                      baseColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // Layer 3: Cyan sweeping glow
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(x3, y3),
                    radius: 1.5,
                    colors: [
                      cyanGlow,
                      baseColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              // Content payload
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
