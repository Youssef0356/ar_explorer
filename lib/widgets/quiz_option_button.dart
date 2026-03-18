import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';

class QuizOptionButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;
  final bool isDark;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
    this.isDark = true,
  });

  Color get _backgroundColor {
    if (!showResult) {
      return isSelected
          ? AppTheme.accentCyan.withOpacity(isDark ? 0.15 : 0.1)
          : AppTheme.cardC(isDark);
    }
    if (isCorrect) {
      return AppTheme.successGreen.withOpacity(isDark ? 0.15 : 0.1);
    }
    if (isSelected && !isCorrect) {
      return AppTheme.errorRed.withOpacity(isDark ? 0.15 : 0.1);
    }
    return AppTheme.cardC(isDark).withOpacity(isDark ? 0.5 : 0.7);
  }

  Color get _borderColor {
    if (!showResult) {
      return isSelected
          ? AppTheme.accentCyan.withOpacity(0.5)
          : AppTheme.dividerC(isDark);
    }
    if (isCorrect) {
      return AppTheme.successGreen.withOpacity(0.5);
    }
    if (isSelected && !isCorrect) {
      return AppTheme.errorRed.withOpacity(0.5);
    }
    return AppTheme.dividerC(isDark).withOpacity(0.3);
  }

  IconData? get _trailingIcon {
    if (!showResult) return null;
    if (isCorrect) return Icons.check_circle_rounded;
    if (isSelected && !isCorrect) return Icons.cancel_rounded;
    return null;
  }

  Color get _trailingIconColor {
    if (isCorrect) return AppTheme.successGreen;
    return AppTheme.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['A', 'B', 'C', 'D'];
    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor, width: 1.5),
          boxShadow: !isDark && isSelected && !showResult
              ? [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected && !showResult
                    ? AppTheme.accentCyan.withOpacity(0.2)
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.08)),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[index],
                style: AppTheme.labelMedium.copyWith(
                  color: isSelected && !showResult
                      ? AppTheme.accentCyan
                      : AppTheme.textMutedC(isDark),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppTheme.bodyMedium.copyWith(
                  color: showResult && !isSelected && !isCorrect
                      ? AppTheme.textMutedC(isDark)
                      : AppTheme.textPrimaryC(isDark),
                ),
              ),
            ),
            if (_trailingIcon != null)
              Icon(
                _trailingIcon,
                color: _trailingIconColor,
                size: 22,
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
              ),
          ],
        ),
      ),
    );
  }
}
