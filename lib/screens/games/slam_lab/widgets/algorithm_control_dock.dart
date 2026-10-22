import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_theme.dart';

class AlgorithmControlDock extends StatelessWidget {
  final double fastThreshold;
  final ValueChanged<double> onFastThresholdChanged;
  final bool ransacEnabled;
  final ValueChanged<bool> onRansacToggled;
  final VoidCallback onRelocalize;
  final bool isRelocalizeAvailable;
  final bool isDark;

  const AlgorithmControlDock({
    super.key,
    required this.fastThreshold,
    required this.onFastThresholdChanged,
    required this.ransacEnabled,
    required this.onRansacToggled,
    required this.onRelocalize,
    required this.isRelocalizeAvailable,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentCyan.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: FAST Sensitivity ──
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 16, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Text(
                'FAST CORNER THRESHOLD',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.accentCyan,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(fastThreshold * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          // ── Slider ──
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.accentCyan,
              inactiveTrackColor: AppTheme.accentCyan.withValues(alpha: 0.15),
              thumbColor: AppTheme.accentCyan,
              overlayColor: AppTheme.accentCyan.withValues(alpha: 0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: fastThreshold,
              min: 0.15,
              max: 0.85,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onFastThresholdChanged(val);
              },
            ),
          ),

          // ── Toggles Row: RANSAC Filter & Relocalize ──
          const SizedBox(height: 6),
          Row(
            children: [
              // RANSAC Outlier Rejection Card
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onRansacToggled(!ransacEnabled);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: ransacEnabled
                          ? const Color(0xFF7C4DFF).withValues(alpha: 0.2)
                          : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ransacEnabled
                            ? const Color(0xFF7C4DFF)
                            : AppTheme.dividerC(isDark),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ransacEnabled ? Icons.filter_alt_rounded : Icons.filter_alt_off_rounded,
                          size: 18,
                          color: ransacEnabled ? const Color(0xFFBB86FC) : AppTheme.textMutedC(isDark),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RANSAC Filter',
                                style: TextStyle(
                                  color: ransacEnabled ? Colors.white : AppTheme.textMutedC(isDark),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ransacEnabled ? 'Reject Dynamic' : 'Disabled',
                                style: TextStyle(
                                  color: ransacEnabled ? const Color(0xFFBB86FC) : AppTheme.textMutedC(isDark),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: ransacEnabled,
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            onRansacToggled(val);
                          },
                          activeTrackColor: const Color(0xFFBB86FC),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Relocalize Loop Closure Button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: isRelocalizeAvailable
                      ? () {
                          HapticFeedback.mediumImpact();
                          onRelocalize();
                        }
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text(
                    'Relocalize',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: AppTheme.primaryDark,
                    disabledBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                    disabledForegroundColor: AppTheme.textMutedC(isDark),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
