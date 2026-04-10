import 'dart:io';

void main() async {
  final file = File('c:\\Users\\Youssef356\\Documents\\Mobile development\\ar_explorer\\lib\\data\\inspector_game_data.dart');
  String content = await file.readAsString();

  final regex = RegExp(r"(    // ── L([45])\-([45]) \(Generated\).*?successTerminal: \[\s+TerminalLine\(TerminalLineType\.success, '> ✓ Environment finalized'\),\s+\],\s+\),\s+)", dotAll: true);
  
  // This matches the second generated level (L4-5 or L5-5) block. We'll find all the blocks of 4-4, 4-5, 5-4, 5-5 and just write a custom remover.
  
  // A safer way: just read line by line. If we encounter `id: 'iz4_l4'`, and we have seen it before, we skip until `    ),`.
  final lines = content.split('\n');
  final result = <String>[];
  
  final seenIds = <String>{};
  bool skipping = false;
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (!skipping) {
      if (line.contains("id: 'iz4_l4'") || line.contains("id: 'iz4_l5'") || line.contains("id: 'iz5_l4'") || line.contains("id: 'iz5_l5'")) {
        final idMatch = RegExp(r"id: '(iz[45]_l[45])'").firstMatch(line)?.group(1);
        if (idMatch != null) {
          if (seenIds.contains(idMatch)) {
            skipping = true;
            // Also we need to pop the previous two lines which might be the comment and the "InspectorLevel("
            if (result.length >= 2 && result[result.length - 1].contains("InspectorLevel(") && result[result.length - 2].contains("// ── L")) {
              result.removeLast();
              result.removeLast();
            } else if (result.length >= 1 && result[result.length - 1].contains("InspectorLevel(")) {
              result.removeLast();
            }
            continue;
          } else {
            seenIds.add(idMatch);
          }
        }
      }
      result.add(line);
    } else {
      // we are skipping until we see the close
      if (line == "    ),") {
        skipping = false;
      } else if (line == "    ),\r" || line.trim() == "),") {
        skipping = false;
      }
    }
  }

  await file.writeAsString(result.join('\n'));
}
