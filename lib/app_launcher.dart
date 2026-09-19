import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/firestore_service.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
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
  Object? _error;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
  }

  Future<void> _checkExistingProfile() async {
    try {
      final profile = await FirestoreService().getProfile();
      if (!mounted) return;

      if (profile != null) {
        context.read<MealPlanProvider>().submitProfileAndGenerate(profile);
      }

      setState(() {
        _hasProfile = profile != null;
        _checking = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9F8F3),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F8F3),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Could not connect: $_error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _checking = true;
                      _error = null;
                    });
                    _checkExistingProfile();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _hasProfile ? const DashboardScreen() : const ProfileInputScreen();
  }
}
