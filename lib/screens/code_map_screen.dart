import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../data/code_challenges_data.dart';
import '../models/game_models.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import 'code_game_screen.dart';
import 'league_home_screen.dart';

class CodeMapScreen extends StatelessWidget {
  const CodeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    final sound = context.read<SoundService>();

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, progress, sound),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: codeGameZones.length,
                itemBuilder: (ctx, i) =>
                    _buildZoneCard(context, codeGameZones[i], progress, sound, i),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, GameProgressService progress, SoundService sound) {
    // Count completed code challenges
    int completed = 0, total = 0;
    for (final z in codeGameZones) {
      for (final c in z.challenges) {
        total++;
        if (progress.isLevelCompleted(c.id)) completed++;
      }
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              12, MediaQuery.of(context).padding.top + 8, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF060B14).withOpacity(0.85),
            border: Border(
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.06))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('CODE CHALLENGES',
                        style: TextStyle(
                            color: Color(0xFF00E5FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5)),
                    const Text('Choose a Level',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              // Progress
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$completed / $total',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
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
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.amber, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Zone card ───────────────────────────────────────────────────────────────
  Widget _buildZoneCard(BuildContext context, CodeZone zone,
      GameProgressService progress, SoundService sound, int index) {
    final completedInZone =
        zone.challenges.where((c) => progress.isLevelCompleted(c.id)).length;
    final totalInZone = zone.challenges.length;
    final allDone = completedInZone == totalInZone;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: allDone
              ? zone.accentColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          // Zone header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: zone.accentColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: zone.accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(zone.icon, color: zone.accentColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(zone.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      Text(zone.platform,
                          style: TextStyle(
                              color: zone.accentColor.withOpacity(0.7),
                              fontSize: 12)),
                    ],
                  ),
                ),
                // Zone progress
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: zone.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$completedInZone / $totalInZone',
                      style: TextStyle(
                          color: zone.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          // Level list
          ...zone.challenges.asMap().entries.map((entry) {
            final idx = entry.key;
            final challenge = entry.value;
            final isCompleted = progress.isLevelCompleted(challenge.id);
            final stars = progress.getStars(challenge.id);
            final isLocked = _isChallengeLocked(zone, idx, progress);

            return GestureDetector(
              onTap: () {
                if (isLocked) return;
                sound.playTap();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CodeGameScreen(
                      challenge: challenge,
                      zoneColor: zone.accentColor,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: Colors.white.withOpacity(0.04)),
                  ),
                ),
                child: Row(
                  children: [
                    // Level icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLocked
                            ? Colors.white.withOpacity(0.04)
                            : isCompleted
                                ? zone.accentColor.withOpacity(0.15)
                                : Colors.white.withOpacity(0.06),
                        border: Border.all(
                          color: isLocked
                              ? Colors.white.withOpacity(0.08)
                              : isCompleted
                                  ? zone.accentColor.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Center(
                        child: isLocked
                            ? Icon(Icons.lock_rounded,
                                color: Colors.white.withOpacity(0.2),
                                size: 14)
                            : isCompleted
                                ? Icon(Icons.check_rounded,
                                    color: zone.accentColor, size: 18)
                                : challenge.isBoss
                                    ? Icon(
                                        Icons.local_fire_department_rounded,
                                        color: Colors.orange
                                            .withOpacity(0.7),
                                        size: 16)
                                    : Text('${idx + 1}',
                                        style: TextStyle(
                                            color: Colors.white
                                                .withOpacity(0.6),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: TextStyle(
                              color: isLocked
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (challenge.subtitle.isNotEmpty)
                            Text(
                              challenge.subtitle,
                              style: TextStyle(
                                color: isLocked
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.4),
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Stars
                    if (isCompleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          return Icon(
                            i < stars
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < stars
                                ? Colors.amber
                                : Colors.white.withOpacity(0.15),
                            size: 16,
                          );
                        }),
                      ),
                    if (!isCompleted && !isLocked)
                      Icon(Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.3), size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 + index * 100)).fadeIn().slideY(begin: 0.05);
  }

  // ── Lock logic ──────────────────────────────────────────────────────────────
  bool _isChallengeLocked(
      CodeZone zone, int challengeIndex, GameProgressService progress) {
    final challenge = zone.challenges[challengeIndex];

    // Free levels are never locked
    if (challenge.isFree) return false;

    // First level in zone: check if prev zone boss is complete
    if (challengeIndex == 0) {
      final zoneIdx = codeGameZones.indexOf(zone);
      if (zoneIdx == 0) return false; // first zone first level always open
      final prevZone = codeGameZones[zoneIdx - 1];
      return !progress.isLevelCompleted(prevZone.challenges.last.id);
    }

    // Otherwise: previous challenge must be completed
    final prevChallenge = zone.challenges[challengeIndex - 1];
    return !progress.isLevelCompleted(prevChallenge.id);
  }
}
