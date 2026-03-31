import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/tour_service.dart';
import '../services/sound_service.dart';
import '../services/navigation_service.dart';

class TourBottomSheet extends StatelessWidget {
  final bool isDark;

  const TourBottomSheet({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tourService = context.watch<TourService>();
    final soundService = context.read<SoundService>();
    final navigationService = context.read<NavigationService>();
    final step = tourService.currentStep;

    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.28,
      maxChildSize: 0.35,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardC(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.textMutedC(isDark).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step Indicator & Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(
                              tourService.steps.length,
                              (index) => Container(
                                width: index == tourService.currentStepIndex ? 16 : 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: index == tourService.currentStepIndex
                                      ? AppTheme.accentCyan
                                      : AppTheme.textMutedC(isDark).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'Step ${tourService.currentStepIndex + 1} of ${tourService.steps.length}',
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textMutedC(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              step.icon,
                              color: AppTheme.accentCyan,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              step.title,
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.textPrimaryC(isDark),
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.body,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondaryC(isDark),
                          height: 1.4,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Actions
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              soundService.playTap();
                              tourService.skipTour();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Skip tour',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMutedC(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCyan,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              soundService.playTap();
                              // Navigate to target tab
                              navigationService.setTab(step.targetTab);
                              
                              if (tourService.currentStepIndex == tourService.steps.length - 1) {
                                tourService.completeTour();
                                Navigator.pop(context);
                              } else {
                                tourService.nextStep();
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tourService.currentStepIndex == tourService.steps.length - 1 ? 'Finish' : 'Got it',
                                  style: AppTheme.buttonText.copyWith(color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
