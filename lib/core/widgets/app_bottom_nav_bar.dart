 import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/domain/entities/user_profile.dart';
import '../../features/exercises/domain/repositories/exercise_repository.dart';
import '../../features/exercises/presentation/pages/exercise_library_screen.dart';
import '../../features/exercises/presentation/pages/workout_plan_screen.dart';
import '../../features/report/presentation/pages/report_screen.dart';
import '../../features/profile/presentation/profile_settings_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../localization/app_localizations.dart';

class _NavColors {
  static const primaryDark = Color(0xFF1B2A26);
  static const cardWhite = Colors.white;
  static const textSecondary = Color(0xFF757575);
}

enum AppTab { home, discover, plan, report, profile }

/// The floating pill bottom nav shared by every top-level screen, so
/// tapping any tab from anywhere in the app reaches that screen.
class AppBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final UserProfile? profile;

  const AppBottomNavBar({super.key, required this.currentTab, required this.profile});

  void _navigate(BuildContext context, AppTab tab) {
    if (tab == currentTab) return;

    final Widget screen;
    switch (tab) {
      case AppTab.home:
        screen = const DashboardScreen();
        break;
      case AppTab.discover:
        screen = ExerciseLibraryScreen(repository: context.read<ExerciseRepository>(), profile: profile);
        break;
      case AppTab.plan:
        screen = WorkoutPlanScreen(profile: profile);
        break;
      case AppTab.report:
        screen = ReportScreen(profile: profile);
        break;
      case AppTab.profile:
        screen = ProfileSettingsScreen(profile: profile);
        break;
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _NavColors.cardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, AppTab.home, Icons.home_filled, context.tr('nav_home')),
          _item(context, AppTab.discover, Icons.explore_outlined, context.tr('nav_discover')),
          _item(context, AppTab.plan, Icons.fitness_center_outlined, context.tr('nav_plan')),
          _item(context, AppTab.report, Icons.bar_chart_rounded, context.tr('nav_report')),
          _item(context, AppTab.profile, Icons.person_outline, context.tr('nav_profile')),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, AppTab tab, IconData icon, String label) {
    final isSelected = tab == currentTab;

    return GestureDetector(
      onTap: () => _navigate(context, tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _NavColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : _NavColors.textSecondary),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
