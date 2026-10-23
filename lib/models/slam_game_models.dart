import 'package:flutter/material.dart';

enum ObstacleType {
  wall,
  movingPerson,
  reflectiveGlass,
  texturedRug,
  furniture,
}

class SLAMFeaturePoint {
  final String id;
  Offset position;
  final double contrast; // 0.0 to 1.0 (FAST response strength)
  final bool isDynamic; // Moving obstacle (person/pet)
  final bool isReflective; // Mirror / glass (breaks epipolar geometry)
  Offset velocity; // For dynamic entities
  bool isTracked;
  double stability;

  SLAMFeaturePoint({
    required this.id,
    required this.position,
    required this.contrast,
    this.isDynamic = false,
    this.isReflective = false,
    this.velocity = Offset.zero,
    this.isTracked = false,
    this.stability = 1.0,
  });

  SLAMFeaturePoint copyWith({
    Offset? position,
    bool? isTracked,
    double? stability,
  }) {
    return SLAMFeaturePoint(
      id: id,
      position: position ?? this.position,
      contrast: contrast,
      isDynamic: isDynamic,
      isReflective: isReflective,
      velocity: velocity,
      isTracked: isTracked ?? this.isTracked,
      stability: stability ?? this.stability,
    );
  }
}

class SLAMObstacle {
  final String id;
  final Rect rect;
  final ObstacleType type;
  final String label;
  final Color? customColor;

  const SLAMObstacle({
    required this.id,
    required this.rect,
    required this.type,
    required this.label,
    this.customColor,
  });
}

class SLAMLevel {
  final String id;
  final int levelNumber;
  final String title;
  final String subtitle;
  final String description;
  final String conceptExplanation; // Real-world ARCore / ARKit explanation
  final List<Offset> sensorWaypoints; // Drone/camera movement path (normalized 0.0 to 1.0)
  final double pathDurationSeconds;
  final List<SLAMFeaturePoint> featurePoints;
  final List<SLAMObstacle> obstacles;
  final double defaultFastThreshold;
  final bool defaultRansacEnabled;
  final int xpReward;
  final String practicalTip;

  const SLAMLevel({
    required this.id,
    required this.levelNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.conceptExplanation,
    required this.sensorWaypoints,
    this.pathDurationSeconds = 18.0,
    required this.featurePoints,
    required this.obstacles,
    this.defaultFastThreshold = 0.45,
    this.defaultRansacEnabled = false,
    this.xpReward = 40,
    required this.practicalTip,
  });
}
