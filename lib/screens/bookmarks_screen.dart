import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/modules_data.dart';
import '../services/progress_service.dart';
import '../services/theme_service.dart';
import 'topic_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.watch<ProgressService>();
    final bookmarkedKeys = progress.bookmarks.toList()..sort();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient(isDark)),
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
                      // key format: moduleId_topicId
                      // Find the module and topic
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
                                color: color.withValues(
                                    alpha: isDark ? 0.2 : 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                              color:
                                                  AppTheme.textPrimaryC(
                                                      isDark),
                                            ),
                                          ),
                                          Text(
                                            module.title,
                                            style:
                                                AppTheme.bodySmall.copyWith(
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
                                          color:
                                              AppTheme.textMutedC(isDark),
                                          size: 20),
                                      onPressed: () =>
                                          progress.toggleBookmark(key),
                                    ),
                                  ],
                                ),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.03)
                                          : Colors.grey
                                              .withValues(alpha: 0.06),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '📝 $note',
                                      style:
                                          AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondaryC(
                                            isDark),
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                              delay: Duration(
                                  milliseconds: 80 * index),
                              duration:
                                  const Duration(milliseconds: 400),
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
}
