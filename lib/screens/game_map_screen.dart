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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentLevel());
  }

  void _scrollToCurrentLevel() {
    if (!_scrollController.hasClients) return;
    
    final progress = context.read<GameProgressService>();
    int targetZoneIndex = -1;
    
    // Find first incomplete level
    for (int i = 0; i < arGameZones.length; i++) {
      final zone = arGameZones[i];
      for (int j = 0; j < zone.levels.length; j++) {
        if (!progress.isLevelCompleted(zone.levels[j].id)) {
          targetZoneIndex = i;
          break;
        }
      }
      if (targetZoneIndex != -1) break;
    }

    // If all levels complete, scroll to top (Zone 5)
    if (targetZoneIndex == -1) {
      _scrollController.animateTo(
        0,
        duration: 1.seconds,
        curve: Curves.easeInOut,
      );
      return;
    }

    // The zones are reversed in the Column: [Zone 5, Zone 4, Zone 3, Zone 2, Zone 1]
    // Zone 1 is at the bottom, Zone 5 is at the top.
    final totalZones = arGameZones.length;
    final reversedZoneIndex = (totalZones - 1) - targetZoneIndex;
    
    // Estimation: Each zone is roughly 400-500px tall depending on level count
    // Zone title + levels + spacers
    double scrollPosition = reversedZoneIndex * 450.0;
    
    _scrollController.animateTo(
      scrollPosition.clamp(0, _scrollController.position.maxScrollExtent),
      duration: 1.seconds,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          // ── Background Grid ──
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/grid_pattern.png', // Fallback to a custom painter if missing
                repeat: ImageRepeat.repeat,
                errorBuilder: (context, error, stackTrace) => CustomPaint(
                  painter: GridPainter(color: AppTheme.accentCyan.withValues(alpha: 0.2)),
                ),
              ),
            ),
          ),

          // ── Scrollable Map Content ──
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 100), // Top padding
                ...arGameZones.reversed.map((zone) => _buildZone(zone, progress, isDark)),
                const SizedBox(height: 100), // Bottom padding
              ],
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

  Widget _buildZone(ARZone zone, GameProgressService progress, bool isDark) {
    return Column(
      children: [
        // Zone Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Text(
                zone.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTheme.headingSmall.copyWith(
                  color: zone.accentColor,
                  letterSpacing: 1, // Reduced letter spacing
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: zone.accentColor.withValues(alpha: 0.5), blurRadius: 10),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, zone.accentColor, Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Levels
        ...List.generate(zone.levels.length, (index) {
          final level = zone.levels[index];
          final isLocked = progress.isLevelLocked(level.id);
          final stars = progress.getStars(level.id);
          final isLastInZone = index == zone.levels.length - 1;

          return Column(
            children: [
              _buildLevelNode(level, zone.accentColor, isLocked, stars),
              if (!isLastInZone) _buildPath(zone.accentColor, isLocked),
            ],
          );
        }),
        
        // Path to next zone (if not the last zone in the reversed list)
        if (zone.id != arGameZones.last.id)
          _buildPath(Colors.white.withValues(alpha: 0.3), true, isLong: true),
      ],
    );
  }

  Widget _buildLevelNode(ARLevel level, Color accentColor, bool isLocked, int stars) {
    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToLevel(level),
      child: Column(
        children: [
          Container(
            width: level.isBoss ? 100 : 80,
            height: level.isBoss ? 100 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLocked ? Colors.grey.withValues(alpha: 0.1) : Colors.black,
              border: Border.all(
                color: isLocked 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : (level.isBoss ? Colors.red : accentColor),
                width: level.isBoss ? 3 : 2,
              ),
              boxShadow: isLocked ? [] : [
                BoxShadow(
                  color: (level.isBoss ? Colors.red : accentColor).withValues(alpha: 0.3),
                  blurRadius: 15,
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
                    size: level.isBoss ? 40 : 30,
                  ).animate(onPlay: (controller) => controller.repeat())
                   .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.2)),
                
                if (level.isBoss && !isLocked)
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shake(hz: 2, duration: 3.seconds),

                if (isLocked)
                  Icon(Icons.lock_outline_rounded, color: Colors.white.withValues(alpha: 0.2), size: 24),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level.title,
            style: AppTheme.bodySmall.copyWith(
              color: isLocked ? Colors.white.withValues(alpha: 0.3) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isLocked && stars > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => Icon(
                Icons.star_rounded,
                size: 16,
                color: i < stars ? Colors.amber : Colors.white.withValues(alpha: 0.1),
              )),
            ),
        ],
      ).animate(target: isLocked ? 0 : 1)
       .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0))
       .fadeIn(),
    );
  }

  Widget _buildPath(Color color, bool isLocked, {bool isLong = false}) {
    return Container(
      width: 2,
      height: isLong ? 80 : 40,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: CustomPaint(
        painter: DottedLinePainter(
          color: isLocked ? color.withValues(alpha: 0.1) : color,
          animate: !isLocked,
        ),
      ),
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

class DottedLinePainter extends CustomPainter {
  final Color color;
  final bool animate;

  DottedLinePainter({required this.color, required this.animate});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double y = 0;
    while (y < size.height) {
      canvas.drawCircle(Offset(size.width / 2, y), 2, paint);
      y += 10;
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
