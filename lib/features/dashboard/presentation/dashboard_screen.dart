import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/firestore_service.dart';
import '../../profile/domain/entities/user_profile.dart';
import '../../meal_plan/domain/entities/meal.dart';
import '../../meal_plan/presentation/providers/meal_plan_provider.dart';
import '../../exercises/domain/entities/exercise.dart';
import '../../exercises/domain/repositories/exercise_repository.dart';
import '../../tracking/presentation/providers/water_intake_provider.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../exercises/presentation/active_workout_screen.dart';
import '../../exercises/presentation/pages/exercise_detail_screen.dart';
import '../../exercises/presentation/pages/workout_plan_screen.dart';
import '../../../core/localization/app_localizations.dart';

// --- Shared Theme Colors ---
class DashboardColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const waterBlue = Color(0xFF29B6F6);
  static const waterLight = Color(0xFFE1F5FE);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedDayIndex = 0;
  UserProfile? _profile;
  bool _isLoading = true;
  final Set<int> _completedExerciseIndices = {};

  List<Exercise> _exercises = [];
  bool _exercisesLoading = true;
  String? _exercisesError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await FirestoreService().getProfile();
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _isLoading = false;
    });

    if (profile != null) {
      _loadExercises(profile);
    } else {
      setState(() => _exercisesLoading = false);
    }
  }

  Future<void> _loadExercises(UserProfile profile) async {
    setState(() {
      _exercisesLoading = true;
      _exercisesError = null;
    });
    try {
      final exercises = await context.read<ExerciseRepository>().recommendedForProfile(profile);
      if (!mounted) return;
      setState(() {
        _exercises = exercises;
        _exercisesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exercisesError = e.toString();
        _exercisesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = context.watch<MealPlanProvider>();

    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 12.0,
                bottom: 100.0, // Spacing for floating navbar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // --- Current Streak Banner ---
                  _buildStreakCard(),
                  const SizedBox(height: 16),

                  // --- Active Program Banner ---
                  _buildActiveProgramCard(),
                  const SizedBox(height: 20),

                  // --- 30-Day Workout Plan Section ---
                  _buildWorkoutPlanSection(),
                  const SizedBox(height: 20),

                  // --- Today's Workout Section ---
                  _buildTodayWorkoutSection(),
                  const SizedBox(height: 24),

                  // --- Today's Meals Section ---
                  _buildTodayMealsSection(mealPlanProvider),
                  const SizedBox(height: 24),

                  // --- Water Intake Section ---
                  _buildWaterIntakeSection(),
                  const SizedBox(height: 24),

                  // --- Weekly Activity Section ---
                  _buildWeeklyActivitySection(),
                  const SizedBox(height: 24),

                  // --- User Profile Summary Section ---
                  if (!_isLoading && _profile != null) ...[
                    _buildProfileSummarySection(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),

            // --- Floating Bottom Navigation Bar ---
            Positioned(
              left: 20,
              right: 20,
              bottom: 16,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('dashboard_greeting'),
              style: const TextStyle(
                fontSize: 12,
                color: DashboardColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _profile?.name ?? "Sarah",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DashboardColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 20),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/user_avatar.png'),
            ),
          ],
        ),
      ],
    );
  }

  // Streak Banner Widget
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: DashboardColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('dashboard_current_streak'),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: DashboardColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('dashboard_streak_progress'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('dashboard_streak_days_left'),
                  style: const TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEDC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              context.tr('dashboard_keep_it_up'),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DashboardColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  // Active Program Widget
  Widget _buildActiveProgramCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr('dashboard_day_of'),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Text(
                context.tr('dashboard_active_program'),
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('dashboard_program_name'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(context.tr('dashboard_program_duration'), style: const TextStyle(fontSize: 11, color: Colors.white70)),
              const SizedBox(width: 12),
              const Icon(Icons.local_fire_department_outlined, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(context.tr('dashboard_program_kcal'), style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.tr('dashboard_program_progress'), style: const TextStyle(fontSize: 10, color: Colors.white70)),
              const Text("40%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.40,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.activeGreen),
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _weekdayKeys = [
    'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat', 'weekday_sun',
  ];

  String _weekdayLabel(int weekday) => context.tr(_weekdayKeys[weekday - 1]);

  // 30-Day Workout Plan Section
  Widget _buildWorkoutPlanSection() {
    final workoutLabelKeys = ['workout_full_body', 'workout_abs', 'workout_upper', 'workout_hiit', 'workout_chest'];
    final today = DateTime.now();
    final days = List.generate(5, (index) {
      final date = today.add(Duration(days: index));
      return {
        'day': _weekdayLabel(date.weekday),
        'label': context.tr(workoutLabelKeys[index]),
        'completed': false,
      };
    });

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('dashboard_workout_plan_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                context.tr('dashboard_view_all'),
                style: const TextStyle(fontSize: 12, color: DashboardColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            final item = days[index];
            final isCompleted = item['completed'] == true;
            final isActive = index == _selectedDayIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? DashboardColors.primaryDark
                        : isActive
                        ? DashboardColors.activeBgGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? DashboardColors.activeGreen : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item['day'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isCompleted ? Colors.white70 : DashboardColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? DashboardColors.activeGreen : Colors.transparent,
                          border: isCompleted ? null : Border.all(color: Colors.black26, width: 1.5),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : DashboardColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openWorkoutPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPlanScreen(
          profile: _profile,
          repository: context.read<ExerciseRepository>(),
        ),
      ),
    );
  }

  void _openExerciseDetail(Exercise exercise) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)),
    );
  }

  // Today's Workout Section
  Widget _buildTodayWorkoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('dashboard_todays_workout'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
              ),
              GestureDetector(
                onTap: _openWorkoutPlan,
                child: Text(
                  context.tr('dashboard_adjust_plan'),
                  style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildWorkoutSubtitle(),
          const SizedBox(height: 12),
          _buildWorkoutBody(),
        ],
      ),
    );
  }

  Widget _buildWorkoutSubtitle() {
    if (!_exercisesLoading && _exercisesError == null) {
      final goalLabel = _profile?.primaryGoal != null
          ? _profile!.primaryGoal!.replaceAll('_', ' ')
          : context.tr('dashboard_your_goals');
      return Text(
        context.tr('dashboard_exercises_personalized_for', {
          'count': '${_exercises.length}',
          'goal': goalLabel,
        }),
        style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
      );
    }
    return Text(
      context.tr('dashboard_personalized_for_your_goals'),
      style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
    );
  }

  Widget _buildWorkoutBody() {
    if (_exercisesLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: DashboardColors.primaryDark),
        ),
      );
    }
    if (_exercisesError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              context.tr('dashboard_exercises_load_error'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                if (_profile != null) _loadExercises(_profile!);
              },
              child: Text(context.tr('common_retry')),
            ),
          ],
        ),
      );
    }
    if (_exercises.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          context.tr('dashboard_no_exercises_found'),
          style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
        ),
      );
    }
    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _exercises.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _buildExerciseTile(_exercises[index], index),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DashboardColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(context.tr('dashboard_start_todays_session'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTile(Exercise exercise, int index) {
    final isDone = _completedExerciseIndices.contains(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isDone) {
            _completedExerciseIndices.remove(index);
          } else {
            _completedExerciseIndices.add(index);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDone ? DashboardColors.activeBgGreen : DashboardColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openExerciseDetail(exercise),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildExerciseThumbnail(exercise.gifAsset),
                      if (exercise.videoStoragePath != null)
                        Container(
                          decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(Icons.play_arrow_rounded, size: 14, color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${exercise.prescriptionLabel} · ${exercise.muscleGroups.join(', ')}",
                    style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? DashboardColors.activeGreen : Colors.white,
                border: isDone ? null : Border.all(color: Colors.black26, width: 1.5),
              ),
              child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseThumbnail(String? gifAsset) {
    if (gifAsset == null) {
      return Container(
        color: Colors.white,
        child: const Icon(Icons.self_improvement, size: 20, color: DashboardColors.primaryDark),
      );
    }
    return Image.asset(
      gifAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.white,
        child: const Icon(Icons.self_improvement, size: 20, color: DashboardColors.primaryDark),
      ),
    );
  }

  // Today's Meals Section
  Widget _buildTodayMealsSection(MealPlanProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('dashboard_todays_meals'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                context.tr('dashboard_track_meal'),
                style: const TextStyle(fontSize: 12, color: DashboardColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMealsBody(provider),
      ],
    );
  }

  Widget _buildMealsBody(MealPlanProvider provider) {
    switch (provider.planState) {
      case LoadState.loading:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(color: DashboardColors.primaryDark),
                const SizedBox(height: 12),
                Text(
                  context.tr('dashboard_designing_meals'),
                  style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                ),
              ],
            ),
          ),
        );
      case LoadState.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                provider.errorMessage ?? context.tr('dashboard_meals_generate_error'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (provider.profile != null) {
                    provider.submitProfileAndGenerate(provider.profile!);
                  }
                },
                child: Text(context.tr('common_retry')),
              ),
            ],
          ),
        );
      case LoadState.success:
        if (provider.meals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              context.tr('dashboard_no_meals_generated'),
              style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.meals.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _DashboardMealTile(
            meal: provider.meals[index],
            index: index,
          ),
        );
      case LoadState.idle:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            context.tr('dashboard_no_meal_plan_yet'),
            style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
          ),
        );
    }
  }

  // --- Water Intake Component — backed by WaterIntakeProvider so it's ---
  // --- shared with (and persisted for) the Report screen.            ---
  Widget _buildWaterIntakeSection() {
    return Consumer<WaterIntakeProvider>(
      builder: (context, water, _) {
        final target = water.targetGlasses;
        final glasses = water.glasses;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DashboardColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('dashboard_water_intake'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: DashboardColors.textPrimary,
                    ),
                  ),
                  Text(
                    context.tr('dashboard_glasses_count', {'glasses': '$glasses', 'target': '$target'}),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: DashboardColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Water Glasses Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(target, (index) {
                  final isFilled = index < glasses;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => water.setGlasses(index + 1),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 38,
                        decoration: BoxDecoration(
                          color: isFilled ? DashboardColors.waterBlue : DashboardColors.waterLight,
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: Icon(
                          Icons.local_drink_rounded,
                          size: 18,
                          color: isFilled ? Colors.white : DashboardColors.waterBlue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Add / Remove Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('dashboard_ml_consumed', {'ml': '${glasses * 250}'}),
                    style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: water.addGlass,
                    child: Text(
                      context.tr('dashboard_add_glass'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: DashboardColors.waterBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Weekly Activity Section
  Widget _buildWeeklyActivitySection() {
    const heights = [35.0, 50.0, 25.0, 45.0, 60.0, 15.0, 20.0];
    final today = DateTime.now();
    final activityData = List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return {
        'day': _weekdayLabel(date.weekday),
        'height': heights[index],
        'highlight': index == 0,
      };
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('dashboard_weekly_activity'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('dashboard_avg_kcal_burn'),
            style: const TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activityData.map((item) {
                final isHighlight = item['highlight'] == true;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: (item['height'] as double),
                      decoration: BoxDecoration(
                        color: isHighlight ? DashboardColors.activeGreen : const Color(0xFFE2E6E2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['day'].toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                        color: isHighlight ? DashboardColors.textPrimary : DashboardColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // User Profile Summary Widget
  Widget _buildProfileSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('dashboard_profile_summary_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: DashboardColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(context.tr('label_age'), "${_profile!.age} years"),
          _buildSummaryItem(context.tr('label_height'), "${_profile!.heightCm} cm"),
          _buildSummaryItem(context.tr('label_weight'), "${_profile!.currentWeightKg} kg"),
          _buildSummaryItem(context.tr('label_activity'), _profile!.activityLevel.name.toUpperCase()),
          if (_profile!.fitnessLevel != null)
            _buildSummaryItem(context.tr('label_fitness_level'), _profile!.fitnessLevel!),
          if (_profile!.primaryGoal != null)
            _buildSummaryItem(context.tr('label_primary_goal'), _profile!.primaryGoal!.replaceAll('_', ' ').toUpperCase()),
          if (_profile!.allergies.isNotEmpty)
            _buildSummaryItem(context.tr('label_allergies'), _profile!.allergies.join(', ')),
          if (_profile!.considerations.isNotEmpty)
            _buildSummaryItem(context.tr('label_considerations'), _profile!.considerations.join(', ')),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DashboardColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: DashboardColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return AppBottomNavBar(currentTab: AppTab.home, profile: _profile);
  }
}

String _dashboardMealCategoryLabel(BuildContext context, int index) {
  const keys = ['meal_breakfast', 'meal_lunch', 'meal_dinner'];
  if (index < keys.length) return context.tr(keys[index]);
  return context.tr('meal_snack_n', {'n': '${index - keys.length + 1}'});
}

class _DashboardMealTile extends StatefulWidget {
  final Meal meal;
  final int index;

  const _DashboardMealTile({required this.meal, required this.index});

  @override
  State<_DashboardMealTile> createState() => _DashboardMealTileState();
}

class _DashboardMealTileState extends State<_DashboardMealTile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MealPlanProvider>().ensureImageForMeal(widget.meal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();
    final imageState = provider.imageStates[widget.meal.cacheKey] ?? LoadState.idle;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 44,
              height: 44,
              child: _buildImage(context, imageState),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dashboardMealCategoryLabel(context, widget.index),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: DashboardColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.meal.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  "${widget.meal.calories} kcal",
                  style: const TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: DashboardColors.primaryDark, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context, LoadState state) {
    if (widget.meal.imagePath != null) {
      return Image.file(File(widget.meal.imagePath!), fit: BoxFit.cover);
    }
    if (state == LoadState.error) {
      return GestureDetector(
        onTap: () => context.read<MealPlanProvider>().ensureImageForMeal(widget.meal),
        child: Container(
          color: DashboardColors.background,
          child: const Icon(Icons.refresh, size: 18, color: DashboardColors.textSecondary),
        ),
      );
    }
    return Container(
      color: DashboardColors.background,
      child: const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}