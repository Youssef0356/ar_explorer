import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';

class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool earned;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.earned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: earned
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: earned ? null : AppTheme.cardDark,
                border: Border.all(
                  color: earned
                      ? color.withValues(alpha: 0.5)
                      : AppTheme.dividerColor,
                  width: 2,
                ),
                boxShadow: earned
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: earned ? color : AppTheme.textMuted,
                size: 28,
              ),
            )
            .animate(target: earned ? 1 : 0)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: earned ? color : AppTheme.textMuted,
            fontWeight: earned ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
