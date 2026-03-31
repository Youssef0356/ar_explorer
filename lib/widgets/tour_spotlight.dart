import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class TourSpotlight extends StatefulWidget {
  final Widget child;
  final bool isVisible;

  const TourSpotlight({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  State<TourSpotlight> createState() => _TourSpotlightState();
}

class _TourSpotlightState extends State<TourSpotlight> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
