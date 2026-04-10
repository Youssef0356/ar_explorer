import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/game_data.dart';
import '../services/game_progress_service.dart';
import '../models/game_models.dart';
import '../widgets/animated_google_background.dart';
import 'game_pipeline_screen.dart';

// ── Map layout constants ──────────────────────────────────────────────────────
const double _mapWidth  = 420.0;
const double _mapHeight = 1380.0;

final Map<String, Offset> _levelPositions = {
  'z1_l1':   const Offset(210, 1300),
  'z1_l2':   const Offset(110, 1210),
  'z1_boss': const Offset(310, 1180),
  'z2_l1':   const Offset(90,  1060),
  'z2_l2':   const Offset(280, 1010),
  'z2_boss': const Offset(180,  950),
  'z3_l1':   const Offset(320,  830),
  'z3_l2':   const Offset(110,  790),
  'z3_boss': const Offset(220,  720),
  'z4_l1':   const Offset(100,  600),
  'z4_l2':   const Offset(310,  560),
  'z4_boss': const Offset(200,  490),
  'z5_l1':   const Offset(300,  370),
  'z5_l2':   const Offset(120,  300),
  'z5_boss': const Offset(210,  200),
};

final List<String> _levelOrder = [
  'z1_l1', 'z1_l2', 'z1_boss',
  'z2_l1', 'z2_l2', 'z2_boss',
  'z3_l1', 'z3_l2', 'z3_boss',
  'z4_l1', 'z4_l2', 'z4_boss',
  'z5_l1', 'z5_l2', 'z5_boss',
];

// ── Screen ───────────────────────────────────────────────────────────────────
class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});
  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    final progress = context.read<GameProgressService>();
    String? targetId;
    for (final id in _levelOrder) {
      if (!progress.isLevelCompleted(id) && !progress.isLevelLocked(id)) {
        targetId = id;
        break;
      }
    }
    if (targetId == null) return;
    final pos = _levelPositions[targetId];
    if (pos == null) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = MediaQuery.of(context).size.width / _mapWidth;
    final scrollTarget = ((pos.dy * scale) - screenHeight / 2 + 50)
        .clamp(0.0, _mapHeight * scale);
    _scrollController.animateTo(
      scrollTarget,
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / _mapWidth;
    final scaledHeight = _mapHeight * scale;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedGoogleBackground(
          isDark: true,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: SizedBox(
                    width: screenWidth,
                    height: scaledHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        RepaintBoundary(
                          child: SizedBox(
                            width: screenWidth,
                            height: scaledHeight,
                            child: CustomPaint(
                              painter: _StaticMapPainter(
                                zones: arGameZones,
                                progress: progress,
                                levelOrder: _levelOrder,
                                levelPositions: _levelPositions,
                                scale: scale,
                              ),
                              isComplex: true,
                              willChange: false,
                            ),
                          ),
                        ),
                        ...arGameZones.map((zone) {
                          final labelY = _getZoneLabelY(zone.id) * scale;
                          return Positioned(
                            left: 0,
                            right: 0,
                            top: labelY,
                            child: RepaintBoundary(
                              child: _ZoneLabel(zone: zone, scale: scale),
                            ),
                          );
                        }),
                        ...arGameZones.expand((zone) => zone.levels.map((level) {
                          final pos = _levelPositions[level.id];
                          if (pos == null) return const SizedBox.shrink();
                          
                          final isLocked = progress.isLevelLocked(level.id, isFree: level.isFree);
                          final isReadyToUnlock = progress.isLevelReadyToUnlock(level.id, _levelOrder);
                          final stars     = progress.getStars(level.id);
                          final scaledX   = pos.dx * scale;
                          final scaledY   = pos.dy * scale;
                          final nodeSize  = (level.isBoss ? 72.0 : 58.0) * scale;
                          final delay     = Duration(milliseconds: _levelOrder.indexOf(level.id) * 30);
  
                          return Positioned(
                            left: scaledX - nodeSize / 2,
                            top:  scaledY - nodeSize / 2,
                            child: RepaintBoundary(
                              child: _LevelNode(
                                level: level,
                                zone: zone,
                                isLocked: isLocked,
                                isCompleted: progress.isLevelCompleted(level.id),
                                stars: stars,
                                nodeSize: nodeSize,
                                pulseAnimation: _pulseController,
                                onTap: isLocked 
                                  ? (isReadyToUnlock 
                                      ? () { _showUnlockLevelDialog(context, level, progress); }
                                      : () { ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Complete previous levels to unlock this one!'))); })
                                  : () { _showLevelSheet(level, zone); },
                              )
                                .animate(delay: delay)
                                .fadeIn(duration: 400.ms)
                                .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack),
                            ),
                          );
                        })),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: RepaintBoundary(child: _buildHeader(progress)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnlockLevelDialog(BuildContext context, ARLevel level, GameProgressService progress) {
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
            Text('Unlock "${level.title}" for $cost XP?', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text(
              'Your Balance: ${progress.unifiedXP} XP',
              style: TextStyle(
                color: canAfford ? AppTheme.successGreen : AppTheme.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: canAfford
                ? () async {
                    final success = await progress.unlockLevel(level.id, cost);
                    if (success && context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Unlocked ${level.title}!')),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentPurple,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  double _getZoneLabelY(String zoneId) => const {
    'zone_1': 1365.0,
    'zone_2': 1130.0,
    'zone_3': 890.0,
    'zone_4': 650.0,
    'zone_5': 410.0,
  }[zoneId] ?? 0.0;

  Widget _buildHeader(GameProgressService progress) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 390;
    final isVeryCompact = screenWidth < 350;

    int totalStars = 0, maxStars = 0;
    for (final z in arGameZones) {
      for (final l in z.levels) {
        totalStars += progress.getStars(l.id);
        maxStars   += 3;
      }
    }
    final league = progress.currentLeague;
    final leagueColor = _getLeagueColor(league);

    return Container(
      padding: EdgeInsets.fromLTRB(
        isCompact ? 8 : 12, 
        12, 
        isCompact ? 12 : 16, 
        14
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2), // Added subtle backing to ensure legibility
        border: Border(bottom: BorderSide(
          color: AppTheme.accentPurple.withValues(alpha: 0.15))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, 
                color: Colors.white, 
                size: isVeryCompact ? 16 : 20),
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
                      color: leagueColor, fontSize: 10,
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
              border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 12),
                const SizedBox(width: 3),
                Text('${progress.unifiedXP}',
                  style: const TextStyle(
                    color: Colors.amber, fontSize: 10,
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 7)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLeagueColor(String league) {
    switch (league) {
      case 'Diamond': return const Color(0xFFE1BEE7);
      case 'Gold': return Colors.amber;
      case 'Silver': return const Color(0xFFB0BEC5);
      default: return const Color(0xFFCD7F32);
    }
  }

  IconData _getLeagueIcon(String league) {
    switch (league) {
      case 'Diamond': return Icons.diamond_rounded;
      case 'Gold': return Icons.emoji_events_rounded;
      case 'Silver': return Icons.shield_rounded;
      default: return Icons.shield_outlined;
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
              width: 36, height: 4,
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
                    color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                    color: level.isBoss ? Colors.red : zone.accentColor,
                    size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.isBoss ? '⚡ BOSS CHALLENGE' : zone.name.toUpperCase(),
                        style: TextStyle(
                          color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.9),
                          fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                      const SizedBox(height: 3),
                      Text(level.title,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < stars ? Colors.amber : Colors.white.withValues(alpha: 0.2),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.assignment_rounded,
                      color: zone.accentColor.withValues(alpha: 0.8), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(level.projectTask,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13, height: 1.5, fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
            if (level.buildContext.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(level.goal,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13, height: 1.5))),
                  ],
                ),
              ),
            if (level.isBoss && level.timeLimit > 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.18))),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text('Time limit: ${level.timeLimit}s',
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
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
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => GamePipelineScreen(level: level)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: level.isBoss ? Colors.red : zone.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
                child: Text(
                  stars > 0 ? 'REPLAY LEVEL' : 'START LEVEL',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone label ────────────────────────────────────────────────────────────────
class _ZoneLabel extends StatelessWidget {
  final ARZone zone;
  final double scale;
  const _ZoneLabel({required this.zone, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
            decoration: BoxDecoration(
              color: zone.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: zone.accentColor.withValues(alpha: 0.25))),
            child: Text(
              zone.name.toUpperCase(),
              style: TextStyle(
                color: zone.accentColor.withValues(alpha: 0.75), // Slightly more visible
                fontSize: 6.5 * scale, // Reduced from 7
                fontWeight: FontWeight.w900, // Made bolder
                letterSpacing: 1.8)), // Increased spacing
          ),
        ],
      ),
    );
  }
}

// ── Level node widget ─────────────────────────────────────────────────────────
class _LevelNode extends StatelessWidget {
  final ARLevel level;
  final ARZone zone;
  final bool isLocked;
  final bool isCompleted;
  final int stars;
  final double nodeSize;
  final Animation<double> pulseAnimation;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.zone,
    required this.isLocked,
    required this.isCompleted,
    required this.stars,
    required this.nodeSize,
    required this.pulseAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLocked
        ? Colors.white.withValues(alpha: 0.12)
        : (level.isBoss ? Colors.red : zone.accentColor);
    // Only active (unlocked & not yet completed) nodes get the pulse
    final shouldPulse = !isLocked && !isCompleted;

    return GestureDetector(
      onTap: onTap,
      // Use intrinsic sizing — no fixed height that can overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Glow + circle ──
          shouldPulse
              ? AnimatedBuilder(
                  animation: pulseAnimation,
                  builder: (_, child) => _buildCircle(color, isCompleted, pulseAnimation.value, child!),
                  child: _buildCircleInner(color, isCompleted),
                )
              : _buildCircle(color, isCompleted, 0, _buildCircleInner(color, isCompleted)),

          const SizedBox(height: 4),

          // ── Label — unconstrained width so it never overflows vertically ──
          SizedBox(
            width: nodeSize + 24,
            child: Text(
              level.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isLocked
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.85),
                fontSize: (nodeSize * 0.16).clamp(9.0, 13.0),
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(Color color, bool isCompleted, double pulse, Widget inner) {
    return SizedBox(
      width: nodeSize,
      height: nodeSize,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Render hardware-accelerated gradient glow behind unlocked nodes
          if (!isLocked && !isCompleted)
            Positioned.fill(
              left: -8, right: -8, top: -8, bottom: -8,
              child: Transform.scale(
                scale: 1.0 + pulse * 0.4,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.4),
                        color.withValues(alpha: 0.0),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          inner,
        ],
      ),
    );
  }

  Widget _buildCircleInner(Color color, bool isCompleted) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked
            ? Colors.white.withValues(alpha: 0.04)
            : isCompleted
                ? color.withValues(alpha: 0.2)
                : const Color(0xFF060B14),
        border: Border.all(
          color: color.withValues(alpha: isLocked ? 0.2 : 0.9),
          width: level.isBoss ? 2.5 : 2.0,
        ),
      ),
      child: Center(
        child: isLocked
            ? Icon(Icons.lock_rounded,
                color: Colors.white.withValues(alpha: 0.2), size: nodeSize * 0.35)
            : isCompleted
                ? Icon(Icons.check_rounded, color: color, size: nodeSize * 0.42)
                : Icon(
                    level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                    color: color,
                    size: nodeSize * 0.42,
                  ),
      ),
    );
  }
}

// ── STATIC painter — background, bands, paths, decorations ───────────────────
// This painter only repaints when `progress` changes, never on pulse tick.
class _StaticMapPainter extends CustomPainter {
  final List<ARZone> zones;
  final GameProgressService progress;
  final List<String> levelOrder;
  final Map<String, Offset> levelPositions;
  final double scale;

  const _StaticMapPainter({
    required this.zones,
    required this.progress,
    required this.levelOrder,
    required this.levelPositions,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale canvas so all coordinates are in map-space (0..420 × 0..1380)
    canvas.save();
    canvas.scale(scale, scale);
    final mapSize = Size(_mapWidth, _mapHeight);

    _drawBackground(canvas, mapSize);
    _drawZoneBands(canvas, mapSize);
    _drawPaths(canvas);
    _drawDecorations(canvas, mapSize);

    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1628), Color(0xFF060B14), Color(0xFF060B14), Color(0xFF0A1020)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  void _drawZoneBands(Canvas canvas, Size size) {
    final bands = [
      (color: const Color(0xFFFF4081), top: 0.0,    bot: 440.0), // Zone 5
      (color: const Color(0xFFFFC107), top: 440.0,  bot: 680.0), // Zone 4
      (color: const Color(0xFFD1C4E9), top: 680.0,  bot: 920.0), // Zone 3
      (color: const Color(0xFF2979FF), top: 920.0,  bot: 1160.0), // Zone 2
      (color: const Color(0xFFD1C4E9), top: 1160.0, bot: 1380.0), // Zone 1 (Purple)
    ];

    for (final b in bands) {
      // Side-to-side gradient tint
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            b.color.withValues(alpha: 0.0),
            b.color.withValues(alpha: 0.05),
            b.color.withValues(alpha: 0.05),
            b.color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ).createShader(Rect.fromLTWH(0, b.top, size.width, b.bot - b.top));
      canvas.drawRect(Rect.fromLTWH(0, b.top, size.width, b.bot - b.top), paint);

      // Separator line
      if (b.top > 0) {
        canvas.drawLine(
          Offset(24, b.top), Offset(size.width - 24, b.top),
          Paint()..color = b.color.withValues(alpha: 0.1)..strokeWidth = 0.5);
      }

      // Static blob
      final blobX = (b.color == const Color(0xFF2979FF) || b.color == const Color(0xFFD1C4E9))
          ? size.width * 0.15
          : size.width * 0.80;
      final blobY = (b.top + b.bot) / 2;
      canvas.drawCircle(
        Offset(blobX, blobY),
        110,
        Paint()..shader = RadialGradient(
          colors: [b.color.withValues(alpha: 0.07), b.color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: Offset(blobX, blobY), radius: 110)),
      );
    }
  }

  void _drawPaths(Canvas canvas) {
    for (int i = 0; i < levelOrder.length - 1; i++) {
      final fromId = levelOrder[i];
      final toId   = levelOrder[i + 1];
      final from   = levelPositions[fromId];
      final to     = levelPositions[toId];
      if (from == null || to == null) continue;

      final fromDone  = progress.isLevelCompleted(fromId);
      final toLocked  = progress.isLevelLocked(toId, isFree: _isLevelFreeInZones(toId));
      final active    = fromDone && !toLocked;
      final pathColor = active
          ? _zoneColor(fromId).withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.07);

      _drawCurvedPath(canvas, from, to, pathColor, active);
    }
  }

  void _drawCurvedPath(Canvas canvas, Offset from, Offset to, Color color, bool active) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final perpX = -dy * 0.18;
    final perpY =  dx * 0.18;

    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(
        from.dx + dx * 0.35 + perpX, from.dy + dy * 0.35 + perpY,
        from.dx + dx * 0.65 - perpX, from.dy + dy * 0.65 - perpY,
        to.dx, to.dy,
      );

    if (active) {
      // Soft glow
      canvas.drawPath(path, Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      // Solid line
      canvas.drawPath(path, Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
      // Connector dots
      for (int d = 1; d <= 3; d++) {
        final t = d / 4.0;
        canvas.drawCircle(
          Offset(from.dx + dx * t, from.dy + dy * t),
          2.2,
          Paint()..color = color.withValues(alpha: 0.55)..style = PaintingStyle.fill,
        );
      }
    } else {
      // Dashed locked path
      _drawDashed(canvas, path, Paint()
        ..color = color
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final end = math.min(d + 5.0, m.length);
        canvas.drawPath(m.extractPath(d, end), paint);
        d += 10.0;
      }
    }
  }

  void _drawDecorations(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.25)..style = PaintingStyle.fill;
    for (int i = 0; i < 35; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 1.0 + 0.3,
        starPaint,
      );
    }
  }

  Color _zoneColor(String levelId) {
    for (final z in zones) {
      for (final l in z.levels) {
        if (l.id == levelId) return z.accentColor;
      }
    }
    return Colors.white;
  }

  bool _isLevelFreeInZones(String levelId) {
    for (final z in zones) {
      for (final l in z.levels) {
        if (l.id == levelId) return l.isFree;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(_StaticMapPainter old) => old.progress != progress;
}
