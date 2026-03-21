import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/progress_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool showConfirmButton;

  const PrivacyPolicyScreen({super.key, this.showConfirmButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: showConfirmButton
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Privacy Policy',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
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
                ).animate().scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 24),
                Text(
                  'Privacy Policy',
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review our privacy policy to continue',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
              ],
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Privacy Policy'),
                        _bodyText(
                          'Last updated: March 21, 2026\n\n'
                          'This Privacy Policy explains how AR Explorer'
                          'handles information when you use the AR Explorer mobile application.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('1. Information We Collect'),
                        _bodyText(
                          'We do not require account registration and we do not collect personal '
                          'information on our own servers.\n\n',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('2. How Information Is Used'),
                        _bodyText(
                          'Local app data is used only to provide core functionality, including '
                          'saving your progress and preferences.\n\n'
                          'We do not sell or rent your data.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('3. Third-Party Services'),
                        _bodyText(
                          'The free version of the app may display ads through Google AdMob. '
                          'In-app purchases are processed by Google Play .\n\n'
                          'These providers may process data under their own privacy policies. '
                          'We do not receive or store your payment card details.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('4. Data Retention and Security'),
                        _bodyText(
                          'Because most data is stored on your device, you control retention. '
                          'Removing the app may remove locally stored app data.\n\n'
                          'We apply reasonable measures within the app to protect data, but no '
                          'method of storage or transmission is completely secure.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('5. Children\'s Privacy'),
                        _bodyText(
                          'AR Explorer is not directed to children under 13. We do not knowingly '
                          'collect personal information from children under 13.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('6. Changes to This Policy'),
                        _bodyText(
                          'We may update this Privacy Policy from time to time. Updates will be '
                          'posted in the app with a revised "Last updated" date.',
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle('7. Contact'),
                        _bodyText(
                          'For privacy-related questions, contact us through the app listing on '
                          'Google Play or the Apple App Store.',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              if (showConfirmButton) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await context
                          .read<ProgressService>()
                          .markPrivacyAccepted();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed('/onboarding');
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
