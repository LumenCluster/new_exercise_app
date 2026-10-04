import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/firestore_service.dart';
import '../localization/app_localizations.dart';

/// Some Android brands' battery savers stop scheduled reminders unless the
/// user allows the app to run in the background. This asks them once, and
/// backs the "Reminders not arriving?" tip on the Reminders screen.
class BackgroundActivity {
  static const _channel = MethodChannel('noorishhub/background_activity');
  static const _promptShownKey = 'reminders_background_prompt_shown';

  /// Brands known to block alarms/notifications of apps in the background.
  static const _restrictiveBrands = {
    'xiaomi', 'redmi', 'poco', 'oppo', 'realme', 'oneplus', 'vivo', 'iqoo', 'huawei', 'honor',
    'samsung', 'meizu', 'asus', 'tecno', 'infinix', 'itel', 'lenovo', 'motorola', 'nokia',
  };

  /// Whether this phone likely needs the user's help for reliable reminders.
  static Future<bool> isRecommended() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final status = await _channel.invokeMapMethod<String, dynamic>('status');
      if (status == null) return false;
      final brand = status['manufacturer'] as String? ?? '';
      final exempt = status['ignoringBatteryOptimizations'] as bool? ?? false;
      return !exempt && _restrictiveBrands.contains(brand);
    } catch (_) {
      return false;
    }
  }

  /// Opens the brand's auto-start screen, or the app's settings page.
  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod<bool>('openSettings');
    } catch (_) {
      // Nothing to open on this platform.
    }
  }

  /// Shows the explanation dialog once per user, if this phone needs it.
  static Future<void> maybePrompt(BuildContext context) async {
    if (!await isRecommended()) return;
    final db = FirestoreService();
    if (await db.getCacheValue(_promptShownKey) == 'true') return;
    if (!context.mounted) return;
    await db.setCacheValue(_promptShownKey, 'true');
    if (!context.mounted) return;

    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF558B2F)),
        title: Text(context.tr('reminders_background_title')),
        content: Text(context.tr('reminders_background_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('reminders_background_later')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF13221E)),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('reminders_background_allow')),
          ),
        ],
      ),
    );
    if (open == true) await openSettings();
  }
}
