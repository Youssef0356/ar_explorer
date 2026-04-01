import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/coding_game_data.dart';
import '../services/game_progress_service.dart';
import '../models/coding_game_models.dart';
import '../widgets/animated_google_background.dart';
import 'coding_challenge_screen.dart';

class CodingGameMapScreen extends StatefulWidget {
  const CodingGameMapScreen({super.key});
  @override
  State<CodingGameMapScreen> createState() => _CodingGameMapScreenState();
}

class _CodingGameMapScreenState extends State<CodingGameMapScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    return Theme(
      data: ThemeData.dark(),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedGoogleBackground(
            isDark: true,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(progress),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPlatformZone(codingGameZones[0], progress), // Vuforia
                        _buildPlatformZone(codingGameZones[1], progress), // ARKit
                        _buildPlatformZone(codingGameZones[2], progress), // ARCore
                        _buildPlatformZone(codingGameZones[3], progress), // Meta Quest
                        _buildPlatformZone(codingGameZones[4], progress), // WebXR
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppTheme.accentPurple.withValues(alpha: 0.15),
          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
        ),
        labelColor: AppTheme.accentPurple,
        unselectedLabelColor: Colors.white24,
        tabs: [
          _buildPlatformTab(Icons.light_mode_rounded, 'VUFORIA'),
          _buildPlatformTab(Icons.apple_rounded, 'ARKIT'),
          _buildPlatformTab(Icons.android_rounded, 'ARCORE'),
          _buildPlatformTab(Icons.settings_input_hdmi_rounded, 'QUEST'),
          _buildPlatformTab(Icons.language_rounded, 'WEBXR'),
        ],
      ),
    );
  }

  Widget _buildPlatformTab(IconData icon, String text) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformZone(CodingZone zone, GameProgressService progress) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: zone.levels.length,
      itemBuilder: (ctx, i) {
        final level = zone.levels[i];
        final isLocked = progress.isLevelLocked(level.id, isFree: level.isFree);
        final stars = progress.getStars(level.id);

        return _PlatformLevelCard(
          level: level,
          zone: zone,
          isLocked: isLocked,
          stars: stars,
          index: i + 1,
          onTap: isLocked
              ? () => _showUnlockLevelDialog(context, level, progress)
              : () => _showLevelSheet(level, zone),
        );
      },
    );
  }

  void _showUnlockLevelDialog(BuildContext context, CodingLevel level, GameProgressService progress) {
    const int cost = 20;
    final canAfford = progress.unifiedXP >= cost;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D0D12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Unlock Level', style: TextStyle(color: Colors.white)),
        content: Text('Unlock "${level.title}" for $cost XP?\nYour Balance: ${progress.unifiedXP} XP', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: canAfford ? () async {
              await progress.unlockLevel(level.id, cost);
              if (context.mounted) Navigator.pop(ctx);
            } : null,
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(GameProgressService progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SYSTEMS ENGINEER', style: TextStyle(color: AppTheme.accentPurple, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
                Text('Module Hub', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${progress.unifiedXP} XP', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showLevelSheet(CodingLevel level, CodingZone zone) {
    final progress = context.read<GameProgressService>();
    final stars = progress.getStars(level.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(level.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(level.goal, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CodingChallengeScreen(level: level, accentColor: zone.accentColor)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: zone.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(stars > 0 ? 'REPLAY' : 'START'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformLevelCard extends StatelessWidget {
  final CodingLevel level;
  final CodingZone zone;
  final bool isLocked;
  final int stars;
  final int index;
  final VoidCallback onTap;

  const _PlatformLevelCard({
    required this.level,
    required this.zone,
    required this.isLocked,
    required this.stars,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLocked ? Colors.white24 : zone.accentColor;
    final numberStr = index.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? Colors.white10 : color.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Code style index
            Text(
              '[$numberStr]',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      color: isLocked ? Colors.white38 : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.goal,
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock_rounded, color: Colors.white24, size: 18)
            else
              Row(
                children: List.generate(
                  3,
                  (i) => Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < stars ? Colors.amber : Colors.white10,
                      border: Border.all(
                        color: i < stars ? Colors.amberAccent : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 24),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }
}
