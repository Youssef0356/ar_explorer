import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/coding_game_data.dart';
import '../services/game_progress_service.dart';
import '../models/coding_game_models.dart';
import '../widgets/animated_google_background.dart';
import 'coding_challenge_screen.dart';

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

class CodingGameMapScreen extends StatefulWidget {
  const CodingGameMapScreen({super.key});
  @override
  State<CodingGameMapScreen> createState() => _CodingGameMapScreenState();
}

class _CodingGameMapScreenState extends State<CodingGameMapScreen>
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
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
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
                              zones: codingGameZones,
                              progress: progress,
                              levelOrder: _levelOrder,
                              levelPositions: _levelPositions,
                              scale: scale,
                            ),
                          ),
                        ),
                      ),
                      ...codingGameZones.map((zone) {
                        final labelY = _getZoneLabelY(zone.id) * scale;
                        return Positioned(
                          left: 0, right: 0, top: labelY,
                          child: _ZoneLabel(zone: zone, scale: scale),
                        );
                      }),
                      ...codingGameZones.expand((zone) => zone.levels.map((level) {
                        final pos = _levelPositions[level.id];
                        if (pos == null) return const SizedBox.shrink();
                        final isLocked = progress.isLevelLocked(level.id);
                        final stars = progress.getStars(level.id);
                        return Positioned(
                          left: pos.dx * scale - 30 * scale,
                          top:  pos.dy * scale - 30 * scale,
                          child: _LevelNode(
                            level: level,
                            zone: zone,
                            isLocked: isLocked,
                            stars: stars,
                            nodeSize: (level.isBoss ? 72.0 : 58.0) * scale,
                            pulseAnimation: _pulseController,
                            onTap: isLocked 
                              ? () => _showUnlockLevelDialog(context, level, progress)
                              : () => _showLevelSheet(level, zone),
                          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.5, 0.5)),
                        );
                      })),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: _buildHeader(progress),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockLevelDialog(BuildContext context, CodingLevel level, GameProgressService progress) {
    const int cost = 20;
    final canAfford = progress.unifiedXP >= cost;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unlock Level', style: TextStyle(color: Colors.white)),
        content: Text('Unlock "${level.title}" for $cost XP?\nYour Balance: ${progress.unifiedXP} XP', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: canAfford ? () async {
              await progress.unlockLevel(level.id, cost);
              if (context.mounted) Navigator.pop(ctx);
            } : null,
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
    return Container(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 8, 16, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SYSTEMS ENGINEER', style: TextStyle(color: AppTheme.accentPurple, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
                Text('Logic Map', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text('${progress.unifiedXP} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showLevelSheet(CodingLevel level, CodingZone zone) {
    final progress = context.read<GameProgressService>();
    final stars = progress.getStars(level.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(level.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(level.goal, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CodingChallengeScreen(level: level, accentColor: zone.accentColor)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: zone.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(stars > 0 ? 'REPLAY' : 'START'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final CodingZone zone;
  final double scale;
  const _ZoneLabel({required this.zone, required this.scale});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Text(zone.name.toUpperCase(), style: TextStyle(color: zone.accentColor, fontSize: 10 * scale, fontWeight: FontWeight.bold)),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final CodingLevel level;
  final CodingZone zone;
  final bool isLocked;
  final int stars;
  final double nodeSize;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _LevelNode({required this.level, required this.zone, required this.isLocked, required this.stars, required this.nodeSize, required this.pulseAnimation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isLocked ? Colors.grey : zone.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize, height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked ? Colors.white10 : color.withValues(alpha: 0.2),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(isLocked ? Icons.lock : Icons.play_arrow, color: color),
          ),
          const SizedBox(height: 4),
          Text(level.title, style: TextStyle(color: Colors.white70, fontSize: 10 * (nodeSize/60))),
        ],
      ),
    );
  }
}

class _StaticMapPainter extends CustomPainter {
  final List<CodingZone> zones;
  final GameProgressService progress;
  final List<String> levelOrder;
  final Map<String, Offset> levelPositions;
  final double scale;

  _StaticMapPainter({required this.zones, required this.progress, required this.levelOrder, required this.levelPositions, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white12..strokeWidth = 2..style = PaintingStyle.stroke;
    for (int i = 0; i < levelOrder.length - 1; i++) {
      final p1 = levelPositions[levelOrder[i]]! * scale;
      final p2 = levelPositions[levelOrder[i+1]]! * scale;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
