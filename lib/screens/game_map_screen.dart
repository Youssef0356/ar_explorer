import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../core/app_theme.dart';
import '../data/game_data.dart';
import '../models/game_models.dart';
import '../services/game_progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import 'game_pipeline_screen.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen> {
  final TransformationController _transformationController = TransformationController();
  final double _mapSize = 1200.0;

  @override
  void initState() {
    super.initState();
    _focusOnZone1();
  }

  void _focusOnZone1() {
    // Focus on Zone 1 (Bottom Region: roughly 600, 1000)
    // We need to calculate the translation to center (600, 1000) in the viewport
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final x = (size.width / 2) - 600;
      final y = (size.height / 2) - 1000;
      
      _transformationController.value = Matrix4.identity()
        ..setTranslationRaw(x, y, 0);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<GameProgressService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Interactive Map ──
          InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.3,
            maxScale: 2.0,
            boundaryMargin: const EdgeInsets.all(500),
            child: SizedBox(
              width: _mapSize,
              height: _mapSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Map Background ──
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/world_map_bg.png',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // ── Grid Overlay (Subtle) ──
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: CustomPaint(
                        painter: GridPainter(color: AppTheme.accentCyan),
                      ),
                    ),
                  ),

                  // ── Paths between Zones ──
                  _buildZoneConnectionPaths(),

                  // ── Zones and Levels ──
                  ...arGameZones.map((zone) => _buildZoneContainer(zone, progress, isDark)),
                ],
              ),
            ),
          ),

          // ── Header Overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final progress = context.watch<GameProgressService>();
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AR SYSTEMS ENGINEER',
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.accentCyan, letterSpacing: 2),
                    ),
                    Text(
                      'World Pipeline Map',
                      style: AppTheme.headingSmall.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$totalStars / $maxStars',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildZoneContainer(ARZone zone, GameProgressService progress, bool isDark) {
    // Map Zone IDs to Coordinates on the 1200x1200px map
    final Map<String, Offset> zoneCoords = {
      'fundamentals': const Offset(600, 1000), // Zone 1
      'tracking': const Offset(250, 600),     // Zone 2
      'platforms': const Offset(950, 600),    // Zone 3
      'advanced_standard': const Offset(600, 200), // Zone 4
      'mastery': const Offset(600, 600),      // Zone 5
    };

    final center = zoneCoords[zone.id] ?? const Offset(600, 600);
    
    return Stack(
      children: [
        // Zone Title
        Positioned(
          left: center.dx - 100,
          top: center.dy - 120,
          width: 200,
          child: Column(
            children: [
              Text(
                zone.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTheme.labelMedium.copyWith(
                  color: zone.accentColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: zone.accentColor.withValues(alpha: 0.8), blurRadius: 10),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .shimmer(duration: 3.seconds, color: Colors.white),
            ],
          ),
        ),

        // Levels within the zone
        ...List.generate(zone.levels.length, (index) {
          final level = zone.levels[index];
          final isLocked = progress.isLevelLocked(level.id);
          final stars = progress.getStars(level.id);
          
          // Position levels in a small organic cluster around the center
          // Level 1: Left/Bottom-ish, Level 2: Right/Bottom-ish, Level 3: Center-ish
          Offset offset;
          if (index == 0) {
            offset = const Offset(-40, 20);
          } else if (index == 1) {
            offset = const Offset(40, 20);
          } else {
            offset = const Offset(0, -30);
          }

          return Positioned(
            left: center.dx + offset.dx - 40,
            top: center.dy + offset.dy - 40,
            child: _buildLevelNode(level, zone.accentColor, isLocked, stars),
          );
        }),
      ],
    );
  }

  Widget _buildLevelNode(ARLevel level, Color accentColor, bool isLocked, int stars) {
    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToLevel(level),
      child: Column(
        children: [
          Container(
            width: level.isBoss ? 70 : 60,
            height: level.isBoss ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked ? Colors.grey.withValues(alpha: 0.1) : Colors.black,
              border: Border.all(
                color: isLocked 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : (level.isBoss ? Colors.red : accentColor),
                width: 2,
              ),
              boxShadow: isLocked ? [] : [
                BoxShadow(
                  color: (level.isBoss ? Colors.red : accentColor).withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isLocked)
                  Icon(
                    level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                    color: level.isBoss ? Colors.red : accentColor,
                    size: level.isBoss ? 30 : 24,
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.3)),
                
                if (isLocked)
                  Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.2), size: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: Text(
              level.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTheme.bodySmall.copyWith(
                color: isLocked ? Colors.white.withValues(alpha: 0.3) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ),
          if (!isLocked && stars > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Icon(
                Icons.star_rounded,
                size: 10,
                color: i < stars ? Colors.amber : Colors.white.withValues(alpha: 0.1),
              )),
            ),
        ],
      ).animate(target: isLocked ? 0 : 1)
       .fadeIn(),
    );
  }

  Widget _buildZoneConnectionPaths() {
    // Draw paths between regions of the map
    return CustomPaint(
      size: const Size(1200, 1200),
      painter: MapPathPainter(),
    );
  }

  void _navigateToLevel(ARLevel level) {
    final progress = context.read<GameProgressService>();
    final stars = progress.getStars(level.id);
    final isDark = context.read<ThemeService>().isDarkMode;
    final zone = arGameZones.firstWhere((z) => z.id == level.zoneId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.cardC(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (level.isBoss ? Colors.red : zone.accentColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    level.isBoss ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                    color: level.isBoss ? Colors.red : zone.accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.isBoss ? 'BOSS CHALLENGE' : 'LEVEL PREVIEW',
                        style: AppTheme.labelMedium.copyWith(
                          color: level.isBoss ? Colors.red : zone.accentColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        level.title,
                        style: AppTheme.headingSmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GOAL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(level.goal, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (stars > 0) ...[
              const Text('BEST ATTEMPT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => Icon(
                  Icons.star_rounded,
                  size: 24,
                  color: i < stars ? Colors.amber : Colors.white10,
                )),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SoundService>().playTap();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GamePipelineScreen(level: level)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: level.isBoss ? Colors.red : zone.accentColor,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(stars > 0 ? 'REPLAY' : 'START SESSION', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCyan.withValues(alpha: 0.15)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashPaint = Paint()
      ..color = AppTheme.accentCyan.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = const Offset(600, 600);
    final bottom = const Offset(600, 1000);
    final left = const Offset(250, 600);
    final right = const Offset(950, 600);
    final top = const Offset(600, 200);

    // Draw main hub connections
    _drawCurvedPath(canvas, bottom, center, paint);
    _drawCurvedPath(canvas, left, center, paint);
    _drawCurvedPath(canvas, right, center, paint);
    _drawCurvedPath(canvas, top, center, paint);

    // Draw some tech lines
    _drawTechLines(canvas, size, dashPaint);
  }

  void _drawCurvedPath(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    
    // Calculate control points for a nice curve
    final cp1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
    final cp2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);
    
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    canvas.drawPath(path, paint);
  }

  void _drawTechLines(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < 10; i++) {
      final x = 200.0 + (i * 100);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, x), Offset(size.width, x), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
