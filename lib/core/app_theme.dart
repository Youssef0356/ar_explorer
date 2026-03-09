import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Dark Palette ───────────────────────────────────────────────
  static const Color primaryDark = Color(0xFF0A0E21);
  static const Color surfaceDark = Color(0xFF111328);
  static const Color cardDark = Color(0xFF1A1F38);
  static const Color cardDarkAlt = Color(0xFF1E2346);

  // ── Light Palette ──────────────────────────────────────────────
  static const Color primaryLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardLightAlt = Color(0xFFF0F2F5);

  // ── Accent Colors (shared) ─────────────────────────────────────
  static const Color accentCyan = Color(0xFF00D4AA);
  static const Color accentTeal = Color(0xFF00BCD4);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentAmber = Color(0xFFFFCA28);
  static const Color accentPurple = Color(0xFFBB86FC);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentOrange = Color(0xFFFF8A65);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color warningAmber = Color(0xFFFFB74D);

  // ── Text Colors (dark mode) ────────────────────────────────────
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF78909C);
  static const Color dividerColor = Color(0xFF2A2F4A);

  // ── Text Colors (light mode) ───────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF4A4A6A);
  static const Color textMutedLight = Color(0xFF8A8AA0);
  static const Color dividerColorLight = Color(0xFFE0E0E8);

  // ── Module Colors ──────────────────────────────────────────────
  static const List<Color> moduleColors = [
    accentCyan,
    accentBlue,
    accentPurple,
    accentOrange,
    accentPink,
    accentAmber,
  ];

  static Color getModuleColor(int index) {
    return moduleColors[index % moduleColors.length];
  }

  // ── Gradients ──────────────────────────────────────────────────
  static LinearGradient backgroundGradient(bool isDark) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [primaryDark, const Color(0xFF0D1232)]
        : [const Color(0xFFF0F4FF), const Color(0xFFE8ECFF)],
  );

  static LinearGradient moduleGradient(Color color, bool isDark) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]
            : [color.withValues(alpha: 0.08), color.withValues(alpha: 0.03)],
      );

  // ── Theme-Aware Helpers ────────────────────────────────────────
  static Color textPrimaryC(bool isDark) =>
      isDark ? textPrimary : textPrimaryLight;
  static Color textSecondaryC(bool isDark) =>
      isDark ? textSecondary : textSecondaryLight;
  static Color textMutedC(bool isDark) => isDark ? textMuted : textMutedLight;
  static Color dividerC(bool isDark) =>
      isDark ? dividerColor : dividerColorLight;
  static Color cardC(bool isDark) => isDark ? cardDark : cardLight;
  static Color surfaceC(bool isDark) => isDark ? surfaceDark : surfaceLight;
  static Color scaffoldC(bool isDark) => isDark ? primaryDark : primaryLight;

  // ── Text Styles ────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.outfit(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => GoogleFonts.outfit(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get headingSmall => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get buttonText => GoogleFonts.outfit(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: primaryDark,
  );

  // ── Theme Data ─────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(isDark: true);
  static ThemeData get lightTheme => _buildTheme(isDark: false);

  static ThemeData _buildTheme({required bool isDark}) {
    final scaffold = scaffoldC(isDark);
    final card = cardC(isDark);
    final txtPrimary = textPrimaryC(isDark);
    final txtSecondary = textSecondaryC(isDark);
    final divider = dividerC(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? const ColorScheme.dark(
              primary: accentCyan,
              secondary: accentBlue,
              surface: surfaceDark,
              error: errorRed,
              onPrimary: primaryDark,
              onSecondary: textPrimary,
              onSurface: textPrimary,
              onError: textPrimary,
            )
          : const ColorScheme.light(
              primary: accentCyan,
              secondary: accentBlue,
              surface: surfaceLight,
              error: errorRed,
              onPrimary: primaryLight,
              onSecondary: textPrimaryLight,
              onSurface: textPrimaryLight,
              onError: textPrimary,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium.copyWith(color: txtPrimary),
        iconTheme: IconThemeData(color: txtPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? null : Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentCyan,
          foregroundColor: primaryDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentCyan,
          side: const BorderSide(color: accentCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonText.copyWith(color: accentCyan),
        ),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      iconTheme: IconThemeData(color: txtSecondary, size: 22),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? cardDark : surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ── Decorations ────────────────────────────────────────────────
  static BoxDecoration glassCard(bool isDark) => BoxDecoration(
    color: isDark
        ? cardDark.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06),
      width: 1,
    ),
    boxShadow: isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
  );

  static BoxDecoration moduleCard(Color accent, bool isDark) => BoxDecoration(
    gradient: moduleGradient(accent, isDark),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: accent.withValues(alpha: isDark ? 0.2 : 0.15),
      width: 1,
    ),
    boxShadow: isDark
        ? null
        : [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
  );

  static InputDecoration inputDecoration({
    required String label,
    required String hint,
    required bool isDark,
  }) {
    final txtMuted = textMutedC(isDark);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: txtMuted),
      hintStyle: TextStyle(color: txtMuted.withValues(alpha: 0.5)),
      floatingLabelStyle: const TextStyle(color: accentCyan),
      filled: true,
      fillColor: isDark ? cardDark : cardLightAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: dividerC(isDark), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentCyan, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // ── XP / Level System ──────────────────────────────────────────
  static const List<String> levelTitles = [
    '🌱 AR Beginner',
    '📱 AR Learner',
    '🔍 AR Explorer',
    '⚡ AR Developer',
    '🧠 AR Architect',
    '🏆 AR Master',
  ];

  static const List<String> motivationalMessages = [
    'Every expert was once a beginner! 🚀',
    'Knowledge is your superpower! 💪',
    'You\'re building something amazing! 🌟',
    'Keep going, you\'re on fire! 🔥',
    'Almost there — don\'t stop now! ⚡',
    'Legendary knowledge unlocked! 🏆',
  ];

  static String getLevelTitle(double progress) {
    final idx = (progress * (levelTitles.length - 1)).floor();
    return levelTitles[idx.clamp(0, levelTitles.length - 1)];
  }

  static String getMotivationalMessage(double progress) {
    final idx = (progress * (motivationalMessages.length - 1)).floor();
    return motivationalMessages[idx.clamp(0, motivationalMessages.length - 1)];
  }

  static int getXP(int completedTopics, int totalQuizScore) {
    return (completedTopics * 50) + (totalQuizScore * 2);
  }
}
