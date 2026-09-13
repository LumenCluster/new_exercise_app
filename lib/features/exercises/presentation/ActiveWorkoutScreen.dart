import 'package:flutter/material.dart';
import 'package:untitled/core/localization/app_localizations.dart';

// --- Colors ---
class AppColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeGreenBg = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);
}

// =============================================================================
// 1. ACTIVE WORKOUT SCREEN (Left Image)
// =============================================================================
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildActiveExerciseCard(),
                    const SizedBox(height: 20),
                    Text(
                      context.tr('exercises_up_next'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildUpNextTile(
                      context.tr('exercise_name_romanian_deadlifts'),
                      '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')}',
                    ),
                    const SizedBox(height: 10),
                    _buildUpNextTile(
                      context.tr('exercise_name_shoulder_press'),
                      '3 ${context.tr('common_sets')} • 10 ${context.tr('common_reps')}',
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
        ),
        Column(
          children: [
            Text(
              context.tr('dashboard_program_name'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: const [
                Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text(
                  "12:34",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.pause, size: 18, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('exercises_progress_completed', {'done': '3', 'total': '5'}),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            const Text(
              "60%",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.activeGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: const LinearProgressIndicator(
            value: 0.6,
            minHeight: 6,
            backgroundColor: Color(0xFFE2E6E2),
            color: AppColors.activeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveExerciseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.fitness_center, size: 40, color: Colors.black38),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr('exercises_active_badge'),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('exercise_name_leg_press'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              children: [
                TextSpan(text: '${context.tr('exercises_set_prefix')} '),
                TextSpan(
                  text: '2 ${context.tr('exercises_of')} 3',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const TextSpan(text: " - "),
                TextSpan(
                  text: '12 ${context.tr('common_reps')}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Target Rest Time Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.activeGreenBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "45s",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('exercises_target_rest_time'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('exercises_rest_starts_hint'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fitness_center, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutCompleteScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('exercises_complete_set'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              context.tr('exercises_skip_exercise'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. WORKOUT COMPLETE SCREEN (Right Image)
// =============================================================================
class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Trophy Icon Container
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F3CE),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.activeGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('exercises_workout_complete_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        context.tr('exercises_workout_complete_body', {'program': context.tr('dashboard_program_name')}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 Grid Stats
                    Row(
                      children: [
                        Expanded(child: _buildStatTile(context.tr('exercises_total_duration'), "42m 15s", Icons.timer_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatTile(context.tr('exercises_calories_burned'), "320 kcal", Icons.local_fire_department_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatTile(context.tr('exercises_sets_completed'), context.tr('exercises_fraction', {'a': '15', 'b': '15'}), Icons.assignment_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatTile(context.tr('exercises_total_reps'), '168 ${context.tr('common_reps')}', Icons.refresh_rounded, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Completed Exercises Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('exercises_completed_exercises_title'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          context.tr('exercises_count_of_count', {'a': '5', 'b': '5'}),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.activeGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCompletedExerciseTile(context.tr('exercise_name_bench_press'), '3 ${context.tr('common_sets')} • 10 ${context.tr('common_reps')} • 135 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_squats'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 185 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_leg_press'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 270 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_romanian_deadlifts'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 155 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_shoulder_press'), '3 ${context.tr('common_sets')} • 10 ${context.tr('common_reps')} • 95 lbs'),
                  ],
                ),
              ),
            ),
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color iconBgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedExerciseTile(String title, String details) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fitness_center, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.activeGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Text(
                context.tr('common_done'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              context.tr('exercises_share_summary'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}