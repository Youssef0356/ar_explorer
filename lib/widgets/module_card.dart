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
  final bool enableAnimations;
  final bool isPremiumModule;
  final bool isNextUp;

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
    required this.enableAnimations,
    this.isPremiumModule = false,
    this.isNextUp = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
          onTap: isLocked ? null : onTap,
          child: Container(
            decoration: AppTheme.moduleCard(accentColor, isDark).copyWith(
              color: isLocked
                  ? AppTheme.cardC(isDark).withValues(alpha: isDark ? 0.5 : 0.7)
                  : null,
              border: isNextUp
                  ? Border(
                      left: BorderSide(color: accentColor, width: 3),
                      top: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                      right: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                      bottom: BorderSide(color: accentColor.withValues(alpha: 0.4), width: 1.5),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // ── "Next up" badge ──
                if (isNextUp)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            progress > 0 ? 'Continue' : 'Start here',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                              color: accentColor.withOpacity(
                                isLocked ? 0.1 : 0.15,
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
                                  title.isEmpty ? 'Untitled Module' : title,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: isLocked
                                        ? AppTheme.textMutedC(isDark)
                                        : AppTheme.textPrimaryC(isDark),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  description.isEmpty ? 'Learn more about this topic.' : description,
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
                      // Topic count removed - was too cluttered
                      // Progress bar only
                      if (!isLocked) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: accentColor.withOpacity(
                                    0.1,
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
                            color: isPremiumModule 
                                ? AppTheme.accentAmber.withValues(alpha: 0.15)
                                : AppTheme.warningAmber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPremiumModule ? Icons.workspace_premium_rounded : Icons.info_outline_rounded,
                                    size: 14,
                                    color: isPremiumModule 
                                        ? AppTheme.accentAmber
                                        : AppTheme.warningAmber.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isPremiumModule ? 'Premium' : 'Complete previous quiz to unlock',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: isPremiumModule 
                                            ? AppTheme.accentAmber
                                            : AppTheme.warningAmber.withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: isPremiumModule ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
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
        );

    // If animations are enabled, apply them
    if (enableAnimations) {
      return card
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 50 * index),
            duration: const Duration(milliseconds: 400),
          )
          .slideX(
            begin: 0.05,
            end: 0,
            delay: Duration(milliseconds: 50 * index),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
    }
    
    // Otherwise return flat card
    return card;
  }
}
