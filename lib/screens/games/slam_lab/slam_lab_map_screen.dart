import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../data/games/slam_game_data.dart';
import '../../../models/slam_game_models.dart';
import '../../../services/game_progress_service.dart';
import '../../../services/sound_service.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/animated_google_background.dart';
import 'slam_lab_game_screen.dart';

class SlamLabMapScreen extends StatelessWidget {
  const SlamLabMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final sound = context.read<SoundService>();
    final gameProgress = context.watch<GameProgressService>();

    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          color: AppTheme.textPrimaryC(isDark),
                          onPressed: () {
                            sound.playTap();
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SPATIAL COMPUTING LAB',
                                style: TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'SLAM Simulator',
                                style: AppTheme.headingMedium.copyWith(
                                  color: AppTheme.textPrimaryC(isDark),
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Unified XP Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 16, color: AppTheme.accentCyan),
                              const SizedBox(width: 4),
                              Text(
                                '${gameProgress.unifiedXP} XP',
                                style: const TextStyle(
                                  color: AppTheme.accentCyan,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Description Banner ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.dividerC(isDark)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.sensors_rounded, color: AppTheme.accentCyan, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Master how AR tracking algorithms lock onto static feature points and filter dynamic noise.',
                              style: TextStyle(
                                color: AppTheme.textSecondaryC(isDark),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Level Cards List ──
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: allSlamLevels.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final level = allSlamLevels[index];
                        final isCompleted = gameProgress.isLevelCompleted(level.id);
                        final stars = gameProgress.getStars(level.id);

                        // Level 1 is always unlocked. Next levels unlock when previous is completed.
                        final isUnlocked = index == 0 ||
                            gameProgress.isLevelCompleted(allSlamLevels[index - 1].id);

                        return _buildLevelCard(
                          context: context,
                          level: level,
                          index: index,
                          isUnlocked: isUnlocked,
                          isCompleted: isCompleted,
                          stars: stars,
                          isDark: isDark,
                          sound: sound,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required SLAMLevel level,
    required int index,
    required bool isUnlocked,
    required bool isCompleted,
    required int stars,
    required bool isDark,
    required SoundService sound,
  }) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              sound.playTap();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SlamLabGameScreen(level: level),
                ),
              );
            }
          : () {
              sound.playFailure();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complete previous lab level to unlock!'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? (isDark ? const Color(0xFF131D33) : Colors.white)
              : (isDark ? const Color(0xFF0D1424).withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnlocked
                ? (isCompleted ? AppTheme.accentCyan.withValues(alpha: 0.6) : AppTheme.dividerC(isDark))
                : Colors.transparent,
            width: isCompleted ? 1.5 : 1.0,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Level Number Indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? (isCompleted ? AppTheme.accentCyan.withValues(alpha: 0.2) : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.15)))
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        '0${level.levelNumber}',
                        style: TextStyle(
                          color: isCompleted ? AppTheme.accentCyan : AppTheme.textPrimaryC(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'monospace',
                        ),
                      )
                    : Icon(Icons.lock_rounded, size: 20, color: AppTheme.textMutedC(isDark)),
              ),
            ),

            const SizedBox(width: 14),

            // Level Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: AppTheme.headingSmall.copyWith(
                      color: isUnlocked ? AppTheme.textPrimaryC(isDark) : AppTheme.textMutedC(isDark),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.subtitle,
                    style: TextStyle(
                      color: isUnlocked ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Stars or XP reward
                  Row(
                    children: [
                      if (isCompleted) ...[
                        Row(
                          children: List.generate(3, (i) {
                            final hasStar = i < stars;
                            return Icon(
                              hasStar ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 16,
                              color: hasStar ? AppTheme.accentAmber : AppTheme.textMutedC(isDark),
                            );
                          }),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '+${level.xpReward} XP',
                        style: TextStyle(
                          color: AppTheme.textMutedC(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(
              isUnlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? AppTheme.accentCyan : AppTheme.textMutedC(isDark),
              size: 22,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
  }
}
