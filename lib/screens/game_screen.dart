import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/progress_service.dart';


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game State
  int _currentLevel = 0;
  bool _levelComplete = false;
  int _score = 0;
  List<String> _terminalOutput = ['\n> Initializing AR Subsystem...'];

  // Level Data
  final List<_LevelData> _levels = [
    _LevelData(
      title: 'ARCore: Plane Detection',
      instructions: 'Drag the correct code blocks to complete the ARCore plane placement loop.',
      slots: [
        _CodeSlot(id: 's1', expectedBlockId: 'b1', helperText: 'Get hit results'),
        _CodeSlot(id: 's2', expectedBlockId: 'b2', helperText: 'Create anchor'),
        _CodeSlot(id: 's3', expectedBlockId: 'b3', helperText: 'Instantiate prefab'),
      ],
      availableBlocks: [
        _CodeBlock(id: 'b1', text: 'var hitResult = frame.hitTest(tap);'),
        _CodeBlock(id: 'b2', text: 'var anchor = hitResult.createAnchor();'),
        _CodeBlock(id: 'b3', text: 'Instantiate(prefab, anchor.pose);'),
        _CodeBlock(id: 'w1', text: 'frame.camera.getTrackingState();'), // Wrong option
        _CodeBlock(id: 'w2', text: 'Session.setWorldOrigin(pose);'), // Added wrong option
        _CodeBlock(id: 'w3', text: 'frame.lightEstimation.pixelIntensity;'), // Added wrong option
      ],
      terminalSuccess: '> Plane detected.\n> Hit test successful.\n> Anchor placed.\n> Object rendered.',
    ),
    _LevelData(
      title: 'Vuforia: Image Target',
      instructions: 'Construct the logic to handle when Vuforia recognizes a tracked image.',
      slots: [
        _CodeSlot(id: 's1', expectedBlockId: 'b1', helperText: 'Wait for tracking'),
        _CodeSlot(id: 's2', expectedBlockId: 'b2', helperText: 'Enable renderer'),
      ],
      availableBlocks: [
        _CodeBlock(id: 'w1', text: 'ARSession.run();'),
        _CodeBlock(id: 'b1', text: 'void OnTrackingFound() {'),
        _CodeBlock(id: 'b2', text: '  RenderMesh.enabled = true;'),
        _CodeBlock(id: 'w2', text: '  Destroy(gameObject);'),
        _CodeBlock(id: 'w3', text: 'TrackerManager.Instance.Deinit();'), // Added wrong option
        _CodeBlock(id: 'w4', text: 'CloudRecoBehaviour.OnInitialized();'), // Added wrong option
      ],
      terminalSuccess: '> Vuforia Engine started.\n> Marker database loaded.\n> Marker [STAR] tracked!\n> Mesh enabled.',
    )
  ];

  @override
  void initState() {
    super.initState();
    _shuffleCurrentBlocks();
  }

  void _shuffleCurrentBlocks() {
    _levels[_currentLevel].availableBlocks.shuffle();
  }

  void _addTerminalLine(String line) {
    setState(() {
      _terminalOutput.add(line);
    });
  }

  Future<void> _checkWinCondition() async {
    final level = _levels[_currentLevel];
    final allFilled = level.slots.every((slot) => slot.filledBlockId != null);
    
    if (!allFilled) return;

    final allCorrect = level.slots.every((slot) => slot.filledBlockId == slot.expectedBlockId);

    context.read<SoundService>().playTap();
    _addTerminalLine('\n> Compiling AR session...');
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    if (allCorrect) {
      context.read<SoundService>().playSuccess();
      _addTerminalLine('> Build successful.');
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      _addTerminalLine(level.terminalSuccess);
      
      setState(() {
        _score += 100;
        _levelComplete = true;
      });
    } else {
      context.read<SoundService>().playFailure();
      _addTerminalLine('> Build failed: Syntax or Logic Error.');
      _addTerminalLine('> Check block order.');
      
      setState(() {
        if (_score >= 10) _score -= 10;
      });
    }
  }

  void _nextLevel() {
    if (_currentLevel < _levels.length - 1) {
      context.read<SoundService>().playTap();
      setState(() {
        _currentLevel++;
        _levelComplete = false;
        _terminalOutput = ['\n> Loading Level ${_currentLevel + 1}...'];
        // Reset slots for the new level
        for (var slot in _levels[_currentLevel].slots) {
          slot.filledBlockId = null;
        }
        _shuffleCurrentBlocks();
      });
    } else {
      // Game Beaten
      context.read<SoundService>().playSuccess();
      context.read<ProgressService>().unlockCertificate(ProgressService.certPipelineEngineer);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardC(context.read<ThemeService>().isDarkMode),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🏆 Challenge Completed!'),
          content: Text('You successfully engineered all AR logic loops.\n\nFinal Score: $_score XP'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit game
              },
              child: const Text('Return to Space'),
            ),
          ],
        ),
      );
    }
  }

  void _resetLevel() {
    context.read<SoundService>().playTap();
    setState(() {
      for (var slot in _levels[_currentLevel].slots) {
        slot.filledBlockId = null;
      }
      _terminalOutput.add('> Workspace reset.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();
    final level = _levels[_currentLevel];

    return Theme(data: ThemeData.dark(), child: Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFF1E293B).withValues(alpha: 0.2),
              const Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, isDark, soundService),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 100), // Increased bottom safe area
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                              children: [
                                _buildInstructions(isDark, level),
                                const SizedBox(height: 16),
                                _buildMascotBubble(isDark, level),
                                const SizedBox(height: 24),
                                // Editor Zone
                                _buildEditorZone(isDark, level, soundService),
                                const SizedBox(height: 24),
                                // Blocks Zone
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!_levelComplete)
                                        Container(
                                          height: 140, // Increased height for block pool
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: SingleChildScrollView(
                                            physics: const BouncingScrollPhysics(),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              alignment: WrapAlignment.center,
                                              children: level.availableBlocks.map((block) {
                                                final isUsed = level.slots.any((s) => s.filledBlockId == block.id);
                                                if (isUsed) return const SizedBox.shrink();
                                                return Draggable<String>(
                                                  data: block.id,
                                                  feedback: Material(
                                                    color: Colors.transparent,
                                                    child: _buildCodeBlockUI(isDark, block.text, isDragging: true),
                                                  ),
                                                  childWhenDragging: Opacity(
                                                    opacity: 0.3,
                                                    child: _buildCodeBlockUI(isDark, block.text),
                                                  ),
                                                  onDragStarted: () {
                                                    if (!mounted) return;
                                                    soundService.playTap();
                                                  },
                                                  child: _buildCodeBlockUI(isDark, block.text),
                                                );
                                              }).toList(),
                                            ).animate().fadeIn(),
                                          ),
                                        ),
                                      SizedBox(
                                        height: 200, // Increased terminal height
                                        child: _buildTerminal(isDark),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_levelComplete)
              Positioned.fill(
                child: Container(
                  color: isDark ? Colors.black87 : Colors.white60,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCyan.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_outline_rounded, color: AppTheme.accentCyan, size: 80),
                        )
                        .animate()
                        .scale(duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text(
                          'AR Compilation Successful',
                          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark)),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _nextLevel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCyan,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            _currentLevel < _levels.length - 1 ? 'Next Challenge' : 'Finish Game',
                            style: AppTheme.buttonText.copyWith(color: Colors.black),
                          ),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ));
  }

  Widget _buildHeader(BuildContext context, bool isDark, SoundService soundService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              soundService.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.glassCard(isDark),
              child: Icon(
                Icons.close_rounded,
                color: AppTheme.textPrimaryC(isDark),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logic Compiler',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimaryC(isDark),
                  ),
                ),
                Text(
                  'Level ${_currentLevel + 1} / ${_levels.length}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentAmber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars_rounded, color: AppTheme.accentAmber, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$_score XP',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentAmber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isDark, _LevelData level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.title,
                  style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimaryC(isDark), fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  level.instructions,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondaryC(isDark)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _resetLevel,
            icon: Icon(Icons.refresh_rounded, color: AppTheme.textMutedC(isDark)),
            tooltip: 'Reset blocks',
          ),
        ],
      ),
    );
  }

  Widget _buildMascotBubble(bool isDark, _LevelData level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.psychology_rounded, color: AppTheme.accentCyan, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                _levelComplete ? 'Excellent! Compilation successful.' : 'Tip: ${level.instructions}',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05);
  }

  Widget _buildEditorZone(bool isDark, _LevelData level, SoundService soundService) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
              const Spacer(),
              const Text('main.cs', style: TextStyle(color: Colors.white24, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: level.slots.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final slot = level.slots[index];
              return DragTarget<String>(
                onWillAcceptWithDetails: (details) => slot.filledBlockId == null,
                onAcceptWithDetails: (details) {
                  if (!mounted) return;
                  soundService.playTap();
                  setState(() {
                    for (var s in level.slots) {
                      if (s.filledBlockId == details.data) s.filledBlockId = null;
                    }
                    slot.filledBlockId = details.data;
                  });
                  _checkWinCondition();
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovering = candidateData.isNotEmpty;
                  final isFilled = slot.filledBlockId != null;

                  if (isFilled) {
                    final blockInfo = level.availableBlocks.firstWhere((b) => b.id == slot.filledBlockId);
                    return GestureDetector(
                      onTap: () {
                        soundService.playTap();
                        setState(() { slot.filledBlockId = null; });
                      },
                      child: _buildCodeBlockUI(isDark, blockInfo.text, isSlotted: true),
                    );
                  }

                  return Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isHovering 
                          ? AppTheme.accentCyan.withValues(alpha: 0.15) 
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isHovering ? AppTheme.accentCyan : Colors.white.withValues(alpha: 0.1),
                        style: BorderStyle.solid,
                        width: isHovering ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '// ${slot.helperText}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlockUI(bool isDark, String text, {bool isDragging = false, bool isSlotted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDragging ? AppTheme.accentCyan : (isSlotted ? AppTheme.accentPurple : Colors.transparent),
          width: 2,
        ),
        boxShadow: isSlotted ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          color: AppTheme.textPrimaryC(isDark),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTerminal(bool isDark) {
    return Container(
      width: double.infinity,
      color: isDark ? Colors.black : const Color(0xFF1E293B), // Always dark for terminal
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        reverse: true,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _terminalOutput.map((line) {
            final isError = line.contains('failed') || line.contains('Error');
            final isSuccess = line.contains('successful') || line.contains('!') || line.contains('placed');
            
            Color textColor = Colors.white70;
            if (isError) textColor = Colors.redAccent;
            if (isSuccess) textColor = AppTheme.successGreen;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                line,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LevelData {
  final String title;
  final String instructions;
  final List<_CodeSlot> slots;
  final List<_CodeBlock> availableBlocks;
  final String terminalSuccess;

  _LevelData({
    required this.title,
    required this.instructions,
    required this.slots,
    required this.availableBlocks,
    required this.terminalSuccess,
  });
}

class _CodeSlot {
  final String id;
  final String expectedBlockId;
  final String helperText;
  String? filledBlockId;

  _CodeSlot({
    required this.id,
    required this.expectedBlockId,
    required this.helperText,
  });
}

class _CodeBlock {
  final String id;
  final String text;

  _CodeBlock({required this.id, required this.text});
}
