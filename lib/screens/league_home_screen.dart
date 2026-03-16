import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/game_progress_service.dart';
import '../services/sound_service.dart';
import 'code_map_screen.dart';
import 'game_map_screen.dart';

// ── Fake leaderboard data ─────────────────────────────────────────────────────
class _LeaderboardEntry {
  final String name;
  final String tag;
  final int xp;
  final bool isPlayer;

  const _LeaderboardEntry({
    required this.name,
    required this.tag,
    required this.xp,
    this.isPlayer = false,
  });
}

class LeagueHomeScreen extends StatefulWidget {
  const LeagueHomeScreen({super.key});

  @override
  State<LeagueHomeScreen> createState() => _LeagueHomeScreenState();
}

class _LeagueHomeScreenState extends State<LeagueHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Update streak on screen entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProgressService>().updateStreak();
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GameProgressService>();
    final soundService = context.read<SoundService>();
    final playerXP = progress.totalXP;
    final league = progress.currentLeague;
    final streak = progress.dailyStreak;

    // Build dynamic leaderboard with player included
    final entries = _buildLeaderboard(playerXP, league);

    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, soundService, league, playerXP, streak),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildLeagueBadge(league),
                    const SizedBox(height: 24),
                    _buildLeaderboardCard(entries, league),
                    const SizedBox(height: 24),
                    _buildGameModeCards(context, soundService),
                    const SizedBox(height: 16),
                    _buildStreakCard(streak),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, SoundService sound,
      String league, int xp, int streak) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              sound.playTap();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white70, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AR SYSTEMS ENGINEER',
                    style: TextStyle(
                        color: _leagueColor(league),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.5)),
                const Text('League',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text('$xp XP',
                    style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── League badge ────────────────────────────────────────────────────────────
  Widget _buildLeagueBadge(String league) {
    final color = _leagueColor(league);
    final icon = _leagueIcon(league);

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.05)],
            ),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 3),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 30),
            ],
          ),
          child: Icon(icon, color: color, size: 48),
        )
            .animate()
            .scale(curve: Curves.elasticOut, duration: 800.ms)
            .fadeIn(),
        const SizedBox(height: 12),
        Text('$league League',
            style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 6),
        // Timer pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_rounded,
                  color: Colors.white.withValues(alpha: 0.5), size: 14),
              const SizedBox(width: 6),
              Text('2 DAYS',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Leaderboard card ────────────────────────────────────────────────────────
  Widget _buildLeaderboardCard(List<_LeaderboardEntry> entries, String league) {
    final color = _leagueColor(league);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.leaderboard_rounded,
                    color: color, size: 18),
                const SizedBox(width: 10),
                Text('LEADERBOARD',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2)),
                const Spacer(),
                Icon(_leagueIcon(league),
                    color: color.withValues(alpha: 0.6), size: 16),
              ],
            ),
          ),
          // Entries
          ...entries.asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            final rank = idx + 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: e.isPlayer
                    ? color.withValues(alpha: 0.08)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.04)),
                ),
              ),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: rank <= 3
                            ? Colors.amber
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  // Avatar
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: e.isPlayer
                          ? color.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: e.isPlayer
                            ? color.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        e.name[0],
                        style: TextStyle(
                          color: e.isPlayer ? color : Colors.white70,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + tag
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(e.name,
                                style: TextStyle(
                                    color: e.isPlayer
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14,
                                    fontWeight: e.isPlayer
                                        ? FontWeight.w800
                                        : FontWeight.w600)),
                            if (e.isPlayer) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('YOU',
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ],
                        ),
                        if (e.tag.isNotEmpty)
                          Text(e.tag,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 11)),
                      ],
                    ),
                  ),
                  // XP
                  Text('${e.xp} XP',
                      style: TextStyle(
                          color: e.isPlayer
                              ? color
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: 100 + idx * 80))
                .fadeIn()
                .slideX(begin: 0.05);
          }),
        ],
      ),
    );
  }

  // ── Streak card ─────────────────────────────────────────────────────────────
  Widget _buildStreakCard(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: streak > 0
              ? Colors.orange.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              streak > 0 ? Icons.local_fire_department_rounded : Icons.whatshot_outlined,
              color: streak > 0 ? Colors.orange : Colors.white24,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak > 0 ? '$streak Day Streak!' : 'Start a Streak',
                  style: TextStyle(
                    color: streak > 0 ? Colors.orange : Colors.white54,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  streak > 0
                      ? 'All XP earned today gets a 1.5× multiplier!'
                      : 'Play daily to earn bonus XP.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('1.5×',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildGameModeCards(BuildContext context, SoundService sound) {
    return Column(
      children: [
        _buildModeCard(
          context: context,
          sound: sound,
          title: 'Code Challenges',
          subtitle: 'Fill in the blanks in real AR scripts',
          icon: Icons.code_rounded,
          color: const Color(0xFF00E5FF),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CodeMapScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          context: context,
          sound: sound,
          title: 'Pipeline Challenge',
          subtitle: 'Repackaged mini-game logic',
          icon: Icons.account_tree_rounded,
          color: Colors.purpleAccent,
          isMini: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GameMapScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required SoundService sound,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isMini = false,
  }) {
    return GestureDetector(
      onTap: () {
        sound.playTap();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      if (isMini) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('MINI',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05);
  }

  // ── Leaderboard builder ─────────────────────────────────────────────────────
  List<_LeaderboardEntry> _buildLeaderboard(int playerXP, String league) {
    // Fixed fake players that scale with league context
    final fakeEntries = [
      _LeaderboardEntry(name: 'Nova', tag: 'XR Architect', xp: _scaleXP(480, league)),
      _LeaderboardEntry(name: 'Kai', tag: 'AR Developer', xp: _scaleXP(390, league)),
      _LeaderboardEntry(name: 'Zara', tag: 'Unity Dev', xp: _scaleXP(310, league)),
      _LeaderboardEntry(name: 'Atlas', tag: 'WebXR Engineer', xp: _scaleXP(250, league)),
      _LeaderboardEntry(name: 'Pixel', tag: 'AR Beginner', xp: _scaleXP(120, league)),
    ];

    final player = _LeaderboardEntry(
      name: 'You',
      tag: _playerTag(playerXP),
      xp: playerXP,
      isPlayer: true,
    );

    final all = [...fakeEntries, player];
    all.sort((a, b) => b.xp.compareTo(a.xp));

    // Keep top 6
    return all.take(6).toList();
  }

  int _scaleXP(int base, String league) {
    switch (league) {
      case 'Diamond':
        return base + 1200 + Random(42).nextInt(300);
      case 'Gold':
        return base + 600 + Random(42).nextInt(200);
      case 'Silver':
        return base + 150 + Random(42).nextInt(100);
      default:
        return base;
    }
  }

  String _playerTag(int xp) {
    if (xp >= 1500) return 'Master Engineer';
    if (xp >= 800) return 'Senior Dev';
    if (xp >= 300) return 'AR Developer';
    if (xp >= 50) return 'AR Learner';
    return 'Newcomer';
  }

  // ── League helpers ──────────────────────────────────────────────────────────
  static Color _leagueColor(String league) {
    switch (league) {
      case 'Diamond':
        return const Color(0xFFE1BEE7); // light purple
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return const Color(0xFFB0BEC5); // blue grey
      default:
        return const Color(0xFFCD7F32); // bronze
    }
  }

  static IconData _leagueIcon(String league) {
    switch (league) {
      case 'Diamond':
        return Icons.diamond_rounded;
      case 'Gold':
        return Icons.emoji_events_rounded;
      case 'Silver':
        return Icons.shield_rounded;
      default:
        return Icons.shield_outlined;
    }
  }
}
