import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/sound_service.dart';
import '../services/theme_service.dart';
import '../widgets/animated_google_background.dart';
class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, soundService),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildAppLogo(isDark),
                    const SizedBox(height: 32),
                    _buildInfoSection(
                      isDark: isDark,
                      icon: Icons.explore_rounded,
                      title: 'What is AR Explorer?',
                      content: 'AR Explorer is an interactive learning platform designed to demystify Augmented Reality (AR) development. Whether you are a beginner exploring the concepts or an experienced developer looking to sharpen your skills, AR Explorer provides a structured and gamified curriculum to master spatial computing.',
                      color: AppTheme.accentCyan,
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      isDark: isDark,
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'How to use it',
                      content: 'Start your journey on the Home tab by exploring daily concepts to earn XP. Then, dive into the Roadmap to follow a curated path of modules, quizzes, and hands-on coding challenges to earn certificates. Unlock new games and premium content as you level up!',
                      color: AppTheme.accentAmber,
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      isDark: isDark,
                      icon: Icons.group_rounded,
                      title: 'Who is it for?',
                      content: 'Everyone! From curious learners and students to mobile engineers seeking to transition into XR (Extended Reality) development. Our interactive tools make complex spatial mechanics easily understandable.',
                      color: AppTheme.accentPurple,
                    ),
                    const SizedBox(height: 32),
                    _buildContactCard(context, isDark, soundService),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, SoundService soundService) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              soundService.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCard(isDark),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textPrimaryC(isDark),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'About App',
              style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo(bool isDark) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.accentCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCyan.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.explore_rounded, size: 50, color: AppTheme.accentCyan),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 16),
        Text(
          'AR Explorer',
          style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimaryC(isDark)),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 4),
        Text(
          'Master Spatial Computing',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondaryC(isDark)),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildInfoSection({
    required bool isDark,
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassCard(isDark).copyWith(
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondaryC(isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildContactCard(BuildContext context, bool isDark, SoundService soundService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.mail_rounded, color: AppTheme.accentBlue.withValues(alpha: 0.7), size: 32),
          const SizedBox(height: 12),
          Text(
            'Need Help or Found a Bug?',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Contact us at\nsupport@the356company.com',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
