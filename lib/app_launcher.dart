import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/database_helper.dart';
import 'features/dashboard/presentation/DashboardScreen.dart';
import 'features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'features/profile/presentation/pages/profile_input_screen.dart';

/// Decides whether to show onboarding or the dashboard on app start,
/// based on whether a profile has already been saved from a previous session.
class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  bool _checking = true;
  bool _hasProfile = false;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    final profile = await DatabaseHelper().getProfile();
    if (!mounted) return;

    if (profile != null) {
      context.read<MealPlanProvider>().submitProfileAndGenerate(profile);
    }

    setState(() {
      _hasProfile = profile != null;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F8F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _hasProfile ? const DashboardScreen() : const ProfileInputScreen();
  }
}
