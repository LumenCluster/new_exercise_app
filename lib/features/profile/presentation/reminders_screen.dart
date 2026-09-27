import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_preferences.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../domain/entities/user_profile.dart';

/// Workout and meal reminders: a master switch plus a time and weekdays per
/// reminder. Every change is saved and re-scheduled as local notifications.
class RemindersScreen extends StatefulWidget {
  final UserProfile? profile;

  const RemindersScreen({super.key, this.profile});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Color Palette
  static const backgroundColor = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF1E4620);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);

  // Custom Section Colors
  static const greenIconBg = Color(0xFFEBF5E8);
  static const greenIconColor = Color(0xFF558B2F);
  static const greenTimeBg = Color(0xFFEFF7E6);
  static const greenTimeText = Color(0xFF43A047);

  static const orangeIconBg = Color(0xFFFBE9E7);
  static const orangeIconColor = Color(0xFFE65100);
  static const orangeTimeBg = Color(0xFFFCE4EC);
  static const orangeTimeText = Color(0xFFE65100);

  static const _dayKeys = [
    'reminders_day_mon', 'reminders_day_tue', 'reminders_day_wed', 'reminders_day_thu',
    'reminders_day_fri', 'reminders_day_sat', 'reminders_day_sun',
  ];

  ReminderPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ReminderPreferences.load();
    if (!mounted) return;
    setState(() => _prefs = prefs);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Saves the current preferences and re-schedules notifications.
  Future<void> _saveAndSchedule() async {
    final prefs = _prefs!;
    await prefs.save();
    if (!mounted) return;
    await ReminderScheduler.apply(context, prefs);
  }

  Future<void> _toggleEnabled(bool value) async {
    final prefs = _prefs!;
    if (value) {
      final granted = await NotificationService().requestPermission();
      if (!mounted) return;
      if (!granted && NotificationService().isSupported) {
        _toast(context.tr('reminders_permission_denied'));
        return;
      }
    }
    setState(() => prefs.enabled = value);
    await _saveAndSchedule();
    if (!mounted) return;

    if (value) {
      final sound = await ReminderPreferences.soundEnabled();
      if (!mounted) return;
      await NotificationService().showNow(
        title: context.tr('reminders_enabled_notif_title'),
        body: context.tr('reminders_enabled_notif_body'),
        sound: sound,
      );
    } else {
      _toast(context.tr('reminders_disabled_toast'));
    }
  }

  Future<void> _pickTime(ReminderDefinition def) async {
    final schedule = _prefs!.schedules[def.id]!;
    final picked = await showTimePicker(
      context: context,
      initialTime: schedule.time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: primaryDark),
        ),
        child: child!,
      ),
    );
    if (picked == null || picked == schedule.time) return;
    setState(() => schedule.time = picked);
    await _saveAndSchedule();
    if (!mounted) return;
    _toast(context.tr('reminders_time_saved_toast', {
      'name': context.tr(def.titleKey),
      'time': picked.format(context),
    }));
  }

  Future<void> _toggleDay(ReminderDefinition def, int dayIndex) async {
    final schedule = _prefs!.schedules[def.id]!;
    setState(() => schedule.days[dayIndex] = !schedule.days[dayIndex]);
    await _saveAndSchedule();
  }

  /// Shows this reminder's notification now so the user can preview it.
  Future<void> _preview(ReminderDefinition def) async {
    final granted = await NotificationService().requestPermission();
    if (!mounted) return;
    if (!granted) {
      _toast(context.tr(NotificationService().isSupported ? 'reminders_permission_denied' : 'reminders_unsupported'));
      return;
    }
    final sound = await ReminderPreferences.soundEnabled();
    if (!mounted) return;
    await NotificationService().showNow(
      title: context.tr(def.notificationTitleKey),
      body: context.tr(def.notificationBodyKey),
      sound: sound,
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _prefs;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (prefs == null)
              const Center(child: CircularProgressIndicator(color: primaryDark))
            else
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildEnableNotificationsTile(prefs),
                    const SizedBox(height: 20),
                    // Reminder cards are inert while notifications are off.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: prefs.enabled ? 1 : 0.45,
                      child: IgnorePointer(
                        ignoring: !prefs.enabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context.tr('reminders_section_workout')),
                            const SizedBox(height: 10),
                            _buildRemindersCard(prefs, ReminderSection.workout),
                            const SizedBox(height: 8),
                            _buildFooterNote(context.tr('reminders_workout_footer')),
                            const SizedBox(height: 20),
                            _buildSectionTitle(context.tr('reminders_section_meal')),
                            const SizedBox(height: 10),
                            _buildRemindersCard(prefs, ReminderSection.meal),
                            const SizedBox(height: 8),
                            _buildFooterNote(context.tr('reminders_meal_footer')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: AppBottomNavBar(currentTab: AppTab.profile, profile: widget.profile),
            ),
          ],
        ),
      ),
    );
  }

  // Header Bar
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
        ),
        const SizedBox(width: 12),
        Text(
          context.tr('settings_reminders_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  // Enable Notifications Card
  Widget _buildEnableNotificationsTile(ReminderPreferences prefs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: greenIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 20, color: greenIconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('reminders_enable_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('reminders_enable_subtitle'),
                  style: const TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: prefs.enabled,
            activeThumbColor: Colors.white,
            activeTrackColor: primaryDark,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black12,
            onChanged: _toggleEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }

  Widget _buildRemindersCard(ReminderPreferences prefs, ReminderSection section) {
    final defs = kReminderDefinitions.where((d) => d.section == section).toList();
    final isWorkout = section == ReminderSection.workout;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          for (var i = 0; i < defs.length; i++) ...[
            if (i > 0) const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
            _buildReminderItem(
              def: defs[i],
              schedule: prefs.schedules[defs[i].id]!,
              iconBg: isWorkout ? greenIconBg : orangeIconBg,
              iconColor: isWorkout ? greenIconColor : orangeIconColor,
              timeBg: isWorkout ? greenTimeBg : orangeTimeBg,
              timeTextColor: isWorkout ? greenTimeText : orangeTimeText,
            ),
          ],
        ],
      ),
    );
  }

  // Single Item Widget
  Widget _buildReminderItem({
    required ReminderDefinition def,
    required ReminderSchedule schedule,
    required Color iconBg,
    required Color iconColor,
    required Color timeBg,
    required Color timeTextColor,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tapping the icon or text previews the notification.
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _preview(def),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(def.icon, size: 18, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr(def.titleKey),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr(def.subtitleKey),
                            style: const TextStyle(fontSize: 10, color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _pickTime(def),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: timeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  schedule.time.format(context),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: timeTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(7, (index) {
            final isActive = schedule.days[index];
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: GestureDetector(
                onTap: () => _toggleDay(def, index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? activeGreen : Colors.transparent,
                    border: Border.all(
                      color: isActive ? activeGreen : Colors.black12,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      context.tr(_dayKeys[index]),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFooterNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: textSecondary,
          height: 1.3,
        ),
      ),
    );
  }
}
