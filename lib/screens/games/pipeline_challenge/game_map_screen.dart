import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/app_theme.dart';
import '../../../data/games/game_data.dart';
import '../../../services/game_progress_service.dart';
import '../../../services/subscription_service.dart';
import '../../../models/game_models.dart';
import '../../../widgets/animated_google_background.dart';
import '../../settings/paywall_screen.dart';
import 'game_pipeline_screen.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});
  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  // Dynamically generate the linear order of all levels
  final List<String> _levelOrder = arGameZones
      .expand((zone) => zone.levels)
      .map((level) => level.id)
      .toList();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedGoogleBackground(
          isDark: true,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(progress),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    itemCount: arGameZones.length,
                    itemBuilder: (ctx, i) =>
                        _buildZoneCard(context, arGameZones[i], progress, isPremium, i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(GameProgressService progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 390;
    final isVeryCompact = screenWidth < 350;

    int totalStars = 0, maxStars = 0;
    for (final z in arGameZones) {
      for (final l in z.levels) {
        totalStars += progress.getStars(l.id);
        maxStars += 3;
      }
    }
    final league = progress.currentLeague;
    final leagueColor = _getLeagueColor(league);

    return Container(
      padding: EdgeInsets.fromLTRB(
          isCompact ? 8 : 12, 12, isCompact ? 12 : 16, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: Colors.white, size: isVeryCompact ? 16 : 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
                minWidth: isVeryCompact ? 30 : 36,
                minHeight: isVeryCompact ? 30 : 36),
          ),
          SizedBox(width: isCompact ? 4 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('PIPELINE CHALLENGE',
                      style: TextStyle(
                          color: AppTheme.accentPurple,
                          fontSize: isVeryCompact ? 8 : 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isVeryCompact ? 1.5 : 2.5)),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('Build Mini-Game',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 18 : 20,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // League Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            margin: EdgeInsets.only(right: isVeryCompact ? 4 : 8),
            decoration: BoxDecoration(
              color: leagueColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: leagueColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getLeagueIcon(league), color: leagueColor, size: 12),
                if (!isVeryCompact) ...[
                  const SizedBox(width: 4),
                  Text(league,
                      style: TextStyle(
                          color: leagueColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ],
              ],
            ),
          ),
          // XP Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            margin: EdgeInsets.only(right: isVeryCompact ? 4 : 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded,
                    color: Colors.amber, size: 12),
                const SizedBox(width: 3),
                Text('${progress.unifiedXP}',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          // Stars Progress
          SizedBox(
            width: isVeryCompact ? 34 : 42,
            height: isVeryCompact ? 34 : 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: maxStars > 0 ? totalStars / maxStars : 0,
                  strokeWidth: isVeryCompact ? 2.5 : 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$totalStars',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: isVeryCompact ? 10 : 12,
                            fontWeight: FontWeight.w800)),
                    if (!isVeryCompact)
                      Text('/ $maxStars',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 7)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Zone card ───────────────────────────────────────────────────────────────
  Widget _buildZoneCard(BuildContext context, ARZone zone,
      GameProgressService progress, bool isPremium, int index) {
    final completedInZone =
        zone.levels.where((l) => progress.isLevelCompleted(l.id)).length;
    final totalInZone = zone.levels.length;
    final allDone = completedInZone == totalInZone;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: allDone
              ? zone.accentColor.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Zone Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: zone.accentColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: zone.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.account_tree_rounded,
                      color: zone.accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.name.split(' — ').last,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(zone.id.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                              color: zone.accentColor.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
                    ],
                  ),
                ),
                // Premium Badge — prominent gold PRO chip
                if (index >= 3 && !isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 4),
                        Text('PRO', style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        )),
                      ],
                    ),
                  ),
                // Zone Mastery Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: zone.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$completedInZone / $totalInZone',
                      style: TextStyle(
                          color: zone.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          // Level List
          ...zone.levels.asMap().entries.map((entry) {
            final idx = entry.key;
            final level = entry.value;

            // Zones 4 and 5 (index 3 and 4) are premium only
            final isPremiumZone = index >= 3;
            final isPremiumLocked = isPremiumZone && !isPremium;

            final isLocked = isPremiumLocked || progress.isLevelLocked(level.id, isFree: level.isFree);
            final isReadyToUnlock = progress.isLevelReadyToUnlock(level.id, _levelOrder);
            final isCompleted = progress.isLevelCompleted(level.id);
            final stars = progress.getStars(level.id);

            return GestureDetector(
              onTap: () {
                if (isPremiumLocked) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  );
                } else if (isLocked) {
                  if (isReadyToUnlock) {
                    _showUnlockLevelDialog(context, level, progress);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Complete previous levels to unlock this one!')),
                    );
                  }
                } else {
                  _showLevelSheet(level, zone);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.white.withValues(alpha: 0.04)),
                  ),
                ),
                child: Row(
                  children: [
                    // Level Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked
                            ? Colors.white.withValues(alpha: 0.04)
                            : isCompleted
                                ? (level.isBoss ? Colors.red : zone.accentColor)
                                    .withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: isLocked
                              ? Colors.white.withValues(alpha: 0.08)
                              : isCompleted
                                  ? (level.isBoss
                                          ? Colors.red
                                          : zone.accentColor)
                                      .withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.12),
                          width: level.isBoss ? 2.0 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: isLocked
                            ? Icon(Icons.lock_rounded,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 18)
                            : isCompleted
                                ? Icon(Icons.check_rounded,
                                    color: level.isBoss
                                        ? Colors.red
                                        : zone.accentColor,
                                    size: 22)
                                : level.isBoss
                                    ? Icon(
                                        Icons.bolt_rounded,
                                        color: Colors.red
                                            .withValues(alpha: 0.8),
                                        size: 20)
                                    : Text('${idx + 1}',
                                        style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.7),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.title,
                            style: TextStyle(
                              color: isLocked
                                  ? Colors.white.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.95),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.projectTask.isNotEmpty
                                ? level.projectTask
                                : level.goal,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isLocked
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action / Status
                    if (isPremiumLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 6,
                            )
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 13),
                            SizedBox(width: 4),
                            Text('PRO', style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            )),
                          ],
                        ),
                      )
                    else if (isCompleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          return Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < stars
                                ? Colors.amber
                                : Colors.white.withValues(alpha: 0.15),
                            size: 16,
                          );
                        }),
                      )
                    else if (isLocked && isReadyToUnlock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_open_rounded,
                                color: AppTheme.accentPurple, size: 14),
                            const SizedBox(width: 4),
                            const Text('20 XP',
                                style: TextStyle(
                                    color: AppTheme.accentPurple,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      )
                    else if (!isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (level.isBoss ? Colors.red : zone.accentColor)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'PLAY',
                          style: TextStyle(
                              color: level.isBoss
                                  ? Colors.red
                                  : zone.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 + index * 100)).fadeIn().slideY(begin: 0.05);
  }

  // ── Modals & Sheets ────────────────────────────────────────────────────────
  void _showUnlockLevelDialog(
      BuildContext context, ARLevel level, GameProgressService progress) {
    const int cost = 20;
    final canAfford = progress.unifiedXP >= cost;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppTheme.accentPurple),
            SizedBox(width: 12),
            Text('Unlock Level', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock "${level.title}" for $cost XP?',
                style: const TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text('Your Balance:',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7))),
                  const Spacer(),
                  Text(
                    '${progress.unifiedXP} XP',
                    style: TextStyle(
                      color:
                          canAfford ? AppTheme.successGreen : AppTheme.errorRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () async {
                    final success = await progress.unlockLevel(level.id, cost);
                    if (success && context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Unlocked ${level.title}!'),
                          backgroundColor: AppTheme.accentPurple,
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Unlock',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Diamond':
        return const Color(0xFFE1BEE7);
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  IconData _getLeagueIcon(String league) {
    switch (league) {
      case 'Diamond':
        return Icons.diamond_rounded;
      case 'Gold':
        return Icons.emoji_events_rounded;
      case 'Silver':
        return Icons.shield_rounded;
      default:
        return Icons.shield_outlined;
    }
  }

  void _showLevelSheet(ARLevel level, ARZone zone) {
    final progress = context.read<GameProgressService>();
    final stars = progress.getStars(level.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: zone.accentColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (level.isBoss ? Colors.red : zone.accentColor)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: (level.isBoss ? Colors.red : zone.accentColor)
                            .withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                      level.isBoss
                          ? Icons.bolt_rounded
                          : Icons.play_arrow_rounded,
                      color: level.isBoss ? Colors.red : zone.accentColor,
                      size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          level.isBoss
                              ? '⚡ BOSS CHALLENGE'
                              : zone.name.toUpperCase(),
                          style: TextStyle(
                              color:
                                  (level.isBoss ? Colors.red : zone.accentColor)
                                      .withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 3),
                      Text(level.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      3,
                      (i) => Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(
                                i < stars
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: i < stars
                                    ? Colors.amber
                                    : Colors.white.withValues(alpha: 0.2),
                                size: 20),
                          )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (level.projectTask.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.assignment_rounded,
                        color: zone.accentColor.withValues(alpha: 0.8),
                        size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(level.projectTask,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            if (level.buildContext.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                collapsedBackgroundColor: Colors.white.withValues(alpha: 0.03),
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                iconColor: zone.accentColor,
                collapsedIconColor: Colors.white.withValues(alpha: 0.4),
                title: Text(
                  'About this build step',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Text(
                    level.buildContext,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
            if (level.goal.isNotEmpty && level.projectTask.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: Colors.amber, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(level.goal,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                height: 1.5))),
                  ],
                ),
              ),
            if (level.isBoss && level.timeLimit > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.18))),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text('Time limit: ${level.timeLimit}s',
                        style: const TextStyle(
                            color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GamePipelineScreen(level: level)));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        level.isBoss ? Colors.red : zone.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0),
                child: Text(
                  stars > 0 ? 'REPLAY LEVEL' : 'START LEVEL',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
