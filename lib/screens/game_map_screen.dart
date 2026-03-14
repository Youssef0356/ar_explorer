import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/game_data.dart';
import '../models/game_models.dart';
import '../services/game_progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import 'game_pipeline_screen.dart';

// ── Map layout constants ──────────────────────────────────────────────────────
const double _mapWidth = 420.0;
// Each zone occupies ~220px of height
const double _mapHeight = 1380.0;

// Pre-defined node positions (x, y) within the map canvas.
// Zones are stacked bottom→top (Zone 1 bottom, Zone 5 top).
// Y=0 is top of canvas, Y=_mapHeight is bottom.
// Each zone band:  Zone1: 1160-1380, Z2: 920-1160, Z3: 680-920, Z4: 440-680, Z5: 0-440
final Map<String, Offset> _levelPositions = {
  // ── Zone 1 — Foundations (cyan) ── bottom band
  'z1_l1':   const Offset(210, 1300),
  'z1_l2':   const Offset(110, 1210),
  'z1_boss': const Offset(310, 1180),

  // ── Zone 2 — Tracking (blue) ──
  'z2_l1':   const Offset(90,  1060),
  'z2_l2':   const Offset(280, 1010),
  'z2_boss': const Offset(180,  950),

  // ── Zone 3 — Platforms (purple) ──
  'z3_l1':   const Offset(320,  830),
  'z3_l2':   const Offset(110,  790),
  'z3_boss': const Offset(220,  720),

  // ── Zone 4 — Advanced (amber) ──
  'z4_l1':   const Offset(100,  600),
  'z4_l2':   const Offset(310,  560),
  'z4_boss': const Offset(200,  490),

  // ── Zone 5 — Master (pink) ──
  'z5_l1':   const Offset(300,  370),
  'z5_l2':   const Offset(120,  300),
  'z5_boss': const Offset(210,  200),
};

// Ordered list of all level IDs for path drawing
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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    final progress = context.read<GameProgressService>();

    // Find the first incomplete unlocked level
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

    // Map canvas y → scroll offset (canvas is drawn inside full scroll view)
    // We want the node visible roughly centered on screen
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = 100.0;
    final scrollTarget = (pos.dy - screenHeight / 2 + headerHeight)
        .clamp(0.0, _mapHeight);

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

    // Scale the map to fill screen width
    final scale = screenWidth / _mapWidth;
    final scaledHeight = _mapHeight * scale;

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: Stack(
        children: [
          // ── Scrollable map ──
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: screenWidth,
              height: scaledHeight + 120, // extra bottom padding
              child: Stack(
                children: [
                  // ── Background + paths canvas ──
                  Positioned.fill(
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _mapWidth,
                        height: _mapHeight,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) => CustomPaint(
                            painter: _MapBackgroundPainter(
                              zones: arGameZones,
                              progress: progress,
                              levelOrder: _levelOrder,
                              levelPositions: _levelPositions,
                              pulseValue: _pulseController.value,
                            ),
                            size: const Size(_mapWidth, _mapHeight),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Level nodes (positioned absolutely, scaled) ──
                  ...arGameZones.expand((zone) {
                    return zone.levels.map((level) {
                      final pos = _levelPositions[level.id];
                      if (pos == null) return const SizedBox.shrink();
                      final isLocked = progress.isLevelLocked(level.id);
                      final stars = progress.getStars(level.id);

                      final scaledX = pos.dx * scale;
                      final scaledY = pos.dy * scale;
                      final nodeSize = (level.isBoss ? 72.0 : 58.0) * scale;

                      return Positioned(
                        left: scaledX - nodeSize / 2,
                        top: scaledY - nodeSize / 2,
                        child: _LevelNode(
                          level: level,
                          zone: zone,
                          isLocked: isLocked,
                          stars: stars,
                          size: nodeSize,
                          pulseAnimation: _pulseController,
                          onTap: isLocked ? null : () => _showLevelSheet(level, zone),
                        )
                            .animate(delay: Duration(milliseconds: _levelOrder.indexOf(level.id) * 60))
                            .fadeIn(duration: 400.ms)
                            .scale(begin: const Offset(0.5, 0.5), curve: Curves.easeOutBack),
                      );
                    });
                  }),

                  // ── Zone name labels ──
                  ...arGameZones.map((zone) {
                    final labelY = _getZoneLabelY(zone.id) * scale;
                    return Positioned(
                      left: 0,
                      right: 0,
                      top: labelY,
                      child: _ZoneLabel(zone: zone),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Header overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(progress),
          ),
        ],
      ),
    );
  }

  double _getZoneLabelY(String zoneId) {
    const Map<String, double> labels = {
      'zone_1': 1345.0,
      'zone_2': 1100.0,
      'zone_3': 860.0,
      'zone_4': 620.0,
      'zone_5': 120.0,
    };
    return labels[zoneId] ?? 0;
  }

  Widget _buildHeader(GameProgressService progress) {
    int totalStars = 0;
    int maxStars = 0;
    for (final zone in arGameZones) {
      for (final level in zone.levels) {
        totalStars += progress.getStars(level.id);
        maxStars += 3;
      }
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            12,
            MediaQuery.of(context).padding.top + 8,
            16,
            14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF060B14).withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: AppTheme.accentCyan.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AR SYSTEMS ENGINEER',
                      style: TextStyle(
                        color: AppTheme.accentCyan,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      'World Map',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: maxStars > 0 ? totalStars / maxStars : 0,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentAmber,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalStars',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '/ $maxStars',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                    color: level.isBoss ? Colors.red : zone.accentColor,
                    size: 28,
                  ),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        level.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                      size: 20,
                    ),
                  )),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Goal card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      level.goal,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
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
                  border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Time limit: ${level.timeLimit}s',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<SoundService>().playTap();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamePipelineScreen(level: level),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: level.isBoss ? Colors.red : zone.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  stars > 0 ? 'REPLAY LEVEL' : 'START LEVEL',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Zone label widget ──────────────────────────────────────────────────────────
class _ZoneLabel extends StatelessWidget {
  final ARZone zone;
  const _ZoneLabel({required this.zone});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / _mapWidth;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: zone.accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: zone.accentColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              zone.name.toUpperCase(),
              style: TextStyle(
                color: zone.accentColor.withValues(alpha: 0.7),
                fontSize: 8 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level node widget ──────────────────────────────────────────────────────────
class _LevelNode extends StatelessWidget {
  final ARLevel level;
  final ARZone zone;
  final bool isLocked;
  final int stars;
  final double size;
  final Animation<double> pulseAnimation;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.level,
    required this.zone,
    required this.isLocked,
    required this.stars,
    required this.size,
    required this.pulseAnimation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLocked
        ? Colors.white.withValues(alpha: 0.12)
        : (level.isBoss ? Colors.red : zone.accentColor);

    final isCompleted = stars > 0;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 28,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Glow ring for active (not locked, not completed) ──
            AnimatedBuilder(
              animation: pulseAnimation,
              builder: (_, child) {
                final pulse = isCompleted || isLocked ? 0.0 : pulseAnimation.value;
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: isLocked
                        ? []
                        : [
                            BoxShadow(
                              color: color.withValues(alpha: 0.15 + pulse * 0.25),
                              blurRadius: 8 + pulse * 16,
                              spreadRadius: pulse * 4,
                            ),
                          ],
                  ),
                  child: child,
                );
              },
              child: Container(
                width: size,
                height: size,
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
                          color: Colors.white.withValues(alpha: 0.2),
                          size: size * 0.35)
                      : isCompleted
                          ? Icon(Icons.check_rounded, color: color, size: size * 0.42)
                          : Icon(
                              level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                              color: color,
                              size: size * 0.42,
                            ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Level name ──
            SizedBox(
              width: size + 20,
              child: Text(
                level.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isLocked
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.85),
                  fontSize: size * 0.16,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map background + paths painter ────────────────────────────────────────────
class _MapBackgroundPainter extends CustomPainter {
  final List<ARZone> zones;
  final GameProgressService progress;
  final List<String> levelOrder;
  final Map<String, Offset> levelPositions;
  final double pulseValue;

  const _MapBackgroundPainter({
    required this.zones,
    required this.progress,
    required this.levelOrder,
    required this.levelPositions,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawZoneBands(canvas, size);
    _drawPaths(canvas);
    _drawDecorations(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    // Deep space base
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1628),
          Color(0xFF060B14),
          Color(0xFF060B14),
          Color(0xFF0A1020),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle dot grid
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    const gridSpacing = 24.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  void _drawZoneBands(Canvas canvas, Size size) {
    // Zone color band boundaries (top y of each band)
    final bandDefs = [
      (color: const Color(0xFFFF4081), top: 0.0,    bot: 440.0),  // Z5 pink
      (color: const Color(0xFFFFC107), top: 440.0,  bot: 680.0),  // Z4 amber
      (color: const Color(0xFFD1C4E9), top: 680.0,  bot: 920.0),  // Z3 purple
      (color: const Color(0xFF2979FF), top: 920.0,  bot: 1160.0), // Z2 blue
      (color: const Color(0xFF00E5FF), top: 1160.0, bot: 1380.0), // Z1 cyan
    ];

    for (final band in bandDefs) {
      // Soft gradient band tint
      final bandPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            band.color.withValues(alpha: 0.0),
            band.color.withValues(alpha: 0.04),
            band.color.withValues(alpha: 0.06),
            band.color.withValues(alpha: 0.04),
            band.color.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromLTWH(0, band.top, size.width, band.bot - band.top),
        );
      canvas.drawRect(
        Rect.fromLTWH(0, band.top, size.width, band.bot - band.top),
        bandPaint,
      );

      // Thin separator line between zones
      if (band.top > 0) {
        final linePaint = Paint()
          ..color = band.color.withValues(alpha: 0.12)
          ..strokeWidth = 0.5;
        canvas.drawLine(
          Offset(24, band.top),
          Offset(size.width - 24, band.top),
          linePaint,
        );
      }

      // Ambient glow blob in each zone
      final blobX = band.color == const Color(0xFF2979FF) || band.color == const Color(0xFFD1C4E9)
          ? size.width * 0.2
          : size.width * 0.75;
      final blobY = (band.top + band.bot) / 2;
      final blobPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            band.color.withValues(alpha: 0.08 + pulseValue * 0.03),
            band.color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(blobX, blobY), radius: 120));
      canvas.drawCircle(Offset(blobX, blobY), 120, blobPaint);
    }
  }

  void _drawPaths(Canvas canvas) {
    for (int i = 0; i < levelOrder.length - 1; i++) {
      final fromId = levelOrder[i];
      final toId = levelOrder[i + 1];
      final from = levelPositions[fromId];
      final to = levelPositions[toId];
      if (from == null || to == null) continue;

      final fromCompleted = progress.isLevelCompleted(fromId);
      final toLocked = progress.isLevelLocked(toId);

      // Path color based on state
      final pathColor = fromCompleted && !toLocked
          ? _getZoneColor(fromId).withValues(alpha: 0.6)
          : Colors.white.withValues(alpha: 0.08);

      _drawCurvedPath(canvas, from, to, pathColor, fromCompleted && !toLocked);
    }
  }

  void _drawCurvedPath(Canvas canvas, Offset from, Offset to, Color color, bool active) {
    final path = Path();
    path.moveTo(from.dx, from.dy);

    // Cubic bezier for organic curve
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    // Control points slightly perpendicular to the path
    final perpX = -dy * 0.2;
    final perpY = dx * 0.2;
    path.cubicTo(
      from.dx + dx * 0.3 + perpX,
      from.dy + dy * 0.3 + perpY,
      from.dx + dx * 0.7 - perpX,
      from.dy + dy * 0.7 - perpY,
      to.dx,
      to.dy,
    );

    if (active) {
      // Glow underneath
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(path, glowPaint);
    }

    // Main path line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = active ? 1.8 : 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (!active) {
      // Dashed line for locked paths
      _drawDashedPath(canvas, path, linePaint);
    } else {
      canvas.drawPath(path, linePaint);
      // Draw connector dots along the path
      _drawConnectorDots(canvas, from, to, color);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      const dashLen = 5.0;
      const gapLen = 5.0;
      double dist = 0;
      while (dist < metric.length) {
        final start = dist;
        final end = math.min(dist + dashLen, metric.length);
        final sub = metric.extractPath(start, end);
        canvas.drawPath(sub, paint);
        dist += dashLen + gapLen;
      }
    }
  }

  void _drawConnectorDots(Canvas canvas, Offset from, Offset to, Color color) {
    const numDots = 3;
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (int d = 1; d <= numDots; d++) {
      final t = d / (numDots + 1);
      final x = from.dx + (to.dx - from.dx) * t;
      final y = from.dy + (to.dy - from.dy) * t;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  void _drawDecorations(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Tiny stars / sparkles scattered in background
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), r, starPaint);
    }

    // Circuit-like decorative lines (faint)
    final circuitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final startX = rng.nextDouble() * size.width;
      final startY = rng.nextDouble() * size.height;
      final path = Path()..moveTo(startX, startY);
      double cx = startX;
      double cy = startY;
      for (int j = 0; j < 3; j++) {
        // Only horizontal or vertical segments (circuit aesthetic)
        if (rng.nextBool()) {
          cx += (rng.nextDouble() - 0.5) * 80;
        } else {
          cy += (rng.nextDouble() - 0.5) * 80;
        }
        path.lineTo(cx, cy);
        canvas.drawCircle(Offset(cx, cy), 2, circuitPaint);
      }
      canvas.drawPath(path, circuitPaint);
    }
  }

  Color _getZoneColor(String levelId) {
    for (final zone in zones) {
      for (final level in zone.levels) {
        if (level.id == levelId) return zone.accentColor;
      }
    }
    return Colors.white;
  }

  @override
  bool shouldRepaint(_MapBackgroundPainter old) =>
      old.pulseValue != pulseValue ||
      old.progress != progress;
}