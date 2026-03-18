import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  INSPECTOR GAME — Data Models
//  The "XR Builder" game: a fake Unity Inspector where players drag real
//  Unity/AR Foundation script names onto a GameObject to achieve an objective.
//  New users see real consequences in the 3D viewport + terminal instantly.
// ═══════════════════════════════════════════════════════════════════════════

// ── Scene Object Types ────────────────────────────────────────────────────────
// Each level declares which scene objects exist and which scripts make them appear.

enum SceneObjectType {
  camera,         // 📷 The AR/XR Camera
  xrRig,          // 🥽 XR Origin / Rig
  handLeft,       // 🤚 Left hand mesh
  handRight,      // 🖐 Right hand mesh
  cube,           // 📦 A grabbable cube
  plane,          // ▭  A detected AR plane (floor/wall)
  lightProbe,     // 💡 A light probe sphere
  avatar,         // 🧍 A virtual avatar
  portal,         // 🌀 A portal / teleport zone
  spatialAnchor,  // 📌 A persistent cloud anchor
}

// ── Inspector Field ───────────────────────────────────────────────────────────
// A read-only property row shown inside an expanded component, e.g.
//   Mass  |  1 kg
class InspectorField {
  final String label;
  final String value;
  const InspectorField({required this.label, required this.value});
}

// ── Terminal Line ─────────────────────────────────────────────────────────────
enum TerminalLineType { dim, info, success, warning, error }

class TerminalLine {
  final TerminalLineType type;
  final String message;
  const TerminalLine(this.type, this.message);
}

// ── Existing Component ────────────────────────────────────────────────────────
// A locked component already on the GameObject that the player cannot remove.
class ExistingComponent {
  final String name;
  final String icon;       // emoji icon
  final Color accentColor;
  final List<InspectorField> fields;
  const ExistingComponent({
    required this.name,
    required this.icon,
    required this.accentColor,
    this.fields = const [],
  });
}

// ── Script Chip ───────────────────────────────────────────────────────────────
// An item in the "Add Script" bank at the bottom of the Inspector.
// correct = true  → the player needs to add this
// correct = false → distractor; adding it logs an error and costs a star
class ScriptChip {
  final String id;
  final String label;              // Displayed name, e.g. "AR Camera Background"
  final String description;        // Tooltip / hint text
  final Color dotColor;
  final bool isCorrect;

  // What happens when this script is placed correctly:
  final List<TerminalLine> addLines;        // Lines logged to the terminal
  final List<InspectorField> addFields;     // Fields shown in the expanded component
  final List<SceneObjectType> activates;    // Scene objects that light up / appear

  // Wrong-script penalty message (only used when isCorrect == false)
  final String errorMessage;

  const ScriptChip({
    required this.id,
    required this.label,
    required this.description,
    required this.dotColor,
    this.isCorrect = true,
    this.addLines = const [],
    this.addFields = const [],
    this.activates = const [],
    this.errorMessage = '',
  });
}

// ── Inspector Level ───────────────────────────────────────────────────────────
class InspectorLevel {
  final String id;
  final String zoneId;
  final String title;

  // Plain-language objective shown at the top — written for absolute beginners
  final String objective;

  // The name shown in the Inspector header, e.g. "Main Camera", "XR Rig"
  final String gameObjectName;

  // Emoji icon for the GameObject in the header
  final String gameObjectIcon;

  // Scene objects present (but dim) at start
  final List<SceneObjectType> sceneObjects;

  // Components already on the object (locked, grey header)
  final List<ExistingComponent> existingComponents;

  // Terminal state at idle (before any scripts placed)
  final List<TerminalLine> idleTerminal;

  // All script chips (correct + distractors) — shown shuffled in the bank
  final List<ScriptChip> scriptBank;

  // IDs of chips that must be placed to win (order doesn't matter)
  final List<String> correctIds;

  // Message shown in the success overlay
  final String successMessage;

  // Terminal lines printed after successful validation
  final List<TerminalLine> successTerminal;

  // Hint text (costs a star when revealed)
  final String hint;

  final bool isBoss;
  final int timeLimit;   // 0 = no timer
  final bool isFree;

  const InspectorLevel({
    required this.id,
    required this.zoneId,
    required this.title,
    required this.objective,
    required this.gameObjectName,
    this.gameObjectIcon = '🎮',
    required this.sceneObjects,
    this.existingComponents = const [],
    required this.idleTerminal,
    required this.scriptBank,
    required this.correctIds,
    required this.successMessage,
    required this.successTerminal,
    required this.hint,
    this.isBoss = false,
    this.timeLimit = 0,
    this.isFree = false,
  });
}

// ── Inspector Zone ────────────────────────────────────────────────────────────
class InspectorZone {
  final String id;
  final String name;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final List<InspectorLevel> levels;

  const InspectorZone({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.levels,
  });
}

// ── Game State (runtime only, not stored in data) ─────────────────────────────
// Used by InspectorGameScreen to track the live session.
class InspectorGameState {
  final Set<String> placedScriptIds;
  final int mistakeCount;
  final int hintsUsed;

  const InspectorGameState({
    this.placedScriptIds = const {},
    this.mistakeCount = 0,
    this.hintsUsed = 0,
  });

  InspectorGameState copyWith({
    Set<String>? placedScriptIds,
    int? mistakeCount,
    int? hintsUsed,
  }) => InspectorGameState(
    placedScriptIds: placedScriptIds ?? this.placedScriptIds,
    mistakeCount: mistakeCount ?? this.mistakeCount,
    hintsUsed: hintsUsed ?? this.hintsUsed,
  );

  bool get allCorrectPlaced => false; // computed externally using level.correctIds

  /// Stars earned: 3 = perfect, 2 = ≤1 mistake, 1 = completed with errors
  int starsEarned(int totalMistakes, int totalHints) {
    if (totalMistakes == 0 && totalHints == 0) return 3;
    if (totalMistakes <= 1) return 2;
    return 1;
  }
}
