import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';

class PaywallScreen extends StatelessWidget {
  final Future<void> Function()? onUnlockAd;

  const PaywallScreen({super.key, this.onUnlockAd});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final subscriptionService = context.watch<SubscriptionService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGradient(isDark).colors.first,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textPrimaryC(isDark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 80, color: AppTheme.accentAmber),
              const SizedBox(height: 24),
              Text(
                'Unlock AR Explorer Premium',
                textAlign: TextAlign.center,
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textPrimaryC(isDark),
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Get unlimited access to all modules, practice tests, mock interviews, and ad-free experience!',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryC(isDark),
                ),
              ),
              const SizedBox(height: 48),
              if (subscriptionService.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    subscriptionService.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentAmber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: subscriptionService.isLoading
                      ? null
                      : () async {
                          await subscriptionService.purchase();
                          if (subscriptionService.isPremium && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: subscriptionService.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Get Lifetime Premium',
                          style: AppTheme.buttonText.copyWith(color: AppTheme.primaryDark),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: subscriptionService.isLoading
                    ? null
                    : () async {
                        await subscriptionService.restorePurchases();
                        if (subscriptionService.isPremium && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: Text(
                  'Restore Purchases',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCyan,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              if (onUnlockAd != null) ...[
                const SizedBox(height: 24),
                Divider(color: AppTheme.dividerC(isDark)),
                const SizedBox(height: 16),
                Text(
                  'Or, unlock just this module by watching a short ad.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onUnlockAd,
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                    label: const Text('Watch Ad to Unlock'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentPurple,
                      side: const BorderSide(color: AppTheme.accentPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
