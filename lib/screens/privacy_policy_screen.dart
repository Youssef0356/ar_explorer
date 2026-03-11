import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/progress_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  /// If true, shows the "Confirm & Continue" button (first-launch mode).
  /// If false, it's just a read-only view from Settings.
  final bool showConfirmButton;

  const PrivacyPolicyScreen({super.key, this.showConfirmButton = false});


  @override
  Widget build(BuildContext context) {
    const isDark = true; // Privacy screen always uses dark theme for premium feel

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: showConfirmButton
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Privacy Policy',
                style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              if (showConfirmButton) ...[
                const SizedBox(height: 48),
                const Icon(
                  Icons.shield_rounded,
                  size: 64,
                  color: AppTheme.accentCyan,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 24),
                Text(
                  'Privacy Policy',
                  style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review and accept our privacy policy to continue',
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],

              // ── Policy Content ──
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('1. Introduction'),
                        _bodyText(
                          'Welcome to AR Explorer. This Privacy Policy explains how we collect, '
                          'use, and protect your information when you use our mobile application.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('2. Information We Collect'),
                        _bodyText(
                          '• Learning progress and quiz scores (stored locally on your device)\n'
                          '• Username you provide during onboarding\n'
                          '• Bookmarks and notes (stored locally)\n'
                          '• Anonymous usage data for app improvement',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('3. Advertising'),
                        _bodyText(
                          'We use Google AdMob to display advertisements. AdMob may collect '
                          'and use data as described in Google\'s Privacy Policy. Rewarded ads '
                          'are shown when you choose to unlock modules.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('4. Data Storage'),
                        _bodyText(
                          'All your learning progress, bookmarks, and notes are stored locally '
                          'on your device using SharedPreferences. We do not upload your personal '
                          'data to any external servers.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('5. Third-Party Services'),
                        _bodyText(
                          '• Google AdMob (advertising)\n'
                          '• Google Play Services (app distribution & in-app reviews)\n'
                          '\nThese services may collect information as specified in their '
                          'respective privacy policies.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('6. Children\'s Privacy'),
                        _bodyText(
                          'AR Explorer is an educational application. We do not knowingly collect '
                          'personal information from children under 13.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('7. Changes to This Policy'),
                        _bodyText(
                          'We may update this Privacy Policy from time to time. '
                          'Any changes will be reflected within the app.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('8. Contact'),
                        _bodyText(
                          'If you have any questions about this Privacy Policy, '
                          'please contact us through the Google Play Store listing.',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Confirm Button (first-launch only) ──
              if (showConfirmButton) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context.read<ProgressService>().markPrivacyAccepted();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/onboarding');
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('I Accept & Continue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTheme.headingSmall.copyWith(
          color: AppTheme.accentCyan,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textSecondary,
        height: 1.6,
      ),
    );
  }
}
