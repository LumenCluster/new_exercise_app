import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// One weekly reminder to schedule: fires at [hour]:[minute] on each day
/// whose flag in [days] (Mon → Sun) is true.
class ScheduledReminder {
  /// Stable 0-based slot; notification ids are derived from it.
  final int slot;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final List<bool> days;

  const ScheduledReminder({
    required this.slot,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.days,
  });
}

/// Thin wrapper around flutter_local_notifications for the app's workout
/// and meal reminders. Android and iOS only; a no-op elsewhere.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channelId = 'reminders';
  static const _silentChannelId = 'reminders_silent';
  static const _previewId = 999;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get isSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (_initialized || !isSupported) return;

    tz_data.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      // Unknown zone id: keep the package default (UTC) rather than crash.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is asked for when the user turns reminders on.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  /// Asks the OS for permission to post notifications. Returns whether it
  /// was granted.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  NotificationDetails _details({required bool sound}) => NotificationDetails(
        android: AndroidNotificationDetails(
          sound ? _channelId : _silentChannelId,
          sound ? 'Reminders' : 'Reminders (silent)',
          channelDescription: 'Workout, meal and hydration reminders',
          importance: Importance.high,
          priority: Priority.high,
          playSound: sound,
        ),
        iOS: DarwinNotificationDetails(presentSound: sound),
      );

  /// Replaces every scheduled reminder with [reminders].
  Future<void> scheduleReminders(List<ScheduledReminder> reminders, {required bool sound}) async {
    if (!isSupported) return;
    await init();
    await _plugin.cancelAll();

    final details = _details(sound: sound);
    for (final reminder in reminders) {
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
        if (!reminder.days[weekday - 1]) continue;
        await _plugin.zonedSchedule(
          id: reminder.slot * 10 + weekday,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: _nextInstance(weekday, reminder.hour, reminder.minute),
          notificationDetails: details,
          // Inexact keeps us clear of the exact-alarm permission; reminders
          // may arrive a few minutes late on Android.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Shows a notification right away (used for previews/confirmation).
  Future<void> showNow({required String title, required String body, required bool sound}) async {
    if (!isSupported) return;
    await init();
    await _plugin.show(id: _previewId, title: title, body: body, notificationDetails: _details(sound: sound));
  }

  Future<void> cancelAll() async {
    if (!isSupported) return;
    await init();
    await _plugin.cancelAll();
  }

  /// Next local date-time that falls on [weekday] at [hour]:[minute].
  tz.TZDateTime _nextInstance(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = tz.TZDateTime(tz.local, date.year, date.month, date.day + 1, hour, minute);
    }
    return date;
  }
}
