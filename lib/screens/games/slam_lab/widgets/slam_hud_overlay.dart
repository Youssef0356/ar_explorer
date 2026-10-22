import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class SlamHudOverlay extends StatelessWidget {
  final int activePointsCount;
  final double confidence; // 0.0 to 1.0
  final double accumulatedDriftMm;
  final double timeElapsed;
  final double totalDuration;
  final bool isTrackingLocked;
  final bool isDrifting;
  final bool isDark;

  const SlamHudOverlay({
    super.key,
    required this.activePointsCount,
    required this.confidence,
    required this.accumulatedDriftMm,
    required this.timeElapsed,
    required this.totalDuration,
    required this.isTrackingLocked,
    required this.isDrifting,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isTrackingLocked
        ? const Color(0xFF00E676)
        : (isDrifting ? const Color(0xFFFF9100) : const Color(0xFFFF1744));

    final statusText = isTrackingLocked
        ? 'TRACKING LOCKED'
        : (isDrifting ? 'DRIFT WARNING' : 'TRACKING LOST');

    final progressRatio = (timeElapsed / totalDuration).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D1A).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Live Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Active Landmarks
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.grain_rounded,
                      size: 15,
                      color: activePointsCount >= 4 ? const Color(0xFF00E676) : const Color(0xFFFF1744),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$activePointsCount/4 pts',
                      style: TextStyle(
                        color: activePointsCount >= 4 ? const Color(0xFF00E676) : const Color(0xFFFF1744),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Accumulated Drift
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: 15,
                      color: accumulatedDriftMm < 5.0 ? AppTheme.accentCyan : const Color(0xFFFF5252),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${accumulatedDriftMm.toStringAsFixed(1)}mm',
                      style: TextStyle(
                        color: accumulatedDriftMm < 5.0 ? AppTheme.accentCyan : const Color(0xFFFF5252),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Confidence & Time progress bar
          Row(
            children: [
              Text(
                'TIME',
                style: TextStyle(
                  color: AppTheme.textMutedC(isDark),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    backgroundColor: AppTheme.dividerC(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(totalDuration - timeElapsed).clamp(0, totalDuration).toInt()}s',
                style: TextStyle(
                  color: AppTheme.textMutedC(isDark),
                  fontSize: 10,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
