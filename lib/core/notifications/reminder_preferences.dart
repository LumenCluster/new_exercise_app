import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/firestore_service.dart';
import '../localization/app_localizations.dart';
import 'notification_service.dart';

enum ReminderSection { workout, meal }

/// A reminder the Reminders screen offers, with its default schedule.
class ReminderDefinition {
  final String id;
  final int slot;
  final ReminderSection section;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final String notificationTitleKey;
  final String notificationBodyKey;
  final TimeOfDay defaultTime;
  final List<bool> defaultDays; // Mon → Sun

  const ReminderDefinition({
    required this.id,
    required this.slot,
    required this.section,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.notificationTitleKey,
    required this.notificationBodyKey,
    required this.defaultTime,
    required this.defaultDays,
  });
}

const List<ReminderDefinition> kReminderDefinitions = [
  ReminderDefinition(
    id: 'morning_workout',
    slot: 0,
    section: ReminderSection.workout,
    icon: Icons.wb_sunny_outlined,
    titleKey: 'reminders_morning_workout_title',
    subtitleKey: 'reminders_morning_workout_subtitle',
    notificationTitleKey: 'reminders_morning_workout_notif_title',
    notificationBodyKey: 'reminders_morning_workout_notif_body',
    defaultTime: TimeOfDay(hour: 7, minute: 30),
    defaultDays: [true, true, true, true, true, false, false],
  ),
  ReminderDefinition(
    id: 'evening_stretch',
    slot: 1,
    section: ReminderSection.workout,
    icon: Icons.nightlight_round_outlined,
    titleKey: 'reminders_evening_stretch_title',
    subtitleKey: 'reminders_evening_stretch_subtitle',
    notificationTitleKey: 'reminders_evening_stretch_notif_title',
    notificationBodyKey: 'reminders_evening_stretch_notif_body',
    defaultTime: TimeOfDay(hour: 20, minute: 30),
    defaultDays: [false, false, true, false, false, true, true],
  ),
  ReminderDefinition(
    id: 'breakfast',
    slot: 2,
    section: ReminderSection.meal,
    icon: Icons.free_breakfast_outlined,
    titleKey: 'reminders_breakfast_title',
    subtitleKey: 'reminders_breakfast_subtitle',
    notificationTitleKey: 'reminders_breakfast_notif_title',
    notificationBodyKey: 'reminders_breakfast_notif_body',
    defaultTime: TimeOfDay(hour: 8, minute: 0),
    defaultDays: [true, true, true, true, true, true, true],
  ),
  ReminderDefinition(
    id: 'lunch',
    slot: 3,
    section: ReminderSection.meal,
    icon: Icons.restaurant_outlined,
    titleKey: 'reminders_lunch_title',
    subtitleKey: 'reminders_lunch_subtitle',
    notificationTitleKey: 'reminders_lunch_notif_title',
    notificationBodyKey: 'reminders_lunch_notif_body',
    defaultTime: TimeOfDay(hour: 13, minute: 15),
    defaultDays: [true, true, true, true, true, false, false],
  ),
  ReminderDefinition(
    id: 'dinner',
    slot: 4,
    section: ReminderSection.meal,
    icon: Icons.soup_kitchen_outlined,
    titleKey: 'reminders_dinner_title',
    subtitleKey: 'reminders_dinner_subtitle',
    notificationTitleKey: 'reminders_dinner_notif_title',
    notificationBodyKey: 'reminders_dinner_notif_body',
    defaultTime: TimeOfDay(hour: 19, minute: 0),
    defaultDays: [true, true, true, true, true, true, true],
  ),
];

/// The user's time and active days for one reminder.
class ReminderSchedule {
  TimeOfDay time;
  List<bool> days;

  ReminderSchedule(this.time, this.days);

  Map<String, dynamic> toJson() => {'hour': time.hour, 'minute': time.minute, 'days': days};

  factory ReminderSchedule.fromJson(Map<String, dynamic> json, ReminderDefinition fallback) {
    final days = (json['days'] as List?)?.map((d) => d == true).toList();
    return ReminderSchedule(
      TimeOfDay(
        hour: (json['hour'] as num?)?.toInt() ?? fallback.defaultTime.hour,
        minute: (json['minute'] as num?)?.toInt() ?? fallback.defaultTime.minute,
      ),
      days != null && days.length == 7 ? days : [...fallback.defaultDays],
    );
  }
}

/// Reminder settings persisted in the user's Firestore cache. The master
/// switch shares `settings_reminders_enabled` with the Settings screen.
class ReminderPreferences {
  static const _enabledKey = 'settings_reminders_enabled';
  static const _configKey = 'reminders_config';
  static const _soundKey = 'settings_sound_enabled';

  bool enabled;
  final Map<String, ReminderSchedule> schedules;

  ReminderPreferences(this.enabled, this.schedules);

  static Future<ReminderPreferences> load() async {
    final db = FirestoreService();
    final enabled = await db.getCacheValue(_enabledKey);
    final raw = await db.getCacheValue(_configKey);

    Map<String, dynamic> saved = {};
    if (raw != null) {
      try {
        saved = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        // Corrupt config: fall back to defaults.
      }
    }

    return ReminderPreferences(
      enabled != null ? enabled == 'true' : true,
      {
        for (final def in kReminderDefinitions)
          def.id: saved[def.id] is Map<String, dynamic>
              ? ReminderSchedule.fromJson(saved[def.id] as Map<String, dynamic>, def)
              : ReminderSchedule(def.defaultTime, [...def.defaultDays]),
      },
    );
  }

  Future<void> save() async {
    final db = FirestoreService();
    await db.setCacheValue(_enabledKey, enabled.toString());
    await db.setCacheValue(
      _configKey,
      jsonEncode({for (final entry in schedules.entries) entry.key: entry.value.toJson()}),
    );
  }

  static Future<bool> soundEnabled() async {
    final sound = await FirestoreService().getCacheValue(_soundKey);
    return sound != null ? sound == 'true' : true;
  }
}

/// Turns saved preferences into scheduled OS notifications, with texts in
/// the app's current language.
class ReminderScheduler {
  static Future<void> apply(BuildContext context, ReminderPreferences prefs) async {
    final service = NotificationService();
    if (!prefs.enabled) {
      await service.cancelAll();
      return;
    }

    final reminders = [
      for (final def in kReminderDefinitions)
        ScheduledReminder(
          slot: def.slot,
          title: context.tr(def.notificationTitleKey),
          body: context.tr(def.notificationBodyKey),
          hour: prefs.schedules[def.id]!.time.hour,
          minute: prefs.schedules[def.id]!.time.minute,
          days: prefs.schedules[def.id]!.days,
        ),
    ];
    final sound = await ReminderPreferences.soundEnabled();
    await service.scheduleReminders(reminders, sound: sound);
  }

  /// Re-applies the saved preferences, e.g. after the sound setting changes.
  static Future<void> refresh(BuildContext context) async {
    final prefs = await ReminderPreferences.load();
    if (!context.mounted) return;
    await apply(context, prefs);
  }
}
