import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ar_explorer/main.dart';
import 'package:ar_explorer/services/progress_service.dart';
import 'package:ar_explorer/services/theme_service.dart';
import 'package:ar_explorer/services/subscription_service.dart';
import 'package:ar_explorer/services/ad_service.dart';
import 'package:ar_explorer/services/sound_service.dart';
import 'package:ar_explorer/services/review_service.dart';

void main() {
  testWidgets('App launches and shows AR Explorer title', (
    WidgetTester tester,
  ) async {
    final progressService = ProgressService();
    final themeService = ThemeService();
    final subscriptionService = SubscriptionService();
    final adService = AdService();
    final soundService = SoundService();
    final reviewService = ReviewService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: subscriptionService),
          ChangeNotifierProvider.value(value: themeService),
          ChangeNotifierProvider.value(value: progressService),
          ChangeNotifierProvider.value(value: adService),
          ChangeNotifierProvider.value(value: soundService),
          ChangeNotifierProvider.value(value: reviewService),
        ],
        child: const ARExplorerApp(),
      ),
    );

    expect(find.text('AR Explorer'), findsOneWidget);
    expect(find.text('Learn Augmented Reality'), findsOneWidget);
  });
}
