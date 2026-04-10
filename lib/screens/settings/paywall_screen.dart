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
                          style: AppTheme.labelMedium.copyWith(color: AppTheme.accentPurple, letterSpacing: 1.2),
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
                        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
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
                      'Unlock premium AR learning content',
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
                          backgroundColor: AppTheme.accentPurple,
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
                                style: AppTheme.buttonText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Restore & Ads ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('|', style: TextStyle(color: AppTheme.textMutedC(isDark))),
                          ),
                          TextButton(
                            onPressed: onUnlockAd,
                            child: Text(
                              'Watch Ad to Unlock',
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.accentPink),
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ── Terms & Privacy ──
                    Text(
                      'By continuing, you agree to our Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.textMutedC(isDark)),
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
      ('No More Ads', 'Remove all banner and rewarded ads forever.', Icons.block_rounded),
      ('Unlock All Games', 'Access Pipeline, Coding Games, and AR Debugger instantly.', Icons.gamepad_rounded),
      ('2x XP Multiplier', 'Progress twice as fast with double XP on all training activities.', Icons.bolt_rounded),
      ('Exclusive Certificates', 'Get sharable certificates that prove your learning progress.', Icons.verified_user_rounded),
      ('Skip Quiz Gates', 'Access any module without passing previous quizzes.', Icons.vibration_rounded),
      ('Express Learning', 'Unlock all present and future modules immediately.', Icons.auto_awesome_rounded),
    ];

    return Column(
      children: features.map((f) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(f.$3, color: AppTheme.accentPurple, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.$1,
                    style: AppTheme.headingSmall.copyWith(fontSize: 15, color: AppTheme.textPrimaryC(isDark)),
                  ),
                  Text(
                    f.$2,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                  ),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
