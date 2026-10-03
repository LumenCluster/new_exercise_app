import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
import 'onboarding_steps.dart' show BodyShapeStep;

// --- Shared Theme Colors ---
class GoalsColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

// --- Common Step Header ---
class GoalsStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const GoalsStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: GoalsColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: GoalsColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// --- Common Action Button ---
class GoalsActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GoalsActionButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: GoalsColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. GOALS & FOCUS INTRO STEP
// ==========================================
class GoalsIntroStep extends StatelessWidget {
  final VoidCallback onNext;

  const GoalsIntroStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: GoalsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // PART 3 badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GoalsColors.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.tr('onboarding_part3_badge'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Left-aligned title & subtitle
              Text(
                context.tr('onboarding_goals_intro_title'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: GoalsColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('onboarding_goals_intro_subtitle'),
                style: const TextStyle(
                  fontSize: 13,
                  color: GoalsColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // Illustration on the right, running off the right edge of the screen
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Transform.translate(
                    // 24 = page padding, plus a little extra so the image bleeds off-screen
                    offset: Offset(24 + screenWidth * 0.06, 0),
                    child: Image.asset(
                      'assets/two.png',
                      width: screenWidth * 0.92,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fitness_center,
                        size: 140,
                        color: GoalsColors.activeGreen,
                      ),
                    ),
                  ),
                ),
              ),

              GoalsActionButton(text: context.tr('common_continue'), onPressed: onNext),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  context.tr('onboarding_about_2_minutes'),
                  style: const TextStyle(fontSize: 11, color: GoalsColors.textSecondary),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. PRIMARY GOAL STEP
// ==========================================
class PrimaryGoalStep extends StatefulWidget {
  final Function(String goal) onNext;

  const PrimaryGoalStep({super.key, required this.onNext});

  @override
  State<PrimaryGoalStep> createState() => _PrimaryGoalStepState();
}

class _PrimaryGoalStepState extends State<PrimaryGoalStep> {
  String? _selectedGoal;

  static const List<Map<String, String>> _goals = [
    {
      'id': 'weight_loss',
      'labelKey': 'onboarding_goal_weight_loss_label',
      'subtitleKey': 'onboarding_goal_weight_loss_sub',
      'image': 'assets/weight_loss.png',
    },
    {
      'id': 'weight_gain',
      'labelKey': 'onboarding_goal_weight_gain_label',
      'subtitleKey': 'onboarding_goal_weight_gain_sub',
      'image': 'assets/weight_gain.png',
    },
    {
      'id': 'maintain_weight',
      'labelKey': 'onboarding_goal_maintain_label',
      'subtitleKey': 'onboarding_goal_maintain_sub',
      'image': 'assets/maintain.png',
    },
    {
      'id': 'muscle_gain',
      'labelKey': 'onboarding_goal_muscle_gain_label',
      'subtitleKey': 'onboarding_goal_muscle_gain_sub',
      'image': 'assets/gain.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoalsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              GoalsStepHeader(
                title: context.tr('onboarding_primary_goal_title'),
                subtitle: context.tr('onboarding_primary_goal_subtitle'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final item = _goals[index];
                    final itemId = item['id']!;
                    final itemLabel = context.tr(item['labelKey']!);
                    final itemSub = context.tr(item['subtitleKey']!);
                    final itemImage = item['image']!;
                    final isSelected = _selectedGoal == itemId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGoal = itemId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? GoalsColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? GoalsColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected ? GoalsColors.activeGreen.withValues(alpha: 0.2) : const Color(0xFFF0F0F0),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  itemImage,
                                  errorBuilder: (_, _, _) => const Icon(Icons.flag, size: 20, color: GoalsColors.primaryDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: GoalsColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      itemSub,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: GoalsColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? GoalsColors.activeGreen : Colors.white,
                                  border: isSelected ? null : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              GoalsActionButton(
                text: context.tr('common_continue'),
                onPressed: _selectedGoal != null ? () => widget.onNext(_selectedGoal!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. TARGET FOCUS AREAS STEP
// ==========================================
class TargetFocusStep extends StatefulWidget {
  final Function(List<String> areas) onNext;

  final Gender gender;

  const TargetFocusStep({super.key, required this.onNext, this.gender = Gender.female});

  @override
  State<TargetFocusStep> createState() => _TargetFocusStepState();
}

class _TargetFocusStepState extends State<TargetFocusStep> {
  final Set<String> _selectedAreas = {};

  static const List<Map<String, String>> _areas = [
    {'id': 'full_body', 'labelKey': 'onboarding_focus_full_body_label', 'subtitleKey': 'onboarding_focus_full_body_sub'},
    {'id': 'arm_shoulders', 'labelKey': 'onboarding_focus_arm_shoulders_label', 'subtitleKey': 'onboarding_focus_arm_shoulders_sub'},
    {'id': 'arms', 'labelKey': 'onboarding_focus_arms_label', 'subtitleKey': 'onboarding_focus_arms_sub'},
    {'id': 'waist', 'labelKey': 'onboarding_focus_waist_label', 'subtitleKey': 'onboarding_focus_waist_sub'},
    {'id': 'abs', 'labelKey': 'onboarding_focus_abs_label', 'subtitleKey': 'onboarding_focus_abs_sub'},
    {'id': 'glutes', 'labelKey': 'onboarding_focus_glutes_label', 'subtitleKey': 'onboarding_focus_glutes_sub'},
    {'id': 'legs', 'labelKey': 'onboarding_focus_legs_label', 'subtitleKey': 'onboarding_focus_legs_sub'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoalsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              GoalsStepHeader(
                title: context.tr('onboarding_focus_title'),
                subtitle: context.tr('onboarding_focus_subtitle'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    // Left side: Body Model Preview
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: Image.asset(
                          widget.gender == Gender.male ? 'assets/male_body.png' : 'assets/body.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.accessibility_new, size: 160, color: GoalsColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right side: Focus Area List
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: _areas.length,
                        itemBuilder: (context, index) {
                          final item = _areas[index];
                          final itemId = item['id']!;
                          final isSelected = _selectedAreas.contains(itemId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAreas.remove(itemId);
                                  } else {
                                    _selectedAreas.add(itemId);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? GoalsColors.activeBgGreen : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? GoalsColors.activeGreen : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.tr(item['labelKey']!),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: GoalsColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            context.tr(item['subtitleKey']!),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: GoalsColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? GoalsColors.activeGreen : Colors.white,
                                        border: isSelected ? null : Border.all(color: Colors.black26, width: 1),
                                      ),
                                      child: isSelected ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              GoalsActionButton(
                text: context.tr('common_continue'),
                onPressed: _selectedAreas.isNotEmpty ? () => widget.onNext(_selectedAreas.toList()) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. IMPROVEMENT GOAL STEP
// ==========================================
class ImproveGoalStep extends StatefulWidget {
  final Function(String goal) onNext;

  const ImproveGoalStep({super.key, required this.onNext});

  @override
  State<ImproveGoalStep> createState() => _ImproveGoalStepState();
}

class _ImproveGoalStepState extends State<ImproveGoalStep> {
  String? _selectedItem;

  static const List<Map<String, String>> _items = [
    {
      'id': 'strength',
      'labelKey': 'onboarding_improve_strength_label',
      'subtitleKey': 'onboarding_improve_strength_sub',
      'image': 'assets/strength.png',
    },
    {
      'id': 'tone',
      'labelKey': 'onboarding_improve_tone_label',
      'subtitleKey': 'onboarding_improve_tone_sub',
      'image': 'assets/tone.png',
    },
    {
      'id': 'stamina',
      'labelKey': 'onboarding_improve_stamina_label',
      'subtitleKey': 'onboarding_improve_stamina_sub',
      'image': 'assets/fitness.png',
    },
    {
      'id': 'flexibility',
      'labelKey': 'onboarding_improve_flexibility_label',
      'subtitleKey': 'onboarding_improve_flexibility_sub',
      'image': 'assets/mobility.png',
    },
    {
      'id': 'overall',
      'labelKey': 'onboarding_improve_overall_label',
      'subtitleKey': 'onboarding_improve_overall_sub',
      'image': 'assets/wellness.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoalsColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              GoalsStepHeader(
                title: context.tr('onboarding_improve_title'),
                subtitle: context.tr('onboarding_improve_subtitle'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final itemId = item['id']!;
                    final isSelected = _selectedItem == itemId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedItem = itemId),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? GoalsColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? GoalsColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                item['image']!,
                                width: 28,
                                height: 28,
                                errorBuilder: (_, _, _) => const Icon(Icons.bolt, color: GoalsColors.primaryDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr(item['labelKey']!),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: GoalsColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.tr(item['subtitleKey']!),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: GoalsColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? GoalsColors.activeGreen : Colors.white,
                                  border: isSelected ? null : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              GoalsActionButton(
                text: context.tr('common_next'),
                onPressed: _selectedItem != null ? () => widget.onNext(_selectedItem!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5. TARGET BODY SHAPE STEP
// ==========================================
// Same carousel, fat-level bar and body fat card as the "current body shape"
// step, with gender-specific images, but asking for the target shape.
class TargetBodyShapeStep extends StatelessWidget {
  final Function(String bodyShape, double fatPercentage) onNext;
  final Gender gender;

  const TargetBodyShapeStep({
    super.key,
    required this.onNext,
    this.gender = Gender.female,
  });

  // "22% - 25%" -> 23.5, "40%+" -> 40
  static double _fatMidpoint(String range) {
    final values = RegExp(r'\d+(\.\d+)?')
        .allMatches(range)
        .map((m) => double.parse(m.group(0)!))
        .toList();
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return BodyShapeStep(
      gender: gender,
      titleKey: 'onboarding_target_body_shape_title',
      onNext: (shape, fatRange) => onNext(shape, _fatMidpoint(fatRange)),
    );
  }
}
