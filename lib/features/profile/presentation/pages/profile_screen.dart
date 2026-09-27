import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../domain/entities/user_profile.dart';

class _ProfileColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

/// Read-only summary of the signed-in profile, reachable from the
/// "Profile" tab on every screen's bottom nav bar.
class ProfileScreen extends StatelessWidget {
  final UserProfile? profile;

  const ProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  if (profile == null)
                    _buildEmptyState(context)
                  else
                    _buildSummaryCard(context, profile!),
                ],
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: AppBottomNavBar(currentTab: AppTab.profile, profile: profile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _ProfileColors.textPrimary),
        ),
        const SizedBox(width: 8),
        Text(
          context.tr('profile_summary_title'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ProfileColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ProfileColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Text(
        context.tr('profile_summary_empty'),
        style: const TextStyle(fontSize: 12, color: _ProfileColors.textSecondary),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, UserProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _ProfileColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: _ProfileColors.background,
                child: Icon(Icons.person, size: 28, color: _ProfileColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name ?? context.tr('profile_summary_default_name'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ProfileColors.textPrimary),
                    ),
                    Text(
                      profile.country,
                      style: const TextStyle(fontSize: 11, color: _ProfileColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(context.tr('label_age'), "${profile.age} years"),
          _buildSummaryItem(context.tr('label_height'), "${profile.heightCm} cm"),
          _buildSummaryItem(context.tr('label_weight'), "${profile.currentWeightKg} kg"),
          if (profile.targetWeightKg != null)
            _buildSummaryItem(context.tr('label_target_weight'), "${profile.targetWeightKg} kg"),
          _buildSummaryItem(context.tr('label_goal'), profile.goal.name.toUpperCase()),
          _buildSummaryItem(context.tr('label_activity'), profile.activityLevel.name.toUpperCase()),
          if (profile.fitnessLevel != null)
            _buildSummaryItem(context.tr('label_fitness_level'), profile.fitnessLevel!),
          if (profile.workoutDaysPerWeek != null)
            _buildSummaryItem(context.tr('label_workout_days_per_week'), "${profile.workoutDaysPerWeek}"),
          _buildSummaryItem(context.tr('label_eating_preference'), profile.eatingPreference.name.toUpperCase()),
          _buildSummaryItem(context.tr('label_meals_per_day'), "${profile.mealsPerDay}"),
          if (profile.primaryGoal != null)
            _buildSummaryItem(context.tr('label_primary_goal'), profile.primaryGoal!.replaceAll('_', ' ').toUpperCase()),
          if (profile.allergies.isNotEmpty)
            _buildSummaryItem(context.tr('label_allergies'), profile.allergies.join(', ')),
          if (profile.considerations.isNotEmpty)
            _buildSummaryItem(context.tr('label_considerations'), profile.considerations.join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _ProfileColors.textSecondary)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ProfileColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
