import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../services/theme_service.dart';
import 'package:provider/provider.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: AppTheme.textPrimaryC(isDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Credits & Sources',
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 400)),

              const SizedBox(height: 16),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App info card
                      _buildInfoCard(isDark),
                      const SizedBox(height: 24),

                      _sectionTitle('📚 Knowledge Sources', isDark),
                      const SizedBox(height: 12),
                      _buildSourceTile(
                        isDark: isDark,
                        icon: Icons.android_rounded,
                        title: 'Google ARCore',
                        subtitle: 'developer.google.com/ar',
                        color: AppTheme.accentCyan,
                        delay: 100,
                      ),
                      _buildSourceTile(
                        isDark: isDark,
                        icon: Icons.camera_rounded,
                        title: 'PTC Vuforia Engine',
                        subtitle: 'developer.vuforia.com',
                        color: AppTheme.accentBlue,
                        delay: 150,
                      ),
                      _buildSourceTile(
                        isDark: isDark,
                        icon: Icons.games_rounded,
                        title: 'Unity AR Foundation',
                        subtitle:
                            'docs.unity3d.com/Packages/com.unity.xr.arfoundation',
                        color: AppTheme.accentPurple,
                        delay: 200,
                      ),
                      _buildSourceTile(
                        isDark: isDark,
                        icon: Icons.book_rounded,
                        title: 'IEEE & ACM Publications',
                        subtitle:
                            'Research papers on SLAM, sensor fusion, and AR systems',
                        color: AppTheme.accentOrange,
                        delay: 250,
                      ),
                      _buildSourceTile(
                        isDark: isDark,
                        icon: Icons.school_rounded,
                        title: 'Academic Curriculum',
                        subtitle:
                            'University AR/VR course materials and references',
                        color: AppTheme.accentPink,
                        delay: 300,
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle('🛠️ Technologies Used', isDark),
                      const SizedBox(height: 12),
                      _buildTechChips(isDark),

                      const SizedBox(height: 28),

                      _sectionTitle('👨‍💻 Development', isDark),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.glassCard(isDark),
                        child: Column(
                          children: [
                            Icon(
                              Icons.code_rounded,
                              color: AppTheme.accentCyan,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'AR Explorer',
                              style: AppTheme.headingSmall.copyWith(
                                color: AppTheme.textPrimaryC(isDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Built with Flutter & Dart',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textMutedC(isDark),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Version 1.0.0',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.accentCyan,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 500),
                      ),

                      const SizedBox(height: 28),

                      // Disclaimer
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber.withValues(
                            alpha: isDark ? 0.08 : 0.06,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.warningAmber.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppTheme.warningAmber,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'This application is designed for educational purposes. '
                                'All content is derived from official documentation, academic sources, '
                                'and open research materials.',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.warningAmber.withValues(
                                    alpha: 0.9,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(
                        delay: const Duration(milliseconds: 500),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentCyan.withValues(alpha: isDark ? 0.15 : 0.1),
                AppTheme.accentBlue.withValues(alpha: isDark ? 0.1 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentCyan.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              const Text('🎓', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'AR Explorer Learning Platform',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.textPrimaryC(isDark),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'An interactive mobile application for learning Augmented Reality '
                'concepts, development techniques, and best practices.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryC(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideY(begin: 0.1, end: 0);
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTheme.headingSmall.copyWith(
        color: AppTheme.textPrimaryC(isDark),
        fontSize: 16,
      ),
    );
  }

  Widget _buildSourceTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child:
          Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardC(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textPrimaryC(isDark),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textMutedC(isDark),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: delay),
                duration: const Duration(milliseconds: 400),
              )
              .slideX(begin: 0.05, end: 0),
    );
  }

  Widget _buildTechChips(bool isDark) {
    final techs = [
      ('Flutter', AppTheme.accentCyan),
      ('Dart', AppTheme.accentBlue),
      ('Provider', AppTheme.accentPurple),
      ('SharedPreferences', AppTheme.accentOrange),
      ('Google Fonts', AppTheme.accentPink),
      ('Flutter Animate', AppTheme.accentAmber),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: techs.map((tech) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: tech.$2.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tech.$2.withValues(alpha: 0.25)),
          ),
          child: Text(
            tech.$1,
            style: AppTheme.bodySmall.copyWith(
              color: tech.$2,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(delay: const Duration(milliseconds: 350));
  }
}
