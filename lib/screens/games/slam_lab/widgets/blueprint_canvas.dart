import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../models/slam_game_models.dart';

class BlueprintCanvas extends StatelessWidget {
  final SLAMLevel level;
  final Offset sensorPosition;
  final double sensorHeading; // Angle in radians
  final double fastThreshold;
  final bool ransacEnabled;
  final bool isTrackingLocked;
  final bool isDrifting;
  final List<SLAMFeaturePoint> livePoints;
  final double scanAnimationValue; // 0.0 to 1.0 repeating

  const BlueprintCanvas({
    super.key,
    required this.level,
    required this.sensorPosition,
    required this.sensorHeading,
    required this.fastThreshold,
    required this.ransacEnabled,
    required this.isTrackingLocked,
    required this.isDrifting,
    required this.livePoints,
    required this.scanAnimationValue,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CustomPaint(
        painter: _BlueprintPainter(
          level: level,
          sensorPosition: sensorPosition,
          sensorHeading: sensorHeading,
          fastThreshold: fastThreshold,
          ransacEnabled: ransacEnabled,
          isTrackingLocked: isTrackingLocked,
          isDrifting: isDrifting,
          livePoints: livePoints,
          scanPulse: scanAnimationValue,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  final SLAMLevel level;
  final Offset sensorPosition;
  final double sensorHeading;
  final double fastThreshold;
  final bool ransacEnabled;
  final bool isTrackingLocked;
  final bool isDrifting;
  final List<SLAMFeaturePoint> livePoints;
  final double scanPulse;

  _BlueprintPainter({
    required this.level,
    required this.sensorPosition,
    required this.sensorHeading,
    required this.fastThreshold,
    required this.ransacEnabled,
    required this.isTrackingLocked,
    required this.isDrifting,
    required this.livePoints,
    required this.scanPulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Background & Blueprint Grid ──
    final bgPaint = Paint()..color = const Color(0xFF090D1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.06)
      ..strokeWidth = 1.0;
    const gridSize = 24.0;
    for (double x = 0; x < w; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Border Frame
    final framePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(Rect.fromLTWH(1, 1, w - 2, h - 2), framePaint);

    // ── 2. Obstacles & Room Structures ──
    for (final obs in level.obstacles) {
      final rect = Rect.fromLTWH(
        obs.rect.left * w,
        obs.rect.top * h,
        obs.rect.width * w,
        obs.rect.height * h,
      );

      switch (obs.type) {
        case ObstacleType.texturedRug:
          final rugPaint = Paint()
            ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.15);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), rugPaint);
          final rugBorder = Paint()
            ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), rugBorder);
          break;

        case ObstacleType.wall:
          final wallPaint = Paint()
            ..color = const Color(0xFF1E293B).withValues(alpha: 0.8);
          canvas.drawRect(rect, wallPaint);
          final wallBorder = Paint()
            ..color = const Color(0xFF64748B).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawRect(rect, wallBorder);
          break;

        case ObstacleType.reflectiveGlass:
          final glassPaint = Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.12);
          canvas.drawRect(rect, glassPaint);
          final glassBorder = Paint()
            ..color = const Color(0xFF00E5FF).withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;
          canvas.drawRect(rect, glassBorder);
          break;

        case ObstacleType.movingPerson:
          final personPaint = Paint()
            ..color = const Color(0xFFFF5252).withValues(alpha: 0.2);
          canvas.drawCircle(rect.center, rect.width / 2, personPaint);
          final personBorder = Paint()
            ..color = const Color(0xFFFF5252).withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawCircle(rect.center, rect.width / 2, personBorder);
          break;

        case ObstacleType.furniture:
          final furnPaint = Paint()
            ..color = const Color(0xFF2A3B5C).withValues(alpha: 0.4);
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), furnPaint);
          final furnBorder = Paint()
            ..color = const Color(0xFF4FC3F7).withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), furnBorder);
          break;
      }

      // Draw obstacle label
      if (obs.label.isNotEmpty && obs.type != ObstacleType.wall) {
        final textSpan = TextSpan(
          text: obs.label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(rect.center.dx - textPainter.width / 2, rect.center.dy - textPainter.height / 2),
        );
      }
    }

    // ── 3. Sensor Position & FOV Cone ──
    final sensorPixelPos = Offset(sensorPosition.dx * w, sensorPosition.dy * h);
    // Use min(w, h) so FOV scales proportionally on all aspect ratios
    final fovDistance = math.min(w, h) * 0.55;
    const fovHalfAngle = 35.0 * (math.pi / 180.0); // 70 deg total FOV

    final fovColor = isTrackingLocked
        ? const Color(0xFF00E5FF)
        : (isDrifting ? const Color(0xFFFF9100) : const Color(0xFFFF1744));

    // Draw FOV Cone Area
    final fovPath = Path();
    fovPath.moveTo(sensorPixelPos.dx, sensorPixelPos.dy);
    fovPath.arcTo(
      Rect.fromCircle(center: sensorPixelPos, radius: fovDistance),
      sensorHeading - fovHalfAngle,
      fovHalfAngle * 2,
      false,
    );
    fovPath.close();

    final fovFillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          fovColor.withValues(alpha: 0.25),
          fovColor.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: sensorPixelPos, radius: fovDistance));
    canvas.drawPath(fovPath, fovFillPaint);

    final fovBorderPaint = Paint()
      ..color = fovColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(fovPath, fovBorderPaint);

    // Dynamic scan pulse ripple
    final pulseRadius = fovDistance * scanPulse;
    final pulsePaint = Paint()
      ..color = fovColor.withValues(alpha: (1.0 - scanPulse) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: sensorPixelPos, radius: pulseRadius),
      sensorHeading - fovHalfAngle,
      fovHalfAngle * 2,
      false,
      pulsePaint,
    );

    // ── 4. Feature Points & Triangulation Rays ──
    final trackedPoints = <Offset>[];

    for (final pt in livePoints) {
      final ptPixel = Offset(pt.position.dx * w, pt.position.dy * h);
      final diff = ptPixel - sensorPixelPos;
      final dist = diff.distance;
      final angleToPt = math.atan2(diff.dy, diff.dx);

      // Normalize angle difference to [-pi, pi]
      var angleDiff = angleToPt - sensorHeading;
      while (angleDiff > math.pi) {
        angleDiff -= 2 * math.pi;
      }
      while (angleDiff < -math.pi) {
        angleDiff += 2 * math.pi;
      }

      final inFrustum = dist <= fovDistance && angleDiff.abs() <= fovHalfAngle;
      final meetsFastThreshold = pt.contrast >= fastThreshold;

      if (!inFrustum) {
        // Outside FOV: subtle landmark cross
        final unselectedPaint = Paint()
          ..color = const Color(0xFF64748B).withValues(alpha: 0.3)
          ..strokeWidth = 1.0;
        canvas.drawLine(ptPixel + const Offset(-2, 0), ptPixel + const Offset(2, 0), unselectedPaint);
        canvas.drawLine(ptPixel + const Offset(0, -2), ptPixel + const Offset(0, 2), unselectedPaint);
      } else if (!meetsFastThreshold) {
        // Inside FOV but filtered out by FAST threshold: dim yellow/grey dot
        final starvedPaint = Paint()
          ..color = const Color(0xFFFFB74D).withValues(alpha: 0.4);
        canvas.drawCircle(ptPixel, 2.5, starvedPaint);
      } else if (pt.isDynamic && !ransacEnabled) {
        // Dynamic outlier causing tracking drift (RANSAC is OFF)
        final badPointPaint = Paint()
          ..color = const Color(0xFFFF9100);
        canvas.drawCircle(ptPixel, 4, badPointPaint);
        // Draw erratic motion indicator
        final errPaint = Paint()
          ..color = const Color(0xFFFF9100).withValues(alpha: 0.5)
          ..strokeWidth = 1.2;
        canvas.drawLine(sensorPixelPos, ptPixel, errPaint);
      } else if (pt.isDynamic && ransacEnabled) {
        // Dynamic point rejected by RANSAC!
        final rejectedPaint = Paint()
          ..color = const Color(0xFFFF1744)
          ..strokeWidth = 1.5;
        canvas.drawLine(ptPixel + const Offset(-3, -3), ptPixel + const Offset(3, 3), rejectedPaint);
        canvas.drawLine(ptPixel + const Offset(-3, 3), ptPixel + const Offset(3, -3), rejectedPaint);
      } else {
        // Valid static feature point tracked!
        trackedPoints.add(ptPixel);

        final trackPaint = Paint()
          ..color = const Color(0xFF00E676);
        canvas.drawCircle(ptPixel, 4.0, trackPaint);

        final glowPaint = Paint()
          ..color = const Color(0xFF00E676).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(ptPixel, 7.0, glowPaint);

        // Triangulation ray to sensor
        final rayPaint = Paint()
          ..color = const Color(0xFF00E676).withValues(alpha: 0.35)
          ..strokeWidth = 1.0;
        canvas.drawLine(sensorPixelPos, ptPixel, rayPaint);
      }
    }

    // ── 5. Triangulation Mesh Between Tracked Points (Epipolar Graph) ──
    if (trackedPoints.length >= 4) {
      final meshPaint = Paint()
        ..color = const Color(0xFF00E676).withValues(alpha: 0.18)
        ..strokeWidth = 1.0;
      final maxConnectionDist = math.min(w, h) * 0.45;
      for (int i = 0; i < trackedPoints.length; i++) {
        for (int j = i + 1; j < trackedPoints.length; j++) {
          if ((trackedPoints[i] - trackedPoints[j]).distance < maxConnectionDist) {
            canvas.drawLine(trackedPoints[i], trackedPoints[j], meshPaint);
          }
        }
      }
    }

    // ── 6. Sensor Rig / Drone Body ──
    final dronePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(sensorPixelPos, 14, dronePaint);

    final droneRing = Paint()
      ..color = fovColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(sensorPixelPos, 14, droneRing);

    final droneCenter = Paint()..color = Colors.white;
    canvas.drawCircle(sensorPixelPos, 4, droneCenter);

    // Heading indicator arrow
    final arrowLength = 20.0;
    final tip = sensorPixelPos + Offset(math.cos(sensorHeading) * arrowLength, math.sin(sensorHeading) * arrowLength);
    final arrowPaint = Paint()
      ..color = fovColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(sensorPixelPos, tip, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _BlueprintPainter oldDelegate) {
    return true; // Live 60 FPS animation
  }
}
