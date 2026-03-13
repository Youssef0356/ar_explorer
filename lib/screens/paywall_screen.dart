import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../widgets/animated_google_background.dart';

class PaywallScreen extends StatelessWidget {
  final Future<void> Function()? onUnlockAd;
  final String? moduleName;

  const PaywallScreen({super.key, this.onUnlockAd, this.moduleName});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final subscriptionService = context.watch<SubscriptionService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGradient(isDark).colors.first,
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: false,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: AppTheme.textPrimaryC(isDark)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                child: Column(
                  children: [
                    // ── Hero Section ──
                    const Icon(Icons.workspace_premium_rounded, size: 72, color: AppTheme.accentAmber),
                    const SizedBox(height: 16),
                    if (moduleName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Unlock to access: $moduleName',
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.accentCyan, letterSpacing: 1.2),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Text(
                      'Unlock AR Explorer Premium',
                      textAlign: TextAlign.center,
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'One-time payment. Yours forever.',
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
                    ),
                    
                    const SizedBox(height: 32),

                    // ── Price Callout ──
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                      decoration: AppTheme.glassCard(isDark).copyWith(
                        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            subscriptionService.localizedPrice,
                            style: AppTheme.headingLarge.copyWith(
                              fontSize: 48,
                              color: AppTheme.textPrimaryC(isDark),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'One-time  |  No subscription  |  No expiry',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Feature Checklist ──
                    _buildFeatureList(isDark),

                    const SizedBox(height: 32),
                    
                    // ── Social Proof ──
                    Text(
                      'Trusted by AR developers in 172 countries',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    if (subscriptionService.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          subscriptionService.errorMessage!,
                          style: const TextStyle(color: AppTheme.errorRed),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // ── Main CTA ──
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.white,
                          elevation: 0,
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
                                'Get Lifetime Access',
                                style: AppTheme.buttonText.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Secondary Options ──
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: subscriptionService.isLoading ? null : () async {
                            await subscriptionService.restorePurchases();
                            if (subscriptionService.isPremium && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            'Restore Purchase',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.accentPurple),
                          ),
                        ),
                        if (onUnlockAd != null) ...[
                          Text(
                            '|',
                            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMutedC(isDark)),
                          ),
                          TextButton(
                            onPressed: onUnlockAd,
                            child: Text(
                              'Watch ad for this module',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.accentCyan),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(bool isDark) {
    final features = [
      'All 5 advanced modules (Technical, Dev, etc.)',
      'Unlimited mock interviews with timers',
      'Drag & Drop AR Coding Practice Game',
      'Professional Completion Certificate',
      'Detailed Quiz analytics & performance tracking',
      'Cloud storage for all your AR Notes',
      'Zero Ads. Zero distractions. Forever.',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(isDark),
      child: Column(
        children: features.map((feature) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppTheme.accentCyan),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feature,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
