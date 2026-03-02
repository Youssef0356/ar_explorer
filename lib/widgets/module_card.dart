import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final double progress;
  final bool isLocked;
  final VoidCallback onTap;
  final int index;
  final bool isDark;

  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.progress,
    required this.isLocked,
    required this.onTap,
    required this.index,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: isLocked ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: AppTheme.moduleCard(accentColor, isDark).copyWith(
              color: isLocked
                  ? AppTheme.cardC(isDark).withValues(alpha: isDark ? 0.5 : 0.7)
                  : null,
            ),
            child: Stack(
              children: [
                // ── Glow effect ──
                if (!isLocked)
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            accentColor.withValues(alpha: isDark ? 0.15 : 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Content ──
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Icon container
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(
                                alpha: isLocked ? 0.1 : 0.15,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isLocked ? Icons.lock_rounded : icon,
                              color: isLocked
                                  ? AppTheme.textMutedC(isDark)
                                  : accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: isLocked
                                        ? AppTheme.textMutedC(isDark)
                                        : AppTheme.textPrimaryC(isDark),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: isLocked
                                        ? AppTheme.textMutedC(
                                            isDark,
                                          ).withValues(alpha: 0.5)
                                        : AppTheme.textSecondaryC(isDark),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Arrow or lock
                          Icon(
                            isLocked
                                ? Icons.lock_outline_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: isLocked
                                ? AppTheme.textMutedC(isDark)
                                : accentColor,
                            size: 18,
                          ),
                        ],
                      ),
                      // Progress bar
                      if (!isLocked) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: accentColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accentColor,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: AppTheme.bodySmall.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isLocked) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: AppTheme.warningAmber.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Complete the previous quiz to unlock',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.warningAmber.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 500),
        )
        .slideX(
          begin: 0.1,
          end: 0,
          delay: Duration(milliseconds: 100 * index),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
  }
}
