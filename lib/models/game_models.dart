import 'package:flutter/material.dart';

enum ARNodeType {
  input,      // Camera, Sensors
  process,    // Detection, Tracking
  output,     // Rendering, Anchoring
  utility     // Logic, Session
}

class ARNode {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final ARNodeType type;
  final String? errorMessage;

  const ARNode({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    this.errorMessage,
  });
}

class ARLevel {
  final String id;
  final String title;
  final String goal;
  final List<String> correctSequence; // IDs of ARNodes
  final List<ARNode> availableNodes;
  final bool isBoss;
  final int timeLimit; // seconds, 0 for unlimited
  final String zoneId;

  const ARLevel({
    required this.id,
    required this.title,
    required this.goal,
    required this.correctSequence,
    required this.availableNodes,
    this.isBoss = false,
    this.timeLimit = 0,
    required this.zoneId,
  });
}

class ARZone {
  final String id;
  final String name;
  final Color accentColor;
  final List<ARLevel> levels;

  const ARZone({
    required this.id,
    required this.name,
    required this.accentColor,
    required this.levels,
  });
}
