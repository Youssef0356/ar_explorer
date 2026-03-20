import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/certificate_progression_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/progress_service.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';
import 'services/ad_service.dart';
import 'services/review_service.dart';
import 'services/subscription_service.dart';
import 'services/game_progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  final subscriptionService = SubscriptionService();
  final themeService = ThemeService();
  final progressService = ProgressService();
  final adService = AdService();
  final soundService = SoundService();
  final reviewService = ReviewService();
  final gameProgressService = GameProgressService();

  // Initialize all services
  await subscriptionService.init();
  await themeService.init();
  await progressService.init();
  await gameProgressService.init();
  adService.setSubscriptionService(subscriptionService);
  adService.init();
  progressService.setSubscriptionService(subscriptionService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: subscriptionService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: progressService),
        ChangeNotifierProvider.value(value: adService),
        ChangeNotifierProvider.value(value: soundService),
        ChangeNotifierProvider.value(value: reviewService),
        ChangeNotifierProvider.value(value: gameProgressService),
      ],
      child: const ARExplorerApp(),
    ),
  );
}

class ARExplorerApp extends StatelessWidget {
  const ARExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final progress = context.read<ProgressService>();

    return MaterialApp(
      title: 'AR Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/home': (_) => const MainScreen(),
        '/certificate': (_) => const CertificateProgressionScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
      },
      home: !progress.hasAcceptedPrivacy
          ? const PrivacyPolicyScreen(showConfirmButton: true)
          : progress.hasSeenOnboarding
              ? const MainScreen()
              : const OnboardingScreen(),
    );
  }
}
