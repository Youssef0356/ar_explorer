import 'dart:io';

void main() {
  final files = [
    'lib/screens/coding_challenge_screen.dart',
    'lib/screens/coding_game_map_screen.dart',
    'lib/screens/ar_debugger_game.dart',
    'lib/screens/inspector_game_screen.dart',
    'lib/screens/inspector_game_map_screen.dart'
  ];

  for (final path in files) {
    var file = File(path);
    if (!file.existsSync()) {
      print('File not found: \$path');
      continue;
    }
    var content = file.readAsStringSync();
    var original = content;

    // We don't want to mess up. Instead of replacing with AppTheme colors, we can just replace:
    // Colors.white -> (isDark ? Colors.white : Colors.black)
    // Colors.white12 -> (isDark ? Colors.white12 : Colors.black12)
    // Colors.white24 -> (isDark ? Colors.white24 : Colors.black26)
    // Colors.white38 -> (isDark ? Colors.white38 : Colors.black38)
    // Colors.white54 -> (isDark ? Colors.white54 : Colors.black54)
    // Colors.white70 -> (isDark ? Colors.white70 : Colors.black87)
    // Color(0xFF060B14), Color(0xFF0A0E1A), Color(0xFF0A1120), Color(0xFF0F1420), Color(0xFF161B29), Color(0xFF1E2638)
    // Let's abstract that to:
    // (isDark ? const Color(...) : Colors.white) or (isDark ? const Color(...) : Colors.grey[100])

    content = content.replaceAll("Colors.white12", "(Theme.of(context).brightness == Brightness.dark ? Colors.white12 : Colors.black12)");
    content = content.replaceAll("Colors.white24", "(Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black26)");
    content = content.replaceAll("Colors.white38", "(Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.black38)");
    content = content.replaceAll("Colors.white54", "(Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54)");
    content = content.replaceAll("Colors.white70", "(Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)");
    content = content.replaceAll("Colors.white", "(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)");

    // Fix possible bad replacements (e.g. Colors.white.withOpacity -> (Theme...).withOpacity)
    content = content.replaceAll("(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withOpacity", "(Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity : Colors.black.withOpacity)");
    content = content.replaceAll("(Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black).withValues", "(Theme.of(context).brightness == Brightness.dark ? Colors.white.withValues : Colors.black.withValues)");

    // Backgrounds
    content = content.replaceAll("const Color(0xFF0A0E1A)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0E1A) : Colors.white)");
    content = content.replaceAll("const Color(0xFF060B14)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF060B14) : Colors.white)");
    content = content.replaceAll("Color(0xFF0A0E1A)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A0E1A) : Colors.white)");
    content = content.replaceAll("Color(0xFF060B14)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF060B14) : Colors.white)");

    // Secondary Backgrounds / cards
    content = content.replaceAll("const Color(0xFF0A1120)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1120) : Colors.grey.shade50)");
    content = content.replaceAll("const Color(0xFF0F1420)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1420) : Colors.grey.shade50)");
    content = content.replaceAll("const Color(0xFF161B29)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161B29) : Colors.white)");
    content = content.replaceAll("const Color(0xFF1E2638)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2638) : Colors.grey.shade100)");

    content = content.replaceAll("Color(0xFF0A1120)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0A1120) : Colors.grey.shade50)");
    content = content.replaceAll("Color(0xFF0F1420)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1420) : Colors.grey.shade50)");
    content = content.replaceAll("Color(0xFF161B29)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161B29) : Colors.white)");
    content = content.replaceAll("Color(0xFF1E2638)", "(Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2638) : Colors.grey.shade100)");

    if (content != original) {
      file.writeAsStringSync(content);
      print('Updated \$path');
    }
  }
}
