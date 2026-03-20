import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../data/quiz_data.dart';
import '../services/game_progress_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/theme_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  TIER MODEL
// ═══════════════════════════════════════════════════════════════════

enum CertTier { bronze, silver, gold, platinum }

class TierData {
  final CertTier tier;
  final String name;
  final String emoji;
  final Color color;
  final Color gradientEnd;
  final String requirement;
  final String description;
  final List<String> perks;
  final IconData badgeIcon;

  const TierData({
    required this.tier,
    required this.name,
    required this.emoji,
    required this.color,
    required this.gradientEnd,
    required this.requirement,
    required this.description,
    required this.perks,
    required this.badgeIcon,
  });
}

const List<TierData> kTiers = [
  TierData(
    tier: CertTier.bronze,
    name: 'Bronze',
    emoji: '🥉',
    color: Color(0xFFCD7F32),
    gradientEnd: Color(0xFF8B4513),
    requirement: 'Complete 3 modules',
    description: 'You\'ve taken your first serious steps into AR development.',
    perks: ['Bronze Badge on Profile', 'Downloadable Bronze Certificate', 'LinkedIn shareable credential'],
    badgeIcon: Icons.auto_awesome_rounded,
  ),
  TierData(
    tier: CertTier.silver,
    name: 'Silver',
    emoji: '🥈',
    color: Color(0xFFB0BEC5),
    gradientEnd: Color(0xFF607D8B),
    requirement: 'Complete all modules + pass all quizzes at 70%+',
    description: 'You have mastered the full AR curriculum from fundamentals to advanced.',
    perks: ['Silver Badge on Profile', 'Downloadable Silver Certificate', 'LinkedIn credential', 'Unlocks Mock Interview unlimited attempts'],
    badgeIcon: Icons.workspace_premium_rounded,
  ),
  TierData(
    tier: CertTier.gold,
    name: 'Gold',
    emoji: '🥇',
    color: Color(0xFFFFCA28),
    gradientEnd: Color(0xFFFF8F00),
    requirement: 'Everything above + score 90%+ on Mock Interview',
    description: 'You are interview-ready. Employers can trust your AR knowledge is solid.',
    perks: ['Gold Badge on Profile', 'Downloadable Gold Certificate', '"Interview Ready" LinkedIn credential', 'Exclusive Gold theme in app'],
    badgeIcon: Icons.military_tech_rounded,
  ),
  TierData(
    tier: CertTier.platinum,
    name: 'Platinum',
    emoji: '💎',
    color: Color(0xFFE1BEE7),
    gradientEnd: Color(0xFF7B1FA2),
    requirement: 'Gold + complete all game zones',
    description: 'The rarest achievement. You don\'t just know AR — you can build it.',
    perks: ['Platinum Badge on Profile', 'Downloadable Platinum Certificate', '"AR Expert" LinkedIn credential', 'Platinum theme + exclusive app icon'],
    badgeIcon: Icons.diamond_rounded,
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  PROGRESS CALCULATOR
// ═══════════════════════════════════════════════════════════════════

class CertProgressData {
  final int completedModules;
  final int totalModules;
  final bool allQuizzesPassed;
  final int quizzesPassed;
  final int totalQuizzes;
  final int bestInterviewScore;
  final int completedGameZones;
  final int totalGameZones;

  const CertProgressData({
    required this.completedModules,
    required this.totalModules,
    required this.allQuizzesPassed,
    required this.quizzesPassed,
    required this.totalQuizzes,
    required this.bestInterviewScore,
    required this.completedGameZones,
    required this.totalGameZones,
  });

  bool get bronzeUnlocked => completedModules >= 3;
  bool get silverUnlocked =>
      completedModules >= totalModules && allQuizzesPassed;
  bool get goldUnlocked => silverUnlocked && bestInterviewScore >= 90;
  bool get platinumUnlocked => goldUnlocked && completedGameZones >= totalGameZones;

  CertTier? get highestUnlocked {
    if (platinumUnlocked) return CertTier.platinum;
    if (goldUnlocked) return CertTier.gold;
    if (silverUnlocked) return CertTier.silver;
    if (bronzeUnlocked) return CertTier.bronze;
    return null;
  }

  bool isTierUnlocked(CertTier t) {
    switch (t) {
      case CertTier.bronze: return bronzeUnlocked;
      case CertTier.silver: return silverUnlocked;
      case CertTier.gold: return goldUnlocked;
      case CertTier.platinum: return platinumUnlocked;
    }
  }

  double tierProgress(CertTier t) {
    switch (t) {
      case CertTier.bronze:
        return (completedModules / 3).clamp(0.0, 1.0);
      case CertTier.silver:
        final modPct = completedModules / totalModules;
        final qPct = totalQuizzes > 0 ? quizzesPassed / totalQuizzes : 0.0;
        return ((modPct + qPct) / 2).clamp(0.0, 1.0);
      case CertTier.gold:
        if (!silverUnlocked) return 0;
        return (bestInterviewScore / 90).clamp(0.0, 1.0);
      case CertTier.platinum:
        if (!goldUnlocked) return 0;
        return totalGameZones > 0
            ? (completedGameZones / totalGameZones).clamp(0.0, 1.0)
            : 0.0;
    }
  }
}

CertProgressData computeProgress(
    ProgressService p, GameProgressService gp) {
  final totalMods = allModules.length;
  int completedMods = 0;
  for (final m in allModules) {
    final done = p.moduleProgress(m.id, m.totalTopics);
    if (done >= 1.0) completedMods++;
  }

  final quizEntries = allQuizzes.entries.toList();
  int passed = 0;
  for (final e in quizEntries) {
    final score = p.getQuizScore(e.key);
    if (score != null && score >= e.value.passingScore) passed++;
  }
  final allPassed = passed >= quizEntries.length && quizEntries.isNotEmpty;

  // Count game zones from game_data (5 zones of 3 levels each)
  // We approximate: zone complete = all 3 levels completed
  // Use isLevelCompleted across known level IDs
  final zoneIds = ['zone_1', 'zone_2', 'zone_3', 'zone_4', 'zone_5'];
  final zoneLevelIds = {
    'zone_1': ['z1_l1', 'z1_l2', 'z1_boss'],
    'zone_2': ['z2_l1', 'z2_l2', 'z2_boss'],
    'zone_3': ['z3_l1', 'z3_l2', 'z3_boss'],
    'zone_4': ['z4_l1', 'z4_l2', 'z4_boss'],
    'zone_5': ['z5_l1', 'z5_l2', 'z5_boss'],
  };
  int completedZones = 0;
  for (final z in zoneIds) {
    final levels = zoneLevelIds[z] ?? [];
    if (levels.every((id) => gp.isLevelCompleted(id))) completedZones++;
  }

  return CertProgressData(
    completedModules: completedMods,
    totalModules: totalMods,
    allQuizzesPassed: allPassed,
    quizzesPassed: passed,
    totalQuizzes: quizEntries.length,
    bestInterviewScore: p.interviewBestScore,
    completedGameZones: completedZones,
    totalGameZones: zoneIds.length,
  );
}

// ═══════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════

class CertificateProgressionScreen extends StatelessWidget {
  const CertificateProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<ProgressService>();
    final gameProgress = context.watch<GameProgressService>();
    final sound = context.read<SoundService>();
    final data = computeProgress(progress, gameProgress);
    final username = progress.username;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldC(isDark),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, sound),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    children: [
                      _buildHeroCard(data, username, isDark),
                      const SizedBox(height: 24),
                      ...kTiers.map((tier) => _TierCard(
                            tier: tier,
                            data: data,
                            username: username,
                            isDark: isDark,
                          )),
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

  Widget _buildHeader(BuildContext context, bool isDark, SoundService sound) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppTheme.textPrimaryC(isDark),
            onPressed: () {
              sound.playTap();
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Credentials',
                  style: AppTheme.headingMedium
                      .copyWith(color: AppTheme.textPrimaryC(isDark))),
              Text('Earn & share your AR expertise',
                  style: AppTheme.bodySmall
                      .copyWith(color: AppTheme.textMutedC(isDark))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
      CertProgressData data, String username, bool isDark) {
    final highest = data.highestUnlocked;
    final tierData = highest != null
        ? kTiers.firstWhere((t) => t.tier == highest)
        : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tierData != null
              ? [
                  tierData.color.withOpacity(0.2),
                  tierData.gradientEnd.withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(isDark ? 0.04 : 0.6),
                  Colors.white.withOpacity(isDark ? 0.02 : 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tierData != null
              ? tierData.color.withOpacity(0.35)
              : AppTheme.dividerC(isDark),
        ),
      ),
      child: Column(
        children: [
          Text(
            tierData != null ? tierData.emoji : '🎯',
            style: const TextStyle(fontSize: 52),
          ).animate().scale(curve: Curves.elasticOut, duration: 600.ms),
          const SizedBox(height: 12),
          Text(
            tierData != null
                ? '${tierData.name} Tier Achieved!'
                : 'Start Your Journey',
            style: AppTheme.headingSmall.copyWith(
              color: tierData != null
                  ? tierData.color
                  : AppTheme.textPrimaryC(isDark),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tierData != null
                ? tierData.description
                : 'Complete 3 modules to earn your first Bronze certificate',
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondaryC(isDark), height: 1.5),
          ),
          if (tierData != null) ...[
            const SizedBox(height: 16),
            // Perks row
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: tierData.perks
                  .map((perk) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tierData.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: tierData.color.withOpacity(0.25)),
                        ),
                        child: Text(perk,
                            style: TextStyle(
                                color: tierData.color,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  TIER CARD WIDGET
// ═══════════════════════════════════════════════════════════════════

class _TierCard extends StatelessWidget {
  final TierData tier;
  final CertProgressData data;
  final String username;
  final bool isDark;

  const _TierCard({
    required this.tier,
    required this.data,
    required this.username,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = data.isTierUnlocked(tier.tier);
    final progress = data.tierProgress(tier.tier);
    final isNext = !unlocked &&
        (data.highestUnlocked == null
            ? tier.tier == CertTier.bronze
            : _isNextTier(data.highestUnlocked!, tier.tier));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: unlocked
            ? tier.color.withOpacity(isDark ? 0.07 : 0.05)
            : AppTheme.cardC(isDark).withOpacity(isDark ? 1 : 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? tier.color.withOpacity(0.35)
              : isNext
                  ? tier.color.withOpacity(0.18)
                  : AppTheme.dividerC(isDark),
          width: unlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Badge icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: unlocked
                      ? tier.color.withOpacity(0.15)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: unlocked
                          ? tier.color.withOpacity(0.4)
                          : Colors.white.withOpacity(0.08)),
                ),
                child: Center(
                  child: Text(tier.emoji,
                      style: TextStyle(
                          fontSize: unlocked ? 24 : 20,
                          color: unlocked ? null : null)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${tier.name} Certificate',
                          style: TextStyle(
                            color: unlocked
                                ? tier.color
                                : AppTheme.textPrimaryC(isDark)
                                    .withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (unlocked) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('EARNED',
                                style: TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.requirement,
                      style: TextStyle(
                        color: unlocked
                            ? AppTheme.textSecondaryC(isDark)
                            : AppTheme.textMutedC(isDark),
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (!unlocked)
                Icon(Icons.lock_outline_rounded,
                    color: AppTheme.textMutedC(isDark).withOpacity(0.4),
                    size: 18),
            ],
          ),

          // Progress bar (show for next-to-unlock)
          if (!unlocked && isNext) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: tier.color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(tier.color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                      color: tier.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],

          // Earned: actions
          if (unlocked) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _CertificateViewScreen(
                          tier: tier,
                          username: username,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: tier.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              color: Colors.black, size: 15),
                          SizedBox(width: 6),
                          Text('View & Download',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _shareCertificate(context, tier, username),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tier.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: tier.color.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.share_rounded,
                        color: tier.color, size: 18),
                  ),
                ),
              ],
            ),
          ],

          // Perks list (collapsed, show on unlock)
          if (unlocked) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: tier.perks
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tier.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(p,
                            style: TextStyle(
                                color: tier.color.withOpacity(0.8),
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(
                milliseconds: 100 + kTiers.indexOf(tier) * 80))
        .slideY(begin: 0.05);
  }

  bool _isNextTier(CertTier current, CertTier candidate) {
    final order = [
      CertTier.bronze,
      CertTier.silver,
      CertTier.gold,
      CertTier.platinum
    ];
    final ci = order.indexOf(current);
    final ti = order.indexOf(candidate);
    return ti == ci + 1;
  }

  void _shareCertificate(
      BuildContext context, TierData tier, String username) {
    Share.share(
      'I just earned the ${tier.name} AR Explorer Certificate! '
      '${tier.emoji}\n\n'
      '${tier.description}\n\n'
      'Check out AR Explorer: https://arexplorer.app',
      subject: 'AR Explorer — ${tier.name} Certificate',
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  CERTIFICATE VIEW & DOWNLOAD SCREEN
// ═══════════════════════════════════════════════════════════════════

class _CertificateViewScreen extends StatefulWidget {
  final TierData tier;
  final String username;

  const _CertificateViewScreen(
      {required this.tier, required this.username});

  @override
  State<_CertificateViewScreen> createState() =>
      _CertificateViewScreenState();
}

class _CertificateViewScreenState extends State<_CertificateViewScreen> {
  final ScreenshotController _screenshotCtrl = ScreenshotController();
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final Uint8List? bytes = await _screenshotCtrl.capture();
      if (bytes != null) {
        await Gal.putImageBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Certificate saved to gallery! 🎉'),
            backgroundColor: AppTheme.successGreen,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: AppTheme.errorRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareImage() async {
    setState(() => _isSaving = true);
    try {
      final Uint8List? bytes = await _screenshotCtrl.capture();
      if (bytes != null) {
        // Write to temp
        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/ar_cert_${widget.tier.name}_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          text:
              'I earned the ${widget.tier.name} AR Explorer Certificate! ${widget.tier.emoji}',
        );
      }
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${widget.tier.name} Certificate',
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Certificate
            Screenshot(
              controller: _screenshotCtrl,
              child: _CertificateCard(
                  tier: widget.tier, username: widget.username),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveToGallery,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.download_rounded),
                    label: Text(_isSaving ? 'Saving…' : 'Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.tier.color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: widget.tier.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: widget.tier.color.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    onPressed: _isSaving ? null : _shareImage,
                    icon: Icon(Icons.share_rounded,
                        color: widget.tier.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Add to LinkedIn → Go to LinkedIn → Add Profile Section → Licenses & Certifications → paste the app link',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final TierData tier;
  final String username;

  const _CertificateCard({required this.tier, required this.username});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    return AspectRatio(
      aspectRatio: 1.414,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;
          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0E21),
                        const Color(0xFF0F1B40),
                        const Color(0xFF050814),
                      ],
                    ),
                    border: Border.all(
                        color: tier.color.withOpacity(0.45), width: 2),
                  ),
                ),
              ),
              // Glow top-left
              Positioned(
                top: -h * 0.3,
                left: -w * 0.15,
                child: Container(
                  width: w * 0.6,
                  height: w * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      tier.color.withOpacity(0.18),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              // Glow bottom-right
              Positioned(
                bottom: -h * 0.35,
                right: -w * 0.2,
                child: Container(
                  width: w * 0.8,
                  height: w * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      tier.gradientEnd.withOpacity(0.14),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              // Inner border
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: tier.color.withOpacity(0.15), width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Tier name at top
              Positioned(
                top: h * 0.06,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'CERTIFICATE OF ACHIEVEMENT',
                      style: GoogleFonts.outfit(
                        fontSize: h * 0.06,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: tier.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: tier.color.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tier.badgeIcon,
                                  color: tier.color, size: h * 0.035),
                              const SizedBox(width: 6),
                              Text(
                                '${tier.name.toUpperCase()} TIER',
                                style: GoogleFonts.outfit(
                                  fontSize: h * 0.03,
                                  fontWeight: FontWeight.w700,
                                  color: tier.color,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.03),
                    Text(tier.emoji, style: TextStyle(fontSize: h * 0.12)),
                  ],
                ),
              ),
              // "THIS IS TO CERTIFY THAT"
              Positioned(
                top: h * 0.54,
                left: 0,
                right: 0,
                child: Text(
                  'THIS IS TO CERTIFY THAT',
                  style: GoogleFonts.inter(
                    fontSize: h * 0.022,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Username
              Positioned(
                top: h * 0.61,
                left: w * 0.08,
                right: w * 0.08,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      username.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: h * 0.085,
                        fontWeight: FontWeight.bold,
                        color: tier.color,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                              color: tier.color.withOpacity(0.5),
                              blurRadius: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Description
              Positioned(
                top: h * 0.755,
                left: w * 0.12,
                right: w * 0.12,
                child: Text(
                  tier.description.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: h * 0.018,
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: 1,
                  ),
                ),
              ),
              // Date & Signature
              Positioned(
                bottom: h * 0.08,
                left: w * 0.12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(dateStr,
                        style: GoogleFonts.inter(
                            fontSize: h * 0.032,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    SizedBox(height: h * 0.01),
                    Container(
                        width: w * 0.2,
                        height: 1,
                        color: tier.color.withOpacity(0.5)),
                    SizedBox(height: h * 0.01),
                    Text('DATE',
                        style: GoogleFonts.inter(
                            fontSize: h * 0.016,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 2)),
                  ],
                ),
              ),
              Positioned(
                bottom: h * 0.065,
                right: w * 0.12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('AR Explorer',
                        style: GoogleFonts.dancingScript(
                            fontSize: h * 0.055,
                            fontWeight: FontWeight.bold,
                            color: tier.color)),
                    SizedBox(height: h * 0.01),
                    Container(
                        width: w * 0.25,
                        height: 1,
                        color: tier.color.withOpacity(0.5)),
                    SizedBox(height: h * 0.01),
                    Text('AUTHORIZED SIGNATURE',
                        style: GoogleFonts.inter(
                            fontSize: h * 0.016,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 2)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
