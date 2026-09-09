import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:ar_explorer/screens/app_shell/main_screen.dart';
import 'package:ar_explorer/services/progress_service.dart';
import 'package:ar_explorer/services/theme_service.dart';
import 'package:ar_explorer/services/subscription_service.dart';
import 'package:ar_explorer/services/ad_service.dart';
import 'package:ar_explorer/services/sound_service.dart';
import 'package:ar_explorer/services/review_service.dart';
import 'package:ar_explorer/services/game_progress_service.dart';
import 'package:ar_explorer/services/navigation_service.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({
      'has_seen_showcase_tour_home_v2': true,
      'has_seen_showcase_tour_roadmap': true,
      'has_seen_showcase_tour_play': true,
      'has_seen_showcase_tour_rewards': true,
    });
  });

  testWidgets('App launches and shows AR Explorer title', (
    WidgetTester tester,
  ) async {
    final progressService = ProgressService();
    final themeService = ThemeService();
    final subscriptionService = SubscriptionService();
    final adService = AdService();
    final soundService = SoundService();
    final reviewService = ReviewService();
    final gameProgressService = GameProgressService();
    final navigationService = NavigationService();

    await progressService.init();
    await themeService.init();
    await subscriptionService.init();
    await gameProgressService.init();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: subscriptionService),
            ChangeNotifierProvider.value(value: themeService),
            ChangeNotifierProvider.value(value: progressService),
            ChangeNotifierProvider.value(value: adService),
            ChangeNotifierProvider.value(value: soundService),
            ChangeNotifierProvider.value(value: reviewService),
            ChangeNotifierProvider.value(value: gameProgressService),
            ChangeNotifierProvider.value(value: navigationService),
          ],
          child: const MaterialApp(
            home: MainScreen(),
          ),
        ),
      );

      // Re-verify that the app builds and shows AR Explorer title
      expect(find.text('AR Explorer'), findsOneWidget);
    });
  });
}
