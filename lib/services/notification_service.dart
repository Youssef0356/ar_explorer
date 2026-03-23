import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

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
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
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
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap if needed
      },
    );

    // Create Notification Channels for Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          _streakChannelId,
          _streakChannelName,
          importance: Importance.max,
          description: 'Reminders to keep your win streak alive.',
        ));

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          _funnyChannelId,
          _funnyChannelName,
          importance: Importance.high,
          description: 'Fun and engaging messages to continue your journey.',
        ));
    
    // Schedule initial engagement notifications
    if (_notificationsEnabled) {
      scheduleEngagementNotifications();
    }
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    if (!_notificationsEnabled) {
      await cancelAll();
    } else {
      scheduleEngagementNotifications();
    }
    notifyListeners();
  }

  Future<void> scheduleStreakReminder(int currentStreak) async {
    if (!_notificationsEnabled) return;
    
    // Cancel existing streak reminders to avoid duplicates
    await _notificationsPlugin.cancel(1001);

    if (currentStreak <= 0) return;

    final String message = currentStreak == 1
        ? "Don't lose your 1 day streak! Jump in for a quick lesson. 🔥"
        : "Your $currentStreak day streak is in danger! Keep it alive today. 🏆";

    await _notificationsPlugin.zonedSchedule(
      1001,
      "Streak Alert! 🔥",
      message,
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 23)), // 23 hours later
      NotificationDetails(
        android: AndroidNotificationDetails(
          _streakChannelId,
          _streakChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleEngagementNotifications() async {
    if (!_notificationsEnabled) return;
    
    // Schedule 3 notifications at random intervals (e.g. 2, 4, and 7 days)
    final random = Random();
    
    // Clear previous engagement notifications
    for (int i = 0; i < 3; i++) {
      await _notificationsPlugin.cancel(2000 + i);
    }

    final List<int> days = [2, 4, 7];
    for (int i = 0; i < days.length; i++) {
      final String message = _funnyMessages[random.nextInt(_funnyMessages.length)];
      
      await _notificationsPlugin.zonedSchedule(
        2000 + i,
        "Continue Your Journey 🚀",
        message,
        tz.TZDateTime.now(tz.local).add(Duration(days: days[i])),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _funnyChannelId,
            _funnyChannelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
