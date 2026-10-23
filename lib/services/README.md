# Services

Business logic, state management, and external integrations. All services extend `ChangeNotifier` and are provided via `Provider`.

- **`progress_service.dart`** — Learning progress, XP, streaks, certificates (SharedPreferences)
- **`game_progress_service.dart`** — Game-specific progress: level completion, stars, unified XP
- **`subscription_service.dart`** — Premium subscription state (RevenueCat)
- **`ad_service.dart`** — Google AdMob integration (banners, interstitials, rewarded ads)
- **`sound_service.dart`** — Sound effects (tap, success, failure, achievement)
- **`theme_service.dart`** — Dark/light/neon theme mode persistence
- **`pdf_export_service.dart`** — Certificate PDF generation
- **`review_service.dart`** — App store review prompt logic
- **`navigation_service.dart`** — Global navigation key
