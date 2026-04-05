import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/certificate_progression_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/splash_screen.dart';
import 'services/progress_service.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';
import 'services/ad_service.dart';
import 'services/review_service.dart';
import 'services/subscription_service.dart';
import 'services/game_progress_service.dart';
import 'services/notification_service.dart';
import 'services/navigation_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  // ── Orientation lock: portrait for phones, all orientations for tablets ──
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final physicalSize = view.physicalSize;
  final devicePixelRatio = view.devicePixelRatio;
  final shortestSideDp = physicalSize.shortestSide / devicePixelRatio;

  if (shortestSideDp >= 600) {
    // Tablet — allow all orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    // Phone — lock to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
  
  // Initialize Ads with timeout to prevent hanging on emulators
  try {
    await MobileAds.instance.initialize().timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('MobileAds initialization error or timeout: $e');
  }

  final subscriptionService = SubscriptionService();
  final themeService = ThemeService();
  final progressService = ProgressService();
  final adService = AdService();
  final soundService = SoundService();
  final reviewService = ReviewService();
  final gameProgressService = GameProgressService();
  final notificationService = NotificationService();
  final navigationService = NavigationService();


  // Initialize all services with resilience
  try {
    await subscriptionService.init();
  } catch (e) {
    debugPrint('SubscriptionService init error: $e');
  }

  try {
    await themeService.init();
  } catch (e) {
    debugPrint('ThemeService init error: $e');
  }

  try {
    await progressService.init();
  } catch (e) {
    debugPrint('ProgressService init error: $e');
  }

  try {
    await gameProgressService.init();
  } catch (e) {
    debugPrint('GameProgressService init error: $e');
  }

  try {
    await soundService.init();
  } catch (e) {
    debugPrint('SoundService init error: $e');
  }

  try {
    await notificationService.init();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }



  try {
    adService.setSubscriptionService(subscriptionService);
    adService.init();
  } catch (e) {
    debugPrint('AdService init error: $e');
  }

  progressService.setSubscriptionService(subscriptionService);
  progressService.setGameProgressService(gameProgressService);

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
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: navigationService),

      ],
      child: const ARExplorerApp(),
    ),
  );
}

class ARExplorerApp extends StatefulWidget {
  const ARExplorerApp({super.key});

  @override
  State<ARExplorerApp> createState() => _ARExplorerAppState();
}

class _ARExplorerAppState extends State<ARExplorerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<NotificationService>().scheduleEngagementNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final isDark = themeService.isDarkMode;
    final isNeon = themeService.isNeonMode;

    return MaterialApp(
      title: 'AR Explorer',
      debugShowCheckedModeBanner: false,
      theme: isNeon ? AppTheme.neonTheme : AppTheme.lightTheme,
      darkTheme: isNeon ? AppTheme.neonTheme : AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/home': (_) => const MainScreen(),
        '/certificate': (_) => const CertificateProgressionScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/paywall': (_) => const PaywallScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
