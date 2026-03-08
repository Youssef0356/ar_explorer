import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/flashcard_data.dart';
import '../models/flashcard_model.dart';
import '../services/theme_service.dart';

class FlashcardScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  final Color accentColor;

  const FlashcardScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.accentColor,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  late List<Flashcard> _cards;
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _cards = (allFlashcards[widget.moduleId] ?? []).toList()..shuffle(Random());
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse().then((_) {
        setState(() => _showBack = false);
      });
    } else {
      _flipController.forward().then((_) {
        setState(() => _showBack = true);
      });
    }
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
      _flipController.reset();
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
      });
      _flipController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;

    if (_cards.isEmpty) {
      return Scaffold(
        body: Container(
          decoration:
              BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No flashcards available for this module',
                    style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMutedC(isDark))),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: AppTheme.textPrimaryC(isDark)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.moduleTitle} Flashcards',
                        style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textPrimaryC(isDark)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${_cards.length}',
                      style: AppTheme.bodyMedium.copyWith(
                          color: widget.accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _cards.length,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.12),
                    valueColor:
                        AlwaysStoppedAnimation(widget.accentColor),
                    minHeight: 4,
                  ),
                ),

                // ── Card ──
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: _flipCard,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -200) {
                            _nextCard();
                          } else if (details.primaryVelocity! > 200) {
                            _prevCard();
                          }
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * pi;
                          final showBack = angle > pi / 2;
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            child: showBack
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..rotateY(pi),
                                    child: _buildCardContent(
                                        card.back, 'ANSWER', isDark, true),
                                  )
                                : _buildCardContent(
                                    card.front, 'QUESTION', isDark, false),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── Controls ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          _currentIndex > 0 ? _prevCard : null,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: _currentIndex > 0
                            ? AppTheme.textPrimaryC(isDark)
                            : AppTheme.textMutedC(isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _flipCard,
                      icon: Icon(
                        _showBack ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(_showBack ? 'Hide' : 'Reveal'),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _currentIndex < _cards.length - 1
                          ? _nextCard
                          : null,
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        color: _currentIndex < _cards.length - 1
                            ? AppTheme.textPrimaryC(isDark)
                            : AppTheme.textMutedC(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Tap to flip • Swipe to navigate',
                    style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMutedC(isDark)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(
      String text, String label, bool isDark, bool isBack) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBack
              ? widget.accentColor.withValues(alpha: 0.3)
              : AppTheme.dividerC(isDark),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isBack
                ? widget.accentColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isBack
                  ? widget.accentColor.withValues(alpha: 0.15)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isBack
                    ? widget.accentColor
                    : AppTheme.textMutedC(isDark),
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textPrimaryC(isDark),
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300));
  }
}
