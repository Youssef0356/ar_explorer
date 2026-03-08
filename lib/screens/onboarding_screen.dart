import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/progress_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      emoji: '🚀',
      title: 'Welcome to AR Explorer',
      subtitle:
          'Your interview preparation companion for Augmented Reality.\n\n'
          'Master core AR concepts, from basics to advanced spatial computing.',
    ),
    _OnboardingPage(
      emoji: '🗺️',
      title: 'Your Learning Path',
      subtitle:
          'Complete modules and pass quizzes at 70%+ to unlock the next stage.\n\n'
          'Track your progress on the visual Roadmap and review flashcards to reinforce key concepts.',
    ),
    _OnboardingPage(
      emoji: '🎯',
      title: 'Get Interview Ready',
      subtitle:
          'Practice weak areas, take daily challenges, and test yourself with timed Mock Interviews.\n\n'
          'Let\'s begin your journey to becoming an AR expert!',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<ProgressService>().markOnboardingSeen();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(true),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip ──
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMuted),
                  ),
                ),
              ),

              // ── Pages ──
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.emoji,
                            style: const TextStyle(fontSize: 72),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.5, 0.5),
                                end: const Offset(1.0, 1.0),
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.elasticOut,
                              ),
                          const SizedBox(height: 32),
                          Text(
                            page.title,
                            style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── Indicators ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppTheme.accentCyan
                          : AppTheme.textMuted.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Next'
                          : 'Get Started',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}
