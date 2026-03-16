import 'package:flutter/material.dart';

class CodingZone {
  final String id;
  final String name;
  final String platform;
  final IconData icon;
  final Color accentColor;
  final List<CodingLevel> levels;

  const CodingZone({
    required this.id,
    required this.name,
    required this.platform,
    required this.icon,
    required this.accentColor,
    required this.levels,
  });
}

class CodingLevel {
  final String id;
  final String title;
  final String goal;
  final List<CodeLine> lines;
  final List<WordChip> wordBank;
  final String mascotHint;
  final String feedbackExplanation;
  final bool isBoss;
  final int timeLimit; // seconds, 0 for unlimited

  const CodingLevel({
    required this.id,
    required this.title,
    required this.goal,
    required this.lines,
    required this.wordBank,
    required this.mascotHint,
    required this.feedbackExplanation,
    this.isBoss = false,
    this.timeLimit = 0,
  });
}

class CodeLine {
  final String? text; // Plain text if not using slots
  final List<CodeSlot>? slots; // Inline slots if any
  final int indent; // number of tab spaces

  const CodeLine({
    this.text,
    this.slots,
    this.indent = 0,
  });

  bool get isPlain => text != null && slots == null;
  bool get hasSlots => slots != null;
}

class CodeSlot {
  final String id;
  final String label; // placeholder text or expected text for internal use
  String? currentWordChipId;

  CodeSlot({
    required this.id,
    required this.label,
    this.currentWordChipId,
  });
}

class WordChip {
  final String id;
  final String label; // the code text
  final String correctSlotId; // the slot this chip belongs in

  const WordChip({
    required this.id,
    required this.label,
    required this.correctSlotId,
  });
}
