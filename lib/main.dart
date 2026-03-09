import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/certificate_screen.dart';
import 'services/progress_service.dart';
import 'services/theme_service.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final progressService = ProgressService();
  await progressService.init();

  final themeService = ThemeService();
  await themeService.init();

  final soundService = SoundService();
  await soundService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progressService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: soundService),
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
    final progress = context.watch<ProgressService>();

    return MaterialApp(
      title: 'AR Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/home': (_) => const HomeScreen(),
        '/certificate': (_) => const CertificateScreen(),
      },
      home: progress.hasSeenOnboarding
          ? const HomeScreen()
          : const OnboardingScreen(),
    );
  }
}
