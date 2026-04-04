import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "refreshNotifications") {
      await NotificationService.handleBackgroundRefresh();
    }
    return Future.value(true);
  });
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  static const String _streakChannelId = 'streak_reminders';
  static const String _streakChannelName = 'Streak Reminders';
  static const String _funnyChannelId = 'engagement_messages';
  static const String _funnyChannelName = 'Funny Reminders';
  static const String _dailyChannelId = 'daily_xp_reminders';
  static const String _dailyChannelName = 'Daily XP Reminders';

  final List<String> _funnyMessages = [
    "We are waiting for your interview, don't keep the hologram hanging! 🤖",
    "Your AR skills are getting rusty. Time to polish them! ✨",
    "Did you know? AR doesn't stand for 'Always Resting'. Get back to work! 🔥",
    "The systems are failing! Only you can debug them. 💻",
    "Continue your journey to becoming an XR Builder. The future is waiting. 🚀",
    "Your future self just called. They said they need those AR certifications! 📞",
    "Is that a bug in the matrix? No, just you missing your daily lesson. 🐛",
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    tz_data.initializeTimeZones();
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool? granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('Notification permissions granted: $granted');
    }

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      _streakChannelId,
      _streakChannelName,
      importance: Importance.max,
      description: 'Reminders to keep your win streak alive.',
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      _funnyChannelId,
      _funnyChannelName,
      importance: Importance.high,
      description: 'Fun and engaging messages to continue your journey.',
    ));

    await androidPlugin?.createNotificationChannel(const AndroidNotificationChannel(
      _dailyChannelId,
      _dailyChannelName,
      importance: Importance.high,
      description: 'Reminders to claim your daily XP bonus.',
    ));
    
    if (_notificationsEnabled) {
      scheduleEngagementNotifications();
      scheduleDailyXPReminder();
      
      // Ensure WorkManager is also initialized and checking periodically
      try {
        Workmanager().initialize(
          callbackDispatcher,
          isInDebugMode: kDebugMode,
        );
        Workmanager().registerPeriodicTask(
          "daily-notification-refresh",
          "refreshNotifications",
          frequency: const Duration(hours: 12),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
          constraints: Constraints(
            networkType: NetworkType.notRequired,
            requiresBatteryNotLow: true,
          ),
        );
      } catch (e) {
        debugPrint('Workmanager registration error: $e');
      }
    }
  }

  // --- Background Task Entry Point ---
  static Future<void> handleBackgroundRefresh() async {
    final service = NotificationService();
    await service.init();
    debugPrint('Background notification refresh completed.');
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    if (!_notificationsEnabled) {
      await cancelAll();
    } else {
      scheduleEngagementNotifications();
      scheduleDailyXPReminder();
    }
    notifyListeners();
  }

  Future<void> scheduleStreakReminder(int currentStreak) async {
    if (!_notificationsEnabled || currentStreak <= 0) return;
    
    await _notificationsPlugin.cancel(id: 1001);

    final String message = currentStreak == 1
        ? "Don't lose your 1 day streak! Jump in for a quick lesson. 🔥"
        : "Your $currentStreak day streak is in danger! Keep it alive today. 🏆";

    await _notificationsPlugin.zonedSchedule(
      id: 1001,
      title: "Streak Alert! 🔥",
      body: message,
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(hours: 23)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _streakChannelId,
          _streakChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleEngagementNotifications() async {
    if (!_notificationsEnabled) return;
    
    final random = Random();
    final List<int> days = [2, 4, 7];
    
    for (int i = 0; i < days.length; i++) {
      await _notificationsPlugin.cancel(id: 2000 + i);
      final String message = _funnyMessages[random.nextInt(_funnyMessages.length)];
      
      await _notificationsPlugin.zonedSchedule(
        id: 2000 + i,
        title: "Continue Your Journey 🚀",
        body: message,
        scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(days: days[i])),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _funnyChannelId,
            _funnyChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> scheduleDailyXPReminder() async {
    if (!_notificationsEnabled) return;

    await _notificationsPlugin.cancel(id: 3000);

    final now = tz.TZDateTime.now(tz.local);
    // Since the app just started, they already got today's XP if they were eligible.
    // We should always schedule the *next* notification for tomorrow at 10:00 AM.
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);
    
    // Only add a day if 10:00 AM has already passed today.
    // If it's 9:00 AM, scheduledDate will be today at 10:00 AM.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: 3000,
      title: "Daily XP Ready! 🚀",
      body: "Come get your 5 XP to start your journey and unlock new AR modules!",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyChannelId,
          _dailyChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> triggerFunnyNotification() async {
    final random = Random();
    final String message = _funnyMessages[random.nextInt(_funnyMessages.length)];
    
    await _notificationsPlugin.show(
      id: 8888,
      title: "Quick AR Reminder! 🚀",
      body: message,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _funnyChannelId,
          _funnyChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // --- Debug / Testing Purposes ---
  Future<void> scheduleTestAlarm60s() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 60));
    
    debugPrint('Scheduling test alarm for $scheduledDate');

    await _notificationsPlugin.zonedSchedule(
      id: 9991,
      title: "Test Alarm (60s) 🕒",
      body: "If you are seeing this, your timed alarms are working perfectly!",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> triggerDebugNotification() async {
    await _notificationsPlugin.show(
      id: 9999,
      title: "Debug Testing 🛠️",
      body: "Notification pipeline is working correctly!",
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'debug_channel',
          'Debug Channel',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}