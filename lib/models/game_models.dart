import 'package:flutter/material.dart';

enum ARNodeType {
  input,      // Camera, Sensors
  process,    // Detection, Tracking
  output,     // Rendering, Anchoring
  utility     // Logic, Session
}

enum GameMode {
  pipeline,   // Drag-and-drop pipeline ordering
  fillIn,     // Code fill-in-the-blank
  mcq,        // Multiple choice concept questions
  debug,      // Debug the broken pipeline
  boss,       // Multi-mechanic boss battle
}

class ARNode {
  final String id;
  final String name;
  final String description;
  final String hint;
  final IconData icon;
  final ARNodeType type;
  final String? errorMessage;

  const ARNode({
    required this.id,
    required this.name,
    required this.description,
    this.hint = '',
    required this.icon,
    required this.type,
    this.errorMessage,
  });
}

class ARLevel {
  final String id;
  final String title;
  final String projectTask;
  final String goal;
  final String buildContext;
  final List<String> correctSequence;
  final List<ARNode> availableNodes;
  final bool isBoss;
  final int timeLimit;
  final String zoneId;
  final bool isFree;
  final GameMode mode;

  const ARLevel({
    required this.id,
    required this.title,
    this.projectTask = '',
    required this.goal,
    this.buildContext = '',
    required this.correctSequence,
    required this.availableNodes,
    this.isBoss = false,
    this.timeLimit = 0,
    required this.zoneId,
    this.isFree = false,
    this.mode = GameMode.pipeline,
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

// ── Code Fill-In Models ───────────────────────────────────────────────────────

class CodeBlank {
  final String id;
  final String correctToken;
  final String hint;
  final String explanation;

  const CodeBlank({
    required this.id,
    required this.correctToken,
    this.hint = '',
    this.explanation = '',
  });
}

class CodeChallenge {
  final String id;
  final String zoneId;
  final String title;
  final String subtitle;
  final String language;           // 'csharp', 'swift', 'kotlin', 'cpp'
  final String codeTemplate;       // Code with ___BLANK_ID___ markers
  final List<CodeBlank> blanks;
  final List<String> distractors;  // Wrong tokens in the word bank
  final bool isBoss;
  final int timeLimit;             // 0 = no timer
  final bool isFree;

  const CodeChallenge({
    required this.id,
    required this.zoneId,
    required this.title,
    this.subtitle = '',
    required this.language,
    required this.codeTemplate,
    required this.blanks,
    this.distractors = const [],
    this.isBoss = false,
    this.timeLimit = 0,
    this.isFree = false,
  });

  List<String> get allTokens {
    final correct = blanks.map((b) => b.correctToken).toList();
    return [...correct, ...distractors]..shuffle();
  }
}

class CodeZone {
  final String id;
  final String name;
  final String platform;
  final IconData icon;
  final Color accentColor;
  final List<CodeChallenge> challenges;

  const CodeZone({
    required this.id,
    required this.name,
    required this.platform,
    required this.icon,
    required this.accentColor,
    required this.challenges,
  });
}
