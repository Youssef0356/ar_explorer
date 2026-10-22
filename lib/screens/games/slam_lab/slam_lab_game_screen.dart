import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/app_theme.dart';
import '../../../data/games/slam_game_data.dart';
import '../../../models/slam_game_models.dart';
import '../../../services/game_progress_service.dart';
import '../../../services/sound_service.dart';
import '../../../services/theme_service.dart';
import 'widgets/blueprint_canvas.dart';
import 'widgets/algorithm_control_dock.dart';
import 'widgets/slam_hud_overlay.dart';

class SlamLabGameScreen extends StatefulWidget {
  final SLAMLevel level;

  const SlamLabGameScreen({
    super.key,
    required this.level,
  });

  @override
  State<SlamLabGameScreen> createState() => _SlamLabGameScreenState();
}

class _SlamLabGameScreenState extends State<SlamLabGameScreen>
    with SingleTickerProviderStateMixin {
  late double _fastThreshold;
  late bool _ransacEnabled;

  Timer? _gameLoopTimer;
  late List<SLAMFeaturePoint> _livePoints;

  double _timeElapsed = 0.0;
  bool _isPlaying = true;
  bool _isGameOver = false;

  // Real-time tracking telemetry
  double _accumulatedDrift = 0.0;
  double _timeInLock = 0.0;
  int _activePointsCount = 0;
  bool _isTrackingLocked = false;
  bool _isDrifting = false;
  double _confidence = 1.0;
  double _scanPulse = 0.0;

  // Sensor state
  Offset _sensorPosition = const Offset(0.5, 0.5);
  double _sensorHeading = 0.0; // Radians

  @override
  void initState() {
    super.initState();
    _fastThreshold = widget.level.defaultFastThreshold;
    _ransacEnabled = widget.level.defaultRansacEnabled;

    // Deep copy initial points
    _livePoints = widget.level.featurePoints
        .map((p) => p.copyWith(position: p.position))
        .toList();

    _sensorPosition = widget.level.sensorWaypoints.first;
    _startGameLoop();
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    super.dispose();
  }

  void _startGameLoop() {
    _gameLoopTimer?.cancel();
    const frameDuration = Duration(milliseconds: 33); // ~30 fps update
    _gameLoopTimer = Timer.periodic(frameDuration, (timer) {
      if (!_isPlaying || _isGameOver) return;
      _updatePhysics(0.033);
    });
  }

  void _updatePhysics(double dt) {
    setState(() {
      _timeElapsed += dt;

      // ── 1. Animate scan ripple ──
      _scanPulse = (_scanPulse + dt * 1.2) % 1.0;

      // ── 2. Interpolate sensor position along waypoints ──
      final totalWaypoints = widget.level.sensorWaypoints.length;
      final progressRatio = (_timeElapsed / widget.level.pathDurationSeconds).clamp(0.0, 1.0);
      final segmentProgress = progressRatio * (totalWaypoints - 1);
      final currentIndex = segmentProgress.floor().clamp(0, totalWaypoints - 2);
      final t = segmentProgress - currentIndex;

      final p0 = widget.level.sensorWaypoints[currentIndex];
      final p1 = widget.level.sensorWaypoints[currentIndex + 1];

      _sensorPosition = Offset.lerp(p0, p1, t) ?? p0;
      final delta = p1 - p0;
      if (delta.distance > 0.001) {
        _sensorHeading = math.atan2(delta.dy, delta.dx);
      }

      // ── 3. Animate dynamic moving points ──
      for (final pt in _livePoints) {
        if (pt.isDynamic && pt.velocity != Offset.zero) {
          var newPos = pt.position + pt.velocity * dt;
          // Bounce off bounds
          if (newPos.dx < 0.1 || newPos.dx > 0.9) {
            pt.velocity = Offset(-pt.velocity.dx, pt.velocity.dy);
          }
          if (newPos.dy < 0.1 || newPos.dy > 0.9) {
            pt.velocity = Offset(pt.velocity.dx, -pt.velocity.dy);
          }
          pt.position = newPos;
        }
      }

      // ── 4. Calculate FOV & Tracking Constraints ──
      const fovDistance = 0.42;
      const fovHalfAngle = 35.0 * (math.pi / 180.0);

      int validStaticPoints = 0;
      int dynamicNoisePoints = 0;

      for (final pt in _livePoints) {
        final diff = pt.position - _sensorPosition;
        final dist = diff.distance;
        final angleToPt = math.atan2(diff.dy, diff.dx);

        var angleDiff = angleToPt - _sensorHeading;
        while (angleDiff > math.pi) {
          angleDiff -= 2 * math.pi;
        }
        while (angleDiff < -math.pi) {
          angleDiff += 2 * math.pi;
        }

        final inFrustum = dist <= fovDistance && angleDiff.abs() <= fovHalfAngle;
        final meetsContrast = pt.contrast >= _fastThreshold;

        if (inFrustum && meetsContrast) {
          if (pt.isDynamic) {
            if (!_ransacEnabled) {
              dynamicNoisePoints++;
            }
          } else {
            validStaticPoints++;
          }
        }
      }

      _activePointsCount = validStaticPoints;

      // ── 5. Triangulation & Drift Math ──
      if (dynamicNoisePoints > 0) {
        // Dynamic moving points corrupt rigid-body ego-motion!
        _isTrackingLocked = false;
        _isDrifting = true;
        _accumulatedDrift += (0.08 * dynamicNoisePoints);
        _confidence = (_confidence - 0.03).clamp(0.1, 1.0);
      } else if (validStaticPoints >= 4) {
        // Minimum 4 points satisfied -> Full 6DoF Pose Lock
        _isTrackingLocked = true;
        _isDrifting = false;
        _timeInLock += dt;
        _confidence = (_confidence + 0.05).clamp(0.0, 1.0);
      } else {
        // Less than 4 points -> Underdetermined geometry -> Drift accumulation
        _isTrackingLocked = false;
        _isDrifting = true;
        _accumulatedDrift += (0.04 * (4 - validStaticPoints));
        _confidence = (_confidence - 0.02).clamp(0.2, 1.0);
      }

      // ── 6. Level Completion or Failure ──
      if (_accumulatedDrift > 18.0) {
        _endGame(success: false);
      } else if (_timeElapsed >= widget.level.pathDurationSeconds) {
        _endGame(success: true);
      }
    });
  }

  void _triggerRelocalize() {
    final sound = context.read<SoundService>();
    sound.playSuccess();

    setState(() {
      _accumulatedDrift = math.max(0.0, _accumulatedDrift - 6.0);
      _confidence = 1.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.loop_rounded, color: AppTheme.accentCyan, size: 20),
            SizedBox(width: 10),
            Text('Loop Closure Activated! Drift corrected to 0.0mm'),
          ],
        ),
        backgroundColor: AppTheme.cardDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _endGame({required bool success}) async {
    _isGameOver = true;
    _gameLoopTimer?.cancel();

    final sound = context.read<SoundService>();
    if (success) {
      sound.playSuccess();
      HapticFeedback.mediumImpact();

      // Calculate Stars (1 to 3)
      final lockRatio = _timeInLock / widget.level.pathDurationSeconds;
      int stars = 1;
      if (_accumulatedDrift <= 4.0 && lockRatio >= 0.70) {
        stars = 3;
      } else if (_accumulatedDrift <= 8.0 && lockRatio >= 0.45) {
        stars = 2;
      }

      await context.read<GameProgressService>().completeLevel(
            widget.level.id,
            stars,
            unifiedXPReward: widget.level.xpReward,
          );

      if (mounted) {
        _showResultDialog(stars: stars, success: true);
      }
    } else {
      sound.playFailure();
      HapticFeedback.heavyImpact();
      if (mounted) {
        _showResultDialog(stars: 0, success: false);
      }
    }
  }

  void _showResultDialog({required int stars, required bool success}) {
    final isDark = context.read<ThemeService>().isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: success ? AppTheme.accentCyan : const Color(0xFFFF1744),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (success ? AppTheme.accentCyan : const Color(0xFFFF1744)).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Badge
                    Icon(
                      success ? Icons.verified_rounded : Icons.warning_amber_rounded,
                      size: 56,
                      color: success ? AppTheme.accentCyan : const Color(0xFFFF1744),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 12),

                    Text(
                      success ? 'LAB CHALLENGE CLEARED!' : 'TRACKING LOST (EXCESS DRIFT)',
                      textAlign: TextAlign.center,
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimaryC(isDark),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Star rating
                    if (success) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final hasStar = index < stars;
                          return Icon(
                            hasStar ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 36,
                            color: hasStar ? AppTheme.accentAmber : AppTheme.textMutedC(isDark),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+${widget.level.xpReward} XP EARNED',
                        style: const TextStyle(
                          color: AppTheme.accentCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Metrics summary
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Final Drift:', style: TextStyle(color: AppTheme.textMutedC(isDark), fontSize: 12)),
                              Text('${_accumulatedDrift.toStringAsFixed(1)} mm', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Locked Duration:', style: TextStyle(color: AppTheme.textMutedC(isDark), fontSize: 12)),
                              Text('${((_timeInLock / widget.level.pathDurationSeconds) * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Real-world concept explanation
                    Text(
                      widget.level.conceptExplanation,
                      style: TextStyle(
                        color: AppTheme.textSecondaryC(isDark),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _restartLevel();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppTheme.dividerC(isDark)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Retry'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              if (success && widget.level.levelNumber < allSlamLevels.length) {
                                final nextLevel = allSlamLevels[widget.level.levelNumber];
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => SlamLabGameScreen(level: nextLevel)),
                                );
                              } else {
                                Navigator.pop(context); // Back to map
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCyan,
                              foregroundColor: AppTheme.primaryDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(success ? 'Continue' : 'Exit'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _restartLevel() {
    setState(() {
      _timeElapsed = 0.0;
      _accumulatedDrift = 0.0;
      _timeInLock = 0.0;
      _confidence = 1.0;
      _isGameOver = false;
      _isPlaying = true;
      _fastThreshold = widget.level.defaultFastThreshold;
      _ransacEnabled = widget.level.defaultRansacEnabled;
      _livePoints = widget.level.featurePoints.map((p) => p.copyWith(position: p.position)).toList();
    });
    _startGameLoop();
  }

  void _showHelpDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: AppTheme.accentCyan, size: 24),
            const SizedBox(width: 10),
            Text('Lab Briefing', style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimaryC(isDark))),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.level.description, style: TextStyle(color: AppTheme.textPrimaryC(isDark), fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentCyan, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.level.practicalTip,
                        style: const TextStyle(color: AppTheme.accentCyan, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final sound = context.read<SoundService>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF05070E) : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimaryC(isDark)),
          onPressed: () {
            sound.playTap();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LAB 0${widget.level.levelNumber} // SLAM SIMULATOR',
              style: const TextStyle(
                color: AppTheme.accentCyan,
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.level.title,
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.textPrimaryC(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppTheme.accentCyan),
            onPressed: () {
              sound.playTap();
              _showHelpDialog(isDark);
            },
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
            color: AppTheme.accentCyan,
            onPressed: () {
              sound.playTap();
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            if (isLandscape) {
              // ── Tablet / Landscape Mode: Side-by-side 2-column layout ──
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Column: Interactive Canvas with floating HUD
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BlueprintCanvas(
                              level: widget.level,
                              sensorPosition: _sensorPosition,
                              sensorHeading: _sensorHeading,
                              fastThreshold: _fastThreshold,
                              ransacEnabled: _ransacEnabled,
                              isTrackingLocked: _isTrackingLocked,
                              isDrifting: _isDrifting,
                              livePoints: _livePoints,
                              scanAnimationValue: _scanPulse,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: SlamHudOverlay(
                              activePointsCount: _activePointsCount,
                              confidence: _confidence,
                              accumulatedDriftMm: _accumulatedDrift,
                              timeElapsed: _timeElapsed,
                              totalDuration: widget.level.pathDurationSeconds,
                              isTrackingLocked: _isTrackingLocked,
                              isDrifting: _isDrifting,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Right Column: Controls in dedicated panel
                    SizedBox(
                      width: 320,
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: AlgorithmControlDock(
                            fastThreshold: _fastThreshold,
                            onFastThresholdChanged: (val) => setState(() => _fastThreshold = val),
                            ransacEnabled: _ransacEnabled,
                            onRansacToggled: (val) => setState(() => _ransacEnabled = val),
                            onRelocalize: _triggerRelocalize,
                            isRelocalizeAvailable: widget.level.levelNumber == 5 && _accumulatedDrift > 2.0,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Portrait Mode (Phones & Portrait Tablets) ──
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // 1. HUD Telemetry Overlay
                      SlamHudOverlay(
                        activePointsCount: _activePointsCount,
                        confidence: _confidence,
                        accumulatedDriftMm: _accumulatedDrift,
                        timeElapsed: _timeElapsed,
                        totalDuration: widget.level.pathDurationSeconds,
                        isTrackingLocked: _isTrackingLocked,
                        isDrifting: _isDrifting,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 12),

                      // 2. Interactive Blueprint Canvas
                      Expanded(
                        child: BlueprintCanvas(
                          level: widget.level,
                          sensorPosition: _sensorPosition,
                          sensorHeading: _sensorHeading,
                          fastThreshold: _fastThreshold,
                          ransacEnabled: _ransacEnabled,
                          isTrackingLocked: _isTrackingLocked,
                          isDrifting: _isDrifting,
                          livePoints: _livePoints,
                          scanAnimationValue: _scanPulse,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Player Algorithm Control Dock
                      AlgorithmControlDock(
                        fastThreshold: _fastThreshold,
                        onFastThresholdChanged: (val) => setState(() => _fastThreshold = val),
                        ransacEnabled: _ransacEnabled,
                        onRansacToggled: (val) => setState(() => _ransacEnabled = val),
                        onRelocalize: _triggerRelocalize,
                        isRelocalizeAvailable: widget.level.levelNumber == 5 && _accumulatedDrift > 2.0,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
