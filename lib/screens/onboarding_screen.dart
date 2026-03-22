import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/progress_service.dart';
import '../widgets/animated_google_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  final _nameController = TextEditingController();
  int _currentPage = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // ── Pages: hook → features → certificates → rewards → name ──
  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == _totalPages - 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name to continue')),
        );
        return;
      }
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finish() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name to continue')),
      );
      return;
    }
    context.read<ProgressService>().updateUsername(name);
    context.read<ProgressService>().markOnboardingSeen();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGoogleBackground(
        isDark: true,
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button (pages 1-4) ──
              if (_currentPage < _totalPages - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                    child: TextButton(
                      onPressed: () {
                        _controller.animateToPage(
                          _totalPages - 1,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: Text(
                        'Skip',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 52),

              // ── Pages ──
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    return _buildPage(index);
                  },
                ),
              ),

              // ── Dots ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _totalPages,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? AppTheme.accentPurple
                            : AppTheme.textMuted.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // ── CTA Button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        foregroundColor: AppTheme.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _totalPages - 1
                            ? 'Start My Journey 🚀'
                            : 'Continue',
                        style: AppTheme.buttonText.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHookPage();
      case 1:
        return _buildFeaturesPage();
      case 2:
        return _buildCertificatesPage();
      case 3:
        return _buildLearningPathPage();
      case 4:
        return _buildNamePage();
      default:
        return const SizedBox();
    }
  }

  // ── PAGE 0: Big Hook ──
  Widget _buildHookPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated logo
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            ),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.accentPurple.withOpacity(0.2),
                    child: const Icon(Icons.view_in_ar_rounded,
                        size: 60, color: AppTheme.accentPurple),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.7, 0.7),
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 36),

          // Bold headline
          Text(
            'Master AR.\nLand the Job.',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 38,
              height: 1.15,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn()
              .slideY(begin: 0.2, curve: Curves.easeOutCubic),

          const SizedBox(height: 16),

          Text(
            'The only AR learning platform built\nfor developers who want to get hired.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 32),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statChip('6', 'Modules'),
              const SizedBox(width: 12),
              _statChip('3', 'Games'),
              const SizedBox(width: 12),
              _statChip('∞', 'Practice'),
            ],
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _statChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              )),
          Text(label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textMuted,
                fontSize: 11,
              )),
        ],
      ),
    );
  }

  // ── PAGE 1: Features ──
  Widget _buildFeaturesPage() {
    final features = [
      (
        Icons.school_rounded,
        AppTheme.accentPurple,
        'Deep AR Curriculum',
        'From basics to SLAM, ARKit, ARCore, Meta Quest & WebXR. Interview-grade content.'
      ),
      (
        Icons.code_rounded,
        AppTheme.accentBlue,
        'Code Challenge Games',
        'Fill-in-the-blank coding challenges across Vuforia, ARKit, ARCore and OpenXR.'
      ),
      (
        Icons.architecture_rounded,
        AppTheme.accentPurple,
        'XR Builder Simulator',
        'Build real Unity Inspector setups. Wire AR components like a senior developer.'
      ),
      (
        Icons.timer_rounded,
        AppTheme.accentAmber,
        'Mock Interviews',
        'Timed, scored, realistic. Know exactly where you stand before the real thing.'
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need\nto get hired in AR',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 28,
              height: 1.2,
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 28),

          ...features.asMap().entries.map((entry) {
            final i = entry.key;
            final f = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: f.$2.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: f.$2.withOpacity(0.3)),
                    ),
                    child: Icon(f.$1, color: f.$2, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$3,
                            style: AppTheme.headingSmall.copyWith(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(f.$4,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            )),
                      ],
                    ),
                  ),
                ],
              )
                  .animate(delay: Duration(milliseconds: 100 + i * 80))
                  .fadeIn()
                  .slideX(begin: 0.1),
            );
          }),
        ],
      ),
    );
  }

  // ── PAGE 2: Certificates ──
  Widget _buildCertificatesPage() {
    final tiers = [
      ('🥉', 'Bronze', const Color(0xFFCD7F32), 'Complete 3 modules'),
      ('🥈', 'Silver', const Color(0xFFB0BEC5), 'Master all modules & quizzes'),
      ('🥇', 'Gold', const Color(0xFFFFCA28), 'Score 90%+ in Mock Interview'),
      ('💎', 'Platinum', const Color(0xFFE1BEE7), 'Complete all games & content'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn verified\ncredentials',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 32,
              height: 1.15,
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          Text(
            'Share on LinkedIn and stand out to AR employers.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ).animate(delay: 150.ms).fadeIn(),

          const SizedBox(height: 28),

          ...tiers.asMap().entries.map((entry) {
            final i = entry.key;
            final t = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: t.$3.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: t.$3.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Text(t.$1, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.$2,
                            style: TextStyle(
                              color: t.$3,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            )),
                        Text(t.$4,
                            style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Icon(Icons.workspace_premium_rounded,
                      color: t.$3.withOpacity(0.5), size: 18),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: 100 + i * 80))
                .fadeIn()
                .slideX(begin: 0.08);
          }),
        ],
      ),
    );
  }

  // ── PAGE 3: Learning path ──
  Widget _buildLearningPathPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your roadmap\nto AR mastery',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 32,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Visual roadmap preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentPurple.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                _roadmapStep(1, 'Learn', 'Complete modules & topics', AppTheme.accentCyan, true),
                _roadmapConnector(AppTheme.accentCyan),
                _roadmapStep(2, 'Quiz', 'Pass quizzes to unlock next level', AppTheme.accentBlue, true),
                _roadmapConnector(AppTheme.accentBlue),
                _roadmapStep(3, 'Build', 'Practice coding & XR games', AppTheme.accentPurple, false),
                _roadmapConnector(AppTheme.accentPurple),
                _roadmapStep(4, 'Certify', 'Earn & share certificates', AppTheme.accentAmber, false),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1),

          const SizedBox(height: 20),

          Text(
            'Each quiz unlocks the next module.\nProgress at your own pace.',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 350.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _roadmapStep(int num, String title, String subtitle, Color color, bool active) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? color : Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$num',
              style: TextStyle(
                color: active ? color : Colors.white38,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: active ? color : Colors.white38,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  )),
              Text(subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: active ? AppTheme.textSecondary : AppTheme.textMuted,
                  )),
            ],
          ),
        ),
        if (active) Icon(Icons.check_circle_rounded, color: color, size: 18),
      ],
    );
  }

  Widget _roadmapConnector(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 20,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withOpacity(0.5), color.withOpacity(0.1)],
          ),
        ),
      ),
    );
  }

  // ── PAGE 4: Name ──
  Widget _buildNamePage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const Text('👤', style: TextStyle(fontSize: 64))
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                curve: Curves.elasticOut,
                duration: 600.ms,
              ),

          const SizedBox(height: 28),

          Text(
            'What should we\ncall you?',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 32,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.2),

          const SizedBox(height: 12),

          Text(
            'Your name appears on your AR Explorer\ncertificates when you earn them.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 250.ms).fadeIn(),

          const SizedBox(height: 36),

          TextField(
            controller: _nameController,
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textPrimary),
            decoration: AppTheme.inputDecoration(
              label: 'Your Name',
              hint: 'e.g. Alex Chen',
              isDark: true,
            ).copyWith(
              prefixIcon:
                  const Icon(Icons.person_outline, color: AppTheme.accentCyan),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _finish(),
            autofocus: false,
          ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15),

          const SizedBox(height: 16),

          Text(
            'You can change this later in Settings.',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted),
          ).animate(delay: 450.ms).fadeIn(),
        ],
      ),
      ),
    );
  }
}
