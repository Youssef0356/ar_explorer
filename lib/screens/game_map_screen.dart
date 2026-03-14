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
              Column(
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
                style: AppTheme.headingSmall.copyWith(
                  color: zone.accentColor,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: zone.accentColor.withValues(alpha: 0.5), blurRadius: 10),
                  ],
                ),
              ),
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
        
        // Path to next zone if applicable
        if (zone.id != arGameZones.first.id)
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
    context.read<SoundService>().playTap();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GamePipelineScreen(level: level)),
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
