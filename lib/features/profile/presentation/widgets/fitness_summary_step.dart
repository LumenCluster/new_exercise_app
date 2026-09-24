import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import 'onboarding_components.dart';

class FitnessSummaryStep extends StatelessWidget {
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final String? fitnessLevel;
  final String? bodyShape;
  final VoidCallback onContinue;
  final Function(int) onEdit;

  const FitnessSummaryStep({
    super.key,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.fitnessLevel,
    required this.bodyShape,
    required this.onContinue,
    required this.onEdit,
  });

  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String bmiStatus(BuildContext context) {
    final val = bmi;
    if (val < 18.5) return context.tr('onboarding_bmi_underweight');
    if (val < 25.0) return context.tr('onboarding_bmi_healthy');
    if (val < 30.0) return context.tr('onboarding_bmi_overweight');
    return context.tr('onboarding_bmi_obese');
  }

  Color get bmiColor {
    final val = bmi;
    if (val < 18.5) return Colors.green;
    if (val < 25.0) return Colors.yellow.shade700;
    if (val < 30.0) return Colors.orange;
    return Colors.red;
  }

  String activityLabel(BuildContext context) {
    switch (activityLevel) {
      case ActivityLevel.sedentary:
        return context.tr('onboarding_activity_sedentary');
      case ActivityLevel.light:
        return context.tr('onboarding_activity_light');
      case ActivityLevel.moderate:
        return context.tr('onboarding_activity_moderate');
      case ActivityLevel.active:
        return context.tr('onboarding_activity_active');
      case ActivityLevel.veryActive:
        return context.tr('onboarding_activity_very_active');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StepHeader(
                title: context.tr('onboarding_fitness_summary_title'),
                subtitle: context.tr('onboarding_fitness_summary_subtitle'),
              ),
              const SizedBox(height: 24),

              // BMI Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('onboarding_bmi_score_label'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bmi.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  bmiStatus(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: bmiColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Placeholder Image for Scales
                          Container(
                            width: 120,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.scale, size: 48, color: Colors.black12),
                          ),
                        ],
                      ),
                    ),

                    // BMI Scale
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.green,
                                      Colors.yellow,
                                      Colors.orange,
                                      Colors.red,
                                    ],
                                  ),
                                ),
                              ),
                              // Marker
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  double position = (bmi - 15) / (35 - 15);
                                  position = position.clamp(0.0, 1.0);
                                  return Align(
                                    alignment: Alignment(position * 2 - 1, 0),
                                    child: Transform.translate(
                                      offset: const Offset(0, -12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.arrow_drop_down, size: 20),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.black, width: 2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(context.tr('onboarding_bmi_range_under'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                              Text(context.tr('onboarding_bmi_range_mid1'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                              Text(context.tr('onboarding_bmi_range_mid2'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                              Text(context.tr('onboarding_bmi_range_over'), style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Summary Items
              _SummaryItem(
                icon: Icons.person_outline,
                label: context.tr('onboarding_label_lifestyle'),
                value: activityLabel(context),
                onEdit: () => onEdit(7), // Activity Level Step index
              ),
              const Divider(height: 1),
              _SummaryItem(
                icon: Icons.fitness_center,
                label: context.tr('onboarding_label_fitness_level'),
                value: fitnessLevel ?? context.tr('onboarding_default_beginner'),
                onEdit: () => onEdit(10), // Fitness Level Step index
              ),
              const Divider(height: 1),
              _SummaryItem(
                icon: Icons.accessibility_new,
                label: context.tr('onboarding_label_body_type'),
                value: bodyShape ?? context.tr('onboarding_default_average'),
                onEdit: () => onEdit(6), // Body Shape Step index
              ),

              const SizedBox(height: 32),

              // Info box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEBF5DB),
                      child: Icon(Icons.info_outline, color: AppColors.accentGreen),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bmi < 25 ? context.tr('onboarding_bmi_good_title') : context.tr('onboarding_bmi_over_title'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bmi < 25
                              ? context.tr('onboarding_bmi_good_body')
                              : context.tr('onboarding_bmi_over_body'),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              OnboardingButton(
                text: context.tr('onboarding_continue_part2'),
                onPressed: onContinue,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.accentGreen),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
