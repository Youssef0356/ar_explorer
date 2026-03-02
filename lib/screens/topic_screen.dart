import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/topic_model.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import '../widgets/content_renderer.dart';

class TopicScreen extends StatefulWidget {
  final Topic topic;
  final String moduleId;
  final Color accentColor;

  const TopicScreen({
    super.key,
    required this.topic,
    required this.moduleId,
    required this.accentColor,
  });

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  late ScrollController _scrollController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topicKey = '${widget.moduleId}_${widget.topic.id}';
    final isDark = context.watch<ThemeService>().isDarkMode;

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
                      onPressed: () => Navigator.pop(context),
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
                                ? AppTheme.successGreen.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCompleted
                                  ? AppTheme.successGreen.withValues(alpha: 0.4)
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
                    backgroundColor: widget.accentColor.withValues(alpha: 0.1),
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
                  child: ContentRenderer(blocks: widget.topic.contentBlocks)
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 500),
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
