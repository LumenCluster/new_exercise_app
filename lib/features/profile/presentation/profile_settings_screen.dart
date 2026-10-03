import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/database/firestore_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/reminder_preferences.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../meal_plan/presentation/providers/meal_plan_provider.dart';
import '../../tracking/presentation/providers/water_intake_provider.dart';
import '../../tracking/presentation/providers/weight_log_provider.dart';
import '../domain/entities/user_profile.dart';
import 'pages/profile_input_screen.dart';
import 'upgrade_premium_screen.dart';
import 'reminders_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final UserProfile? profile;

  const ProfileSettingsScreen({super.key, this.profile});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // Theme Colors
  static const backgroundColor = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeGreenBg = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);
  static const dividerColor = Color(0xFFF0F0EB);

  bool _settingsLoaded = false;
  bool _remindersEnabled = true;
  bool _soundEnabled = true;
  bool _voiceCuesEnabled = true;
  double _volume = 0.7;
  bool _wearableConnected = true;
  bool _isPremium = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = FirestoreService();
    final reminders = await db.getCacheValue('settings_reminders_enabled');
    final sound = await db.getCacheValue('settings_sound_enabled');
    final voice = await db.getCacheValue('settings_voice_enabled');
    final volume = await db.getCacheValue('settings_volume');
    final wearable = await db.getCacheValue('settings_wearable_connected');
    final premium = await db.getCacheValue('settings_premium');
    if (!mounted) return;
    setState(() {
      _remindersEnabled = reminders != null ? reminders == 'true' : true;
      _soundEnabled = sound != null ? sound == 'true' : true;
      _voiceCuesEnabled = voice != null ? voice == 'true' : true;
      _volume = volume != null ? double.tryParse(volume) ?? 0.7 : 0.7;
      _wearableConnected = wearable != null ? wearable == 'true' : true;
      _isPremium = premium == 'true';
      _settingsLoaded = true;
    });
  }

  Future<void> _persist(String key, String value) async {
    await FirestoreService().setCacheValue(key, value);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = languageForCode(context.watch<LocaleProvider>().locale.languageCode);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (!_settingsLoaded)
              const Center(child: CircularProgressIndicator())
            else
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 90),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildUserProfileCard(),
                    const SizedBox(height: 20),

                    // Preferences Section
                    _buildSectionTitle(context.tr('settings_section_preferences')),
                    const SizedBox(height: 10),
                    _buildSettingsGroup([
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        iconBg: const Color(0xFFEBF5E8),
                        iconColor: activeGreen,
                        title: context.tr('settings_reminders_title'),
                        subtitle: context.tr('settings_reminders_subtitle'),
                        trailingText: _remindersEnabled ? context.tr('settings_on') : context.tr('settings_off'),
                        trailingTextColor: _remindersEnabled ? activeGreen : textSecondary,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RemindersScreen(profile: widget.profile)),
                          );
                          // Reflect the master switch the user may have changed.
                          final enabled = await FirestoreService().getCacheValue('settings_reminders_enabled');
                          if (!mounted) return;
                          setState(() => _remindersEnabled = enabled != null ? enabled == 'true' : true);
                        },
                      ),
                      _SettingsItem(
                        icon: Icons.volume_up_outlined,
                        iconBg: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFFAB47BC),
                        title: context.tr('settings_sound_title'),
                        subtitle: context.tr('settings_sound_subtitle'),
                        onTap: _showSoundSettingsDialog,
                      ),
                      _SettingsItem(
                        icon: Icons.language_outlined,
                        iconBg: const Color(0xFFE1F5FE),
                        iconColor: const Color(0xFF29B6F6),
                        title: context.tr('settings_language_title'),
                        subtitle: context.tr('settings_language_subtitle'),
                        trailingText: currentLanguage.nativeName,
                        trailingTextColor: const Color(0xFF29B6F6),
                        onTap: _showLanguageDialog,
                      ),
                      _SettingsItem(
                        icon: Icons.sync_rounded,
                        iconBg: const Color(0xFFE0F2F1),
                        iconColor: const Color(0xFF26A69A),
                        title: context.tr('settings_wearable_title'),
                        subtitle: context.tr('settings_wearable_subtitle'),
                        trailingText: _wearableConnected ? context.tr('settings_connected') : context.tr('settings_not_connected'),
                        trailingTextColor: _wearableConnected ? const Color(0xFF26A69A) : textSecondary,
                        onTap: _showWearableDialog,
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Account & Data Section
                    _buildSectionTitle(context.tr('settings_section_account_data')),
                    const SizedBox(height: 10),
                    _buildSettingsGroup([
                      _SettingsItem(
                        icon: Icons.restart_alt_rounded,
                        iconBg: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFE08A00),
                        title: context.tr('settings_restart_data_title'),
                        subtitle: context.tr('settings_restart_data_subtitle'),
                        onTap: _confirmRestartData,
                      ),
                      _SettingsItem(
                        icon: Icons.delete_outline_rounded,
                        iconBg: const Color(0xFFFFEBEE),
                        iconColor: const Color(0xFFEF5350),
                        title: context.tr('settings_delete_data_title'),
                        subtitle: context.tr('settings_delete_data_subtitle'),
                        onTap: _confirmDeleteData,
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Upgrade Section
                    _buildSectionTitle(context.tr('settings_section_upgrade')),
                    const SizedBox(height: 10),
                    _buildSettingsGroup([
                      _SettingsItem(
                        icon: Icons.workspace_premium_outlined,
                        iconBg: const Color(0xFFFFF8E1),
                        iconColor: const Color(0xFFFFB300),
                        title: _isPremium ? context.tr('settings_premium_active_title') : context.tr('settings_premium_title'),
                        subtitle: _isPremium
                            ? context.tr('settings_premium_active_subtitle')
                            : context.tr('settings_premium_subtitle'),
                        onTap: _isPremium
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const UpgradePremiumScreen()),
                                ),
                        customWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isPremium ? activeGreenBg : const Color(0xFFFFECB3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _isPremium ? context.tr('settings_active_badge') : context.tr('settings_upgrade_badge'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _isPremium ? activeGreen : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Support Section
                    _buildSectionTitle(context.tr('settings_section_support')),
                    const SizedBox(height: 10),
                    _buildSettingsGroup([
                      _SettingsItem(
                        icon: Icons.star_border_rounded,
                        iconBg: const Color(0xFFEBF5E8),
                        iconColor: activeGreen,
                        title: context.tr('settings_rate_us_title'),
                        subtitle: context.tr('settings_rate_us_subtitle'),
                        onTap: _showRatingDialog,
                      ),
                      _SettingsItem(
                        icon: Icons.share_outlined,
                        iconBg: const Color(0xFFF3E5F5),
                        iconColor: const Color(0xFFAB47BC),
                        title: context.tr('settings_share_app_title'),
                        subtitle: context.tr('settings_share_app_subtitle'),
                        onTap: _showShareSheet,
                      ),
                      _SettingsItem(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconBg: const Color(0xFFE1F5FE),
                        iconColor: const Color(0xFF29B6F6),
                        title: context.tr('settings_feedback_title'),
                        subtitle: context.tr('settings_feedback_subtitle'),
                        onTap: _showFeedbackDialog,
                      ),
                      _SettingsItem(
                        icon: Icons.shield_outlined,
                        iconBg: const Color(0xFFEFEFE9),
                        iconColor: textSecondary,
                        title: context.tr('settings_privacy_policy_title'),
                        subtitle: context.tr('settings_privacy_policy_subtitle'),
                        onTap: _showPrivacyPolicySheet,
                      ),
                    ]),
                  ],
                ),
              ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: AppBottomNavBar(currentTab: AppTab.profile, profile: widget.profile),
            ),
            if (_busy)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Preferences
  // ---------------------------------------------------------------------

  Future<void> _showSoundSettingsDialog() async {
    bool sound = _soundEnabled;
    bool voice = _voiceCuesEnabled;
    double volume = _volume;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('settings_sound_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('settings_sound_effects')),
                value: sound,
                activeThumbColor: activeGreen,
                onChanged: (v) => setDialogState(() => sound = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.tr('settings_voice_cues')),
                value: voice,
                activeThumbColor: activeGreen,
                onChanged: (v) => setDialogState(() => voice = v),
              ),
              Row(
                children: [
                  const Icon(Icons.volume_down, size: 18, color: textSecondary),
                  Expanded(
                    child: Slider(
                      value: volume,
                      activeColor: activeGreen,
                      onChanged: (v) => setDialogState(() => volume = v),
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 18, color: textSecondary),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common_cancel'))),
            FilledButton(
              onPressed: () async {
                setState(() {
                  _soundEnabled = sound;
                  _voiceCuesEnabled = voice;
                  _volume = volume;
                });
                await _persist('settings_sound_enabled', sound.toString());
                await _persist('settings_voice_enabled', voice.toString());
                await _persist('settings_volume', volume.toString());
                // Scheduled reminders pick up the new sound preference.
                if (mounted) await ReminderScheduler.refresh(this.context);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(context.tr('common_save')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLanguageDialog() async {
    final localeProvider = context.read<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;
    final selected = await showDialog<AppLanguage>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.tr('settings_choose_language')),
        children: [
          RadioGroup<String>(
            groupValue: currentCode,
            onChanged: (code) => Navigator.pop(
              context,
              kSupportedLanguages.firstWhere((lang) => lang.code == code),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: kSupportedLanguages
                  .map((lang) => RadioListTile<String>(
                        title: Text(lang.nativeName),
                        subtitle: lang.nativeName != lang.englishName ? Text(lang.englishName) : null,
                        value: lang.code,
                        activeColor: activeGreen,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
    if (selected != null && selected.code != currentCode) {
      await localeProvider.setLanguageCode(selected.code);
      if (!mounted) return;
      _toast(context.tr('settings_language_set_to', {'language': selected.nativeName}));
    }
  }

  Future<void> _showWearableDialog() async {
    final connected = _wearableConnected;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_wearable_title')),
        content: Text(
          connected
              ? context.tr('settings_wearable_connected_body')
              : context.tr('settings_wearable_disconnected_body'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common_close'))),
          FilledButton(
            onPressed: () async {
              final message = !connected
                  ? context.tr('settings_wearable_connected_toast')
                  : context.tr('settings_wearable_disconnected_toast');
              setState(() => _wearableConnected = !connected);
              await _persist('settings_wearable_connected', (!connected).toString());
              if (context.mounted) Navigator.pop(context);
              _toast(message);
            },
            child: Text(connected ? context.tr('settings_disconnect') : context.tr('settings_connect')),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Account & Data
  // ---------------------------------------------------------------------

  Future<void> _confirmRestartData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_restart_data_title')),
        content: Text(context.tr('settings_restart_data_confirm_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('common_cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE08A00)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('settings_reset')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final waterProvider = context.read<WaterIntakeProvider>();
    final weightProvider = context.read<WeightLogProvider>();
    final mealPlanProvider = context.read<MealPlanProvider>();
    setState(() => _busy = true);
    try {
      await FirestoreService().clearTrackingData();
      if (!mounted) return;
      await waterProvider.load();
      await weightProvider.load();
      final profile = widget.profile;
      if (profile != null) {
        await mealPlanProvider.submitProfileAndGenerate(profile);
      }
      if (!mounted) return;
      _toast(context.tr('settings_restart_data_success_toast'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeleteData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_delete_data_title')),
        content: Text(context.tr('settings_delete_data_confirm_body')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.tr('common_cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('settings_delete_everything')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final waterProvider = context.read<WaterIntakeProvider>();
    final weightProvider = context.read<WeightLogProvider>();
    setState(() => _busy = true);
    try {
      await FirestoreService().clearAllData();
      await NotificationService().cancelAll();
      if (!mounted) return;
      await waterProvider.load();
      await weightProvider.load();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfileInputScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ---------------------------------------------------------------------
  // Support
  // ---------------------------------------------------------------------

  Future<void> _showRatingDialog() async {
    int rating = 0;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.tr('settings_rate_us_title')),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < rating;
              return IconButton(
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFFFB300),
                  size: 28,
                ),
                onPressed: () => setDialogState(() => rating = i + 1),
              );
            }),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common_cancel'))),
            FilledButton(
              onPressed: rating == 0
                  ? null
                  : () async {
                      final message = context.tr('settings_rate_us_submit_toast', {'rating': '$rating'});
                      await _persist('settings_rating', rating.toString());
                      if (context.mounted) Navigator.pop(context);
                      _toast(message);
                    },
              child: Text(context.tr('common_submit')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showShareSheet() async {
    final shareText = context.tr('settings_share_text');
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('settings_share_app_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
              child: Text(shareText, style: const TextStyle(fontSize: 12, color: textSecondary)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: primaryDark),
                onPressed: () async {
                  final message = context.tr('settings_copied_toast');
                  await Clipboard.setData(ClipboardData(text: shareText));
                  if (context.mounted) Navigator.pop(context);
                  _toast(message);
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: Text(context.tr('settings_copy_link')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFeedbackDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings_feedback_title')),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: context.tr('settings_feedback_hint'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('common_cancel'))),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final key = 'feedback_${DateTime.now().toIso8601String()}';
              final message = context.tr('settings_feedback_thanks_toast');
              await _persist(key, text);
              if (context.mounted) Navigator.pop(context);
              _toast(message);
            },
            child: Text(context.tr('common_submit')),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyPolicySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('settings_privacy_policy_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    context.tr('settings_privacy_policy_body'),
                    style: const TextStyle(fontSize: 12, height: 1.6, color: textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Static building blocks
  // ---------------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('settings_header_title'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          context.tr('settings_header_subtitle'),
          style: const TextStyle(fontSize: 11, color: textSecondary),
        ),
      ],
    );
  }

  Widget _buildUserProfileCard() {
    final profile = widget.profile;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(color: activeGreenBg, shape: BoxShape.circle),
            child: const Icon(Icons.person, color: primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name ?? context.tr('settings_guest_name'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile != null
                      ? context.tr('settings_goal_label', {'goal': profile.goal.name.toUpperCase()})
                      : context.tr('settings_complete_profile'),
                  style: const TextStyle(fontSize: 10, color: textSecondary),
                ),
                if (_isPremium) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: activeGreenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, size: 12, color: activeGreen),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('settings_premium_badge'),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: activeGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.vertical(
                  top: index == 0 ? const Radius.circular(20) : Radius.zero,
                  bottom: isLast ? const Radius.circular(20) : Radius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, size: 18, color: item.iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontSize: 9,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.customWidget != null) ...[
                        item.customWidget!,
                        const SizedBox(width: 6),
                      ] else if (item.trailingText != null) ...[
                        Text(
                          item.trailingText!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.trailingTextColor ?? textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 62, right: 14),
                  child: Divider(height: 1, thickness: 1, color: dividerColor),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// Data Model Helper
class _SettingsItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? trailingText;
  final Color? trailingTextColor;
  final Widget? customWidget;
  final VoidCallback? onTap;

  _SettingsItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailingText,
    this.trailingTextColor,
    this.customWidget,
    this.onTap,
  });
}
