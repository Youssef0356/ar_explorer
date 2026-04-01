import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TourSpotlight extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final bool showArrow;

  const TourSpotlight({
    super.key,
    required this.child,
    required this.isVisible,
    this.showArrow = false,
  });

  @override
  State<TourSpotlight> createState() => _TourSpotlightState();
}

class _TourSpotlightState extends State<TourSpotlight> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.isVisible)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 2),
                  ],
                ),
              ),
            ),
          ),
        if (widget.isVisible && widget.showArrow)
          Positioned(
            top: -32,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    color: AppTheme.accentCyan,
                    size: 24,
                    shadows: [
                      Shadow(
                        color: AppTheme.accentCyan.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (widget.isVisible && !widget.showArrow)
          Positioned(
            top: -2,
            right: -2,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.accentCyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
