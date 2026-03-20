import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/theme_service.dart';

class DailyKeywordCard extends StatefulWidget {
  final String keyword;
  final String definition;

  const DailyKeywordCard({
    super.key,
    required this.keyword,
    required this.definition,
  });

  @override
  State<DailyKeywordCard> createState() => _DailyKeywordCardState();
}

class _DailyKeywordCardState extends State<DailyKeywordCard>
    with SingleTickerProviderStateMixin {
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse().then((_) {
        setState(() => _showBack = false);
      });
    } else {
      _flipController.forward().then((_) {
        setState(() => _showBack = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background dismiss layer
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
            ),
          ),
          
          // Card
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final angle = _flipAnimation.value * pi;
                final showBack = angle > pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: showBack
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(pi),
                          child: _buildSide(
                            isBack: true,
                            isDark: isDark,
                            title: 'Definition',
                            content: widget.definition,
                            icon: Icons.lightbulb_rounded,
                            color: AppTheme.accentPurple,
                          ),
                        )
                      : _buildSide(
                          isBack: false,
                          isDark: isDark,
                          title: 'Daily AR Keyword',
                          content: widget.keyword,
                          icon: Icons.calendar_today_rounded,
                          color: AppTheme.accentCyan,
                        ),
                );
              },
            ),
          ).animate().scale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
              ).fadeIn(),
              
          // Close button at top right
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: AppTheme.textPrimaryC(isDark)),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.cardC(isDark).withValues(alpha: 0.8),
              ),
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        ],
      ),
    );
  }

  Widget _buildSide({
    required bool isBack,
    required bool isDark,
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: isBack ? 0.4 : 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTheme.labelMedium.copyWith(
              color: color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: isBack
                ? AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                    height: 1.5,
                  )
                : AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                    fontSize: 28,
                  ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            isBack ? 'Tap to see keyword' : 'Tap to reveal definition',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textMutedC(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
