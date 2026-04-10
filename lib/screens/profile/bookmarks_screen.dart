import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import 'topic_screen.dart';
import '../widgets/animated_google_background.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<ProgressService>();
    final bookmarkedKeys = progress.bookmarks.toList()..sort();

    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: isDark,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              title: Text(
                'Bookmarks & Notes',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.textPrimaryC(isDark),
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimaryC(isDark)),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // ── General Notes Section ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'MY GENERAL NOTES',
                          style: AppTheme.labelMedium.copyWith(
                            letterSpacing: 1.5,
                            color: AppTheme.textMutedC(isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final generalNote = progress.getNote('general_notes');
                        final color = AppTheme.accentCyan;
                        
                        if (generalNote.isEmpty) {
                          return GestureDetector(
                            onTap: () => _showEditNoteDialog(
                                context, isDark, progress, 'general_notes', generalNote, color),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3),
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add_comment_rounded,
                                      size: 18, color: color),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Add a general note...',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => _showEditNoteDialog(
                                context, isDark, progress, 'general_notes', generalNote, color),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardC(isDark),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: color.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.edit_note_rounded,
                                      size: 20,
                                      color: color),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      generalNote,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textPrimaryC(
                                            isDark),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 16,
                                      color:
                                          AppTheme.textMutedC(isDark)),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            if (bookmarkedKeys.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: Row(
                    children: [
                      const Text('🔖', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        'SAVED TOPICS',
                        style: AppTheme.labelMedium.copyWith(
                          letterSpacing: 1.5,
                          color: AppTheme.textMutedC(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (bookmarkedKeys.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline_rounded,
                          size: 64, color: AppTheme.textMutedC(isDark)),
                      const SizedBox(height: 16),
                      Text(
                        'No bookmarks yet',
                        style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textMutedC(isDark)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the bookmark icon on any topic\nto save it here',
                        style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textMutedC(isDark)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final key = bookmarkedKeys[index];
                      final result = _findTopic(key);
                      if (result == null) return const SizedBox.shrink();

                      final module = result['module'];
                      final topic = result['topic'];
                      final note = progress.getNote(key);
                      final color = AppTheme.getModuleColor(
                          allModules.indexOf(module));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            final moduleIndex = allModules.indexOf(module);
                            final color = AppTheme.getModuleColor(moduleIndex);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TopicScreen(
                                  topic: topic,
                                  moduleId: module.id,
                                  accentColor: color,
                                  fromBookmark: true,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardC(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: color.withValues(alpha: isDark ? 0.2 : 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.bookmark_rounded,
                                        color: color, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            topic.title,
                                            style: AppTheme.headingSmall
                                                .copyWith(
                                              fontSize: 15,
                                              color: AppTheme.textPrimaryC(
                                                  isDark),
                                            ),
                                          ),
                                          Text(
                                            module.title,
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textMutedC(
                                                  isDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                          Icons.bookmark_remove_rounded,
                                          color: AppTheme.textMutedC(isDark),
                                          size: 20),
                                      onPressed: () =>
                                          progress.toggleBookmark(key),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Note section — always visible, no premium gate
                                if (note.isEmpty)
                                  GestureDetector(
                                    onTap: () => _showEditNoteDialog(
                                        context, isDark, progress, key, note, color),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: color.withValues(alpha: 0.2),
                                            style: BorderStyle.solid),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.add_comment_rounded,
                                              size: 16, color: color),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Add a note…',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: color.withValues(alpha: 0.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () => _showEditNoteDialog(
                                        context, isDark, progress, key, note, color),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.03)
                                            : Colors.grey.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: color.withValues(alpha: 0.15)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.edit_note_rounded,
                                              size: 16,
                                              color: AppTheme.textMutedC(isDark)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              note,
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.textSecondaryC(
                                                    isDark),
                                              ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(Icons.chevron_right_rounded,
                                              size: 14,
                                              color:
                                                  AppTheme.textMutedC(isDark)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(milliseconds: 80 * index),
                              duration: const Duration(milliseconds: 400),
                            ).slideX(
                              begin: 0.1,
                              end: 0,
                              delay: Duration(milliseconds: 80 * index),
                              curve: Curves.easeOutCubic,
                            ),
                      );
                    },
                    childCount: bookmarkedKeys.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _findTopic(String key) {
    for (final module in allModules) {
      for (final topic in module.topics) {
        final topicKey = '${module.id}_${topic.id}';
        if (topicKey == key) {
          return {'module': module, 'topic': topic};
        }
      }
    }
    return null;
  }

  // FIX: isDark is passed in from the outer widget context,
  // not read inside the dialog builder where the context is different.
  void _showEditNoteDialog(
    BuildContext context,
    bool isDark,
    ProgressService progress,
    String key,
    String currentNote,
    Color accentColor,
  ) {
    final controller = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardC(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit_note_rounded, color: accentColor, size: 22),
            const SizedBox(width: 10),
            Text(
              currentNote.isEmpty ? 'Add Note' : 'Edit Note',
              style: AppTheme.headingSmall
                  .copyWith(color: AppTheme.textPrimaryC(isDark)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              autofocus: true,
              style: AppTheme.bodyMedium
                  .copyWith(color: AppTheme.textPrimaryC(isDark)),
              decoration: InputDecoration(
                hintText: 'Write your thoughts, key takeaways…',
                hintStyle: AppTheme.bodyMedium
                    .copyWith(color: AppTheme.textMutedC(isDark)),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.dividerC(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppTheme.dividerC(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
            ),
            if (currentNote.isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  progress.saveNote(key, '');
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Delete note',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.errorRed.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.textMutedC(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              // Only save if there's actual content, or delete if cleared
              progress.saveNote(key, text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
