import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../data/coding_game_data.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import 'coding_challenge_screen.dart';
import 'league_home_screen.dart';

class CodingGameMapScreen extends StatelessWidget {
  const CodingGameMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    final progress = context.watch<GameProgressService>();
    final sound = context.read<SoundService>();

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, sound, progress),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                itemCount: codingGameZones.length,
                itemBuilder: (context, index) {
                  final zone = codingGameZones[index];
                  // Levels 3, 4, 5 (all zones after the first simple one) could be premium?
                  // Using user's spec: "Zone 1 free, rest premium" typically.
                  final isLocked = !isPremium && index > 0;

                  return _buildZoneCard(context, zone, isLocked, sound, progress);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SoundService sound, GameProgressService progress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AR PLATFORMS', style: TextStyle(color: AppTheme.accentCyan, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                Text('Select a Zone', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ],
            ),
          ),
          if (progress.codingStreak > 0)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.codingStreak} DAY STREAK',
                    style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          // League Button
          GestureDetector(
            onTap: () {
              sound.playTap();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeagueHomeScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Colors.amber, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, dynamic zone, bool isLocked, SoundService sound, GameProgressService progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              sound.playTap();
              if (isLocked) {
                // Show paywall or simple message
                _showLockedMessage(context);
              } else {
                // Navigate to first level of zone (expanding to a level list or auto-start)
                // For this MVP, we start the first level of the zone
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CodingChallengeScreen(
                      level: zone.levels.first,
                      accentColor: zone.accentColor,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF131927),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: zone.accentColor.withValues(alpha: isLocked ? 0.05 : 0.2), width: 1),
                boxShadow: [
                  BoxShadow(color: zone.accentColor.withValues(alpha: isLocked ? 0.0 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: zone.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(zone.icon, color: zone.accentColor, size: 30),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: TextStyle(
                            color: isLocked ? Colors.white38 : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          zone.platform,
                          style: TextStyle(
                            color: zone.accentColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProgressDots(
                          zone.levels.length, 
                          zone.levels.where((l) => progress.isCodingLevelCompleted(l.id)).length
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock_rounded, color: Colors.amber, size: 24)
                  else
                    Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildProgressDots(int total, int completed) {
    return Row(
      children: List.generate(total, (i) {
        final isLast = i == total - 1;
        return Container(
          width: isLast ? 24 : 12,
          height: 8,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: i < completed ? AppTheme.accentCyan : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: isLast ? Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.5)) : null,
          ),
          child: isLast ? const Center(child: Icon(Icons.bolt, color: AppTheme.accentAmber, size: 6)) : null,
        );
      }),
    );
  }

  void _showLockedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This zone requires a Premium subscription.'),
        backgroundColor: Colors.amber[900],
      ),
    );
  }
}
