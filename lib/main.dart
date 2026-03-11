import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/certificate_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/progress_service.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';
import 'services/ad_service.dart';
import 'services/review_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  final progressService = ProgressService();
  await progressService.init();

  final themeService = ThemeService();
  await themeService.init();

  final soundService = SoundService();
  await soundService.init();

  final adService = AdService();
  adService.init();

  final reviewService = ReviewService();
  await reviewService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progressService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: soundService),
        ChangeNotifierProvider.value(value: adService),
        ChangeNotifierProvider.value(value: reviewService),
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
        '/home': (_) => const HomeScreen(),
        '/certificate': (_) => const CertificateScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
      },
      home: !progress.hasAcceptedPrivacy
          ? const PrivacyPolicyScreen(showConfirmButton: true)
          : progress.hasSeenOnboarding
              ? const HomeScreen()
              : const OnboardingScreen(),
    );
  }
}
