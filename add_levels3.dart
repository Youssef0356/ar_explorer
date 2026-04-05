import 'dart:io';

void main() async {
  final file = File('c:\\Users\\Youssef356\\Documents\\Mobile development\\ar_explorer\\lib\\data\\inspector_game_data.dart');
  String content = await file.readAsString();

  content = content.replaceFirst("    InspectorLevel(\r\n      id: 'iz4_boss',", '''
    // ── L4-4 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz4_l4',
      zoneId: 'zone_inspector_4',
      title: 'Advanced Shadows',
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

    // ── L4-5 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz4_l5',
      zoneId: 'zone_inspector_4',
      title: 'Expert Shadows',
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

    InspectorLevel(
      id: 'iz4_boss',
''');

  content = content.replaceFirst("    InspectorLevel(\n      id: 'iz4_boss',", '''
    // ── L4-4 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz4_l4',
      zoneId: 'zone_inspector_4',
      title: 'Advanced Shadows',
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

    // ── L4-5 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz4_l5',
      zoneId: 'zone_inspector_4',
      title: 'Expert Shadows',
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

    InspectorLevel(
      id: 'iz4_boss',
''');

  content = content.replaceFirst("    InspectorLevel(\r\n      id: 'iz5_boss',", '''
    // ── L5-4 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz5_l4',
      zoneId: 'zone_inspector_5',
      title: 'Advanced LiDAR',
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

    // ── L5-5 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz5_l5',
      zoneId: 'zone_inspector_5',
      title: 'Expert LiDAR',
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

    InspectorLevel(
      id: 'iz5_boss',
''');

  content = content.replaceFirst("    InspectorLevel(\n      id: 'iz5_boss',", '''
    // ── L5-4 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz5_l4',
      zoneId: 'zone_inspector_5',
      title: 'Advanced LiDAR',
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

    // ── L5-5 (Generated) ─────────────────────────────────────────────
    InspectorLevel(
      id: 'iz5_l5',
      zoneId: 'zone_inspector_5',
      title: 'Expert LiDAR',
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

    InspectorLevel(
      id: 'iz5_boss',
''');

  await file.writeAsString(content);
}
