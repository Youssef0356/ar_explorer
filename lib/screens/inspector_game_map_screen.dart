import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../data/inspector_game_data.dart';
import '../models/inspector_game_models.dart';
import '../services/game_progress_service.dart';
import '../services/theme_service.dart';
import '../services/sound_service.dart';
import 'inspector_game_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  InspectorGameMapScreen
//  Shown when the user taps "XR Builder" from the main nav.
//  Displays a zone list → expandable level grid.
// ═══════════════════════════════════════════════════════════════════════════

class InspectorGameMapScreen extends StatelessWidget {
  const InspectorGameMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark    = context.watch<ThemeService>().isDarkMode;
    final progress  = context.watch<GameProgressService>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldC(isDark),
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            backgroundColor: AppTheme.scaffoldC(isDark),
            expandedHeight: 110,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('XR BUILDER',
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.accentCyan,
                      fontSize: 16, letterSpacing: 1.5)),
                  Text('Build real XR apps in the Inspector',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textMutedC(isDark), fontSize: 10)),
                ],
              ),
            ),
          ),

          // ── Stats strip ──
          SliverToBoxAdapter(
            child: _StatsStrip(progress: progress, isDark: isDark),
          ),

          // ── Zone cards ──
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ZoneCard(
                zone: inspectorGameZones[i],
                progress: progress,
                isDark: isDark,
              ),
              childCount: inspectorGameZones.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Stats strip ────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final GameProgressService progress;
  final bool isDark;
  const _StatsStrip({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final total     = allInspectorLevels.length;
    final completed = allInspectorLevels
        .where((l) => progress.isLevelCompleted(l.id))
        .length;
    final pct = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardC(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$completed / $total levels complete',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textMutedC(isDark))),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: AppTheme.dividerC(isDark),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accentCyan),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${progress.totalXP} XP',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.accentAmber, fontSize: 18)),
              Text(progress.currentLeague,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textMutedC(isDark))),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Zone card ──────────────────────────────────────────────────────────────
class _ZoneCard extends StatefulWidget {
  final InspectorZone zone;
  final GameProgressService progress;
  final bool isDark;
  const _ZoneCard({
    required this.zone,
    required this.progress,
    required this.isDark,
  });

  @override
  State<_ZoneCard> createState() => _ZoneCardState();
}

class _ZoneCardState extends State<_ZoneCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final zone      = widget.zone;
    final levels    = zone.levels;
    final doneCount = levels
        .where((l) => widget.progress.isLevelCompleted(l.id))
        .length;
    final allDone   = doneCount == levels.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardC(widget.isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allDone
              ? zone.accentColor.withValues(alpha: .4)
              : AppTheme.dividerC(widget.isDark)),
      ),
      child: Column(
        children: [
          // Zone header — tap to expand
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: zone.accentColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(zone.icon,
                        color: zone.accentColor, size: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(zone.name,
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textPrimaryC(widget.isDark),
                            fontSize: 13)),
                        Text(zone.subtitle,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textMutedC(widget.isDark))),
                      ],
                    ),
                  ),
                  // Progress badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: zone.accentColor.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: zone.accentColor.withValues(alpha: .2)),
                    ),
                    child: Text('$doneCount/${levels.length}',
                      style: TextStyle(
                        color: zone.accentColor,
                        fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? .5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: AppTheme.textMutedC(widget.isDark)),
                  ),
                ],
              ),
            ),
          ),
          // Level grid
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.4,
                ),
                itemCount: levels.length,
                itemBuilder: (ctx, i) => _LevelTile(
                  level: levels[i],
                  zone: zone,
                  progress: widget.progress,
                  isDark: widget.isDark,
                  // A level is locked if the previous one isn't done
                  // (first level of each zone is always unlocked)
                  isLocked: i > 0 &&
                      !widget.progress.isLevelCompleted(levels[i - 1].id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Level tile ─────────────────────────────────────────────────────────────
class _LevelTile extends StatelessWidget {
  final InspectorLevel level;
  final InspectorZone zone;
  final GameProgressService progress;
  final bool isDark;
  final bool isLocked;
  const _LevelTile({
    required this.level,
    required this.zone,
    required this.progress,
    required this.isDark,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final stars     = progress.getStars(level.id);
    final completed = progress.isLevelCompleted(level.id);

    final bgColor = isLocked
        ? AppTheme.dividerC(isDark)
        : (completed
            ? zone.accentColor.withValues(alpha: .12)
            : zone.accentColor.withValues(alpha: .06));

    final borderColor = isLocked
        ? Colors.transparent
        : (completed
            ? zone.accentColor.withValues(alpha: .35)
            : zone.accentColor.withValues(alpha: .15));

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              context.read<SoundService>().playTap();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InspectorGameScreen(level: level),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Lock / boss icon
            Text(
              isLocked ? '🔒' : (level.isBoss ? '💀' : level.gameObjectIcon),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(level.title,
                    style: TextStyle(
                      color: isLocked
                          ? AppTheme.textMutedC(isDark)
                          : AppTheme.textPrimaryC(isDark),
                      fontSize: 10, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                  if (completed)
                    Row(
                      children: List.generate(3, (i) => Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < stars
                            ? Colors.amber
                            : AppTheme.textMutedC(isDark),
                        size: 10,
                      )),
                    )
                  else if (!isLocked)
                    Text(
                      level.isBoss ? 'BOSS' : 'Tap to play',
                      style: TextStyle(
                        color: level.isBoss
                            ? AppTheme.errorRed
                            : AppTheme.textMutedC(isDark),
                        fontSize: 9,
                        fontWeight: level.isBoss ? FontWeight.w800 : FontWeight.w400),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
