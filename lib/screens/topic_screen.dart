import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/topic_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../widgets/content_renderer.dart';
import 'paywall_screen.dart';

class TopicScreen extends StatefulWidget {
  final Topic topic;
  final String moduleId;
  final Color accentColor;

  final bool fromBookmark;
  
  const TopicScreen({
    super.key,
    required this.topic,
    required this.moduleId,
    required this.accentColor,
    this.fromBookmark = false,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  late ScrollController _scrollController;
  double _progress = 0.0;
  late TextEditingController _noteController;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    final topicKey = '${widget.moduleId}_${widget.topic.id}';
    final existingNote = context.read<ProgressService>().getNote(topicKey);
    _noteController = TextEditingController(text: existingNote);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    if (maxScroll <= 0) return;

    setState(() {
      _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicKey = '${widget.moduleId}_${widget.topic.id}';
    final isDark = context.watch<ThemeService>().isDarkMode;
    final soundService = context.read<SoundService>();
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(isDark),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: AppTheme.textPrimaryC(isDark),
                      onPressed: () {
                        soundService.playTap();
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.topic.title,
                            style: AppTheme.headingSmall.copyWith(
                              color: AppTheme.textPrimaryC(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.topic.subtitle,
                            style: AppTheme.bodySmall.copyWith(
                              color: widget.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bookmark button
                    Consumer<ProgressService>(
                      builder: (context, progress, child) {
                        final isBookmarked =
                            progress.isBookmarked(topicKey);
                        return IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: isBookmarked
                                ? widget.accentColor
                                : AppTheme.textMutedC(isDark),
                          ),
                          onPressed: () {
                            soundService.playTap(); // Added sound trigger
                            progress.toggleBookmark(topicKey);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isBookmarked
                                      ? 'Bookmark removed'
                                      : 'Bookmarked!',
                                ),
                                backgroundColor: AppTheme.cardC(isDark),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<ProgressService>(
                      builder: (context, progress, child) {
                        final isCompleted = progress.isTopicCompleted(topicKey);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.successGreen.withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCompleted
                                  ? AppTheme.successGreen.withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCompleted) ...[
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppTheme.successGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '✅ Done',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: const Duration(milliseconds: 300)),

              // ── Progress Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: widget.accentColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.accentColor,
                    ),
                    minHeight: 2,
                  ),
                ),
              ),

              // ── Content ──
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContentRenderer(blocks: widget.topic.contentBlocks)
                          .animate()
                          .fadeIn(
                            delay: const Duration(milliseconds: 200),
                            duration: const Duration(milliseconds: 500),
                          ),
                      const SizedBox(height: 20),
                      // ── Notes Section ──
                      GestureDetector(
                        onTap: () {
                          if (!isPremium) {
                            soundService.playTap();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaywallScreen(
                                  moduleName: 'Personal Notes & PDF Export',
                                ),
                              ),
                            );
                            return;
                          }
                          setState(() => _showNotes = !_showNotes);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.04)
                                : Colors.grey.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isPremium 
                                    ? AppTheme.dividerC(isDark)
                                    : AppTheme.accentAmber.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPremium ? Icons.edit_note_rounded : Icons.lock_outline_rounded,
                                color: isPremium 
                                    ? AppTheme.textMutedC(isDark)
                                    : AppTheme.accentAmber,
                                size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isPremium ? 'Personal Notes' : 'Personal Notes (Premium)',
                                style: AppTheme.labelMedium.copyWith(
                                    color: isPremium 
                                        ? AppTheme.textMutedC(isDark)
                                        : AppTheme.accentAmber),
                              ),
                              const Spacer(),
                              if (isPremium)
                                Icon(
                                  _showNotes
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AppTheme.textMutedC(isDark),
                                  size: 20,
                                )
                              else
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: AppTheme.accentAmber,
                                  size: 14,
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_showNotes) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _noteController,
                          maxLines: 5,
                          minLines: 2,
                          style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textPrimaryC(isDark)),
                          decoration: InputDecoration(
                            hintText: 'Write your notes here...',
                            hintStyle: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textMutedC(isDark)),
                            filled: true,
                            fillColor: AppTheme.cardC(isDark),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.dividerC(isDark)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.dividerC(isDark)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: widget.accentColor),
                            ),
                          ),
                          onChanged: (value) {
                            context
                                .read<ProgressService>()
                                .saveNote(topicKey, value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Mark Complete FAB ──
      floatingActionButton: Consumer<ProgressService>(
        builder: (context, progress, child) {
          final isCompleted = progress.isTopicCompleted(topicKey);
          if (!isCompleted) {
            return AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  soundService.playTap();
                  await progress.completeTopic(topicKey);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Text(
                              '\ud83c\udf89',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Topic completed! +50 XP',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textPrimaryC(isDark),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.cardC(isDark),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                backgroundColor: widget.accentColor,
                foregroundColor: AppTheme.primaryDark,
                icon: const Icon(Icons.check_rounded, size: 20),
                label: Text('Mark Complete \u2728', style: AppTheme.buttonText),
              ),
            );
          }

          // After completion, show a "Next topic" button that asks the
          // previous screen to move forward.
          // Only show this if NOT opened from bookmarks.
          if (widget.fromBookmark) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.pop<bool>(context, true);
            },
            backgroundColor: widget.accentColor,
            foregroundColor: AppTheme.primaryDark,
            icon: const Icon(Icons.arrow_forward_rounded, size: 20),
            label: Text('Next topic', style: AppTheme.buttonText),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
