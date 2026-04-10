import 'dart:io';

void main() async {
  final file = File('c:\\Users\\Youssef356\\Documents\\Mobile development\\ar_explorer\\lib\\data\\inspector_game_data.dart');
  String content = await file.readAsString();

  final regex = RegExp(r"id: 'iz(4|5)_l3',.*?title: '(.*?)',.*?,\s+(\s+// ── L\d+-BOSS)", dotAll: true);
  
  content = content.replaceAllMapped(regex, (match) {
    final zoneNum = match.group(1);
    final prevTitle = match.group(2);
    final endSection = match.group(3);
    
    final newLevels = '''
    // ── L\${zoneNum}-4 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz\${zoneNum}_l4',
      zoneId: 'zone_inspector_\$zoneNum',
      title: 'Advanced \$prevTitle',
      objective: 'Configure additional settings to master the workflow in this zone.',
      gameObjectName: 'Manager',
      gameObjectIcon: '⚙',
      sceneObjects: [SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: Color(0xFF4FC3F7), fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim, '> Analyzing setup...'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Requires optimization'),
      ],
      hint: 'Use the correct component to resolve the warning and proceed.',
      scriptBank: [
        ScriptChip(
          id: 'gen_correct1',
          label: 'Optimizer Script',
          description: 'A script that finalizes the configuration.',
          dotColor: Color(0xFF00D4AA),
          isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Configuration complete')],
          addFields: [InspectorField(label: 'Status', value: 'Active')],
        ),
        ScriptChip(
          id: 'gen_wrong1',
          label: 'Debug Mode',
          description: 'Enables debug logging.',
          dotColor: Color(0xFFEF5350),
          isCorrect: false,
          errorMessage: 'This is not needed for the optimization.',
        )
      ],
      correctIds: ['gen_correct1'],
      successMessage: 'Configuration applied successfully!',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓ Optimization complete'),
      ],
    ),

    // ── L\${zoneNum}-5 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz\${zoneNum}_l5',
      zoneId: 'zone_inspector_\$zoneNum',
      title: 'Expert \$prevTitle',
      objective: 'Apply the final polish to your environment.',
      gameObjectName: 'Controller',
      gameObjectIcon: '🎛',
      sceneObjects: [SceneObjectType.cube],
      existingComponents: [
        ExistingComponent(name: 'Transform', icon: '⊞', accentColor: Color(0xFF4FC3F7), fields: []),
      ],
      idleTerminal: [
        TerminalLine(TerminalLineType.dim, '> Awaiting finalization...'),
        TerminalLine(TerminalLineType.warning, '> WARNING: Deployment checks pending'),
      ],
      hint: 'Attach the deployment script.',
      scriptBank: [
        ScriptChip(
          id: 'gen_correct2',
          label: 'Deployment Script',
          description: 'Prepares the scene for deployment.',
          dotColor: Color(0xFF00D4AA),
          isCorrect: true,
          addLines: [TerminalLine(TerminalLineType.success, '> Deployment ready')],
          addFields: [InspectorField(label: 'Mode', value: 'Release')],
        ),
        ScriptChip(
          id: 'gen_wrong2',
          label: 'Test Script',
          description: 'Fires test events.',
          dotColor: Color(0xFFEF5350),
          isCorrect: false,
          errorMessage: 'Incorrect mode selected.',
        )
      ],
      correctIds: ['gen_correct2'],
      successMessage: 'Deployment ready!',
      successTerminal: [
        TerminalLine(TerminalLineType.success, '> ✓ Environment finalized'),
      ],
    ),
\$endSection''';
    
    return "\${match.group(0)!.substring(0, match.group(0)!.length - endSection!.length)}\$newLevels";
  });

  await file.writeAsString(content);
}
