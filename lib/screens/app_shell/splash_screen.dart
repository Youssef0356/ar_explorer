import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../services/progress_service.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import 'privacy_policy_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for a nice splash animation duration
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final progress = context.read<ProgressService>();
    Widget nextScreen;
    
    if (!progress.hasAcceptedPrivacy) {
      nextScreen = const PrivacyPolicyScreen(showConfirmButton: true);
    } else if (progress.hasSeenOnboarding) {
      nextScreen = const MainScreen();
    } else {
      nextScreen = const OnboardingScreen();
    }

    // Use a smooth fade transition to the next screen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppTheme.scaffoldC(isDark),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo with multiple sequential animations
            Image.asset(
              'assets/images/app_logoTransparent.png',
              width: 160,
              height: 160,
            )
            .animate()
            .fade(duration: 800.ms)
            .scale(
              begin: const Offset(0.5, 0.5), 
              end: const Offset(1, 1), 
              curve: Curves.easeOutBack, 
              duration: 1000.ms
            )
            .then(delay: 200.ms)
            .shimmer(
              duration: 1200.ms, 
              color: AppTheme.accentCyan.withValues(alpha: 0.5)
            ),
            
            const SizedBox(height: 32),
            
            // App Title fading in and sliding up
            Text(
              'AR Explorer',
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.textPrimaryC(isDark),
                letterSpacing: 2.5,
              ),
            )
            .animate()
            .fade(delay: 500.ms, duration: 800.ms)
            .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
