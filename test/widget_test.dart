import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ar_explorer/main.dart';
import 'package:ar_explorer/services/progress_service.dart';
import 'package:ar_explorer/services/theme_service.dart';

void main() {
  testWidgets('App launches and shows AR Explorer title', (
    WidgetTester tester,
  ) async {
    final progressService = ProgressService();
    final themeService = ThemeService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: progressService),
          ChangeNotifierProvider.value(value: themeService),
        ],
        child: const ARExplorerApp(),
      ),
    );

    expect(find.text('AR Explorer'), findsOneWidget);
    expect(find.text('Learn Augmented Reality'), findsOneWidget);
  });
}
