import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/database/firestore_service.dart';
import '../../profile/domain/entities/user_profile.dart';
import '../../meal_plan/domain/entities/meal.dart';
import '../../meal_plan/presentation/providers/meal_plan_provider.dart';
import '../../tracking/presentation/providers/water_intake_provider.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../exercises/presentation/pages/workout_plan_screen.dart';
import '../../../core/localization/app_localizations.dart';
import 'widgets/storage_videos_section.dart';

// --- Shared Theme Colors ---
class DashboardColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const programDark = Color(0xFF14261C);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const waterBlue = Color(0xFF29B6F6);
  static const waterLight = Color(0xFFE1F5FE);
  static const emptyGrey = Color(0xFFECECEF);
  static const barIdle = Color(0xFFE3EAF2);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserProfile? _profile;
  bool _isLoading = true;

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

                  // --- Today's Workout Section (goal videos from Firebase Storage) ---
                  // Waits for the profile so it lists the user's goal folder
                  // directly instead of loading a fallback folder first.
                  if (!_isLoading) ...[
                    StorageVideosSection(
                      primaryGoal: _profile?.primaryGoal,
                      titleKey: 'dashboard_todays_workout',
                      trailing: GestureDetector(
                        onTap: _openWorkoutPlan,
                        child: Text(
                          context.tr('dashboard_adjust_plan'),
                          style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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
        color: DashboardColors.programDark,
        borderRadius: BorderRadius.circular(22),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.tr('dashboard_day_of'),
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: DashboardColors.primaryDark),
                ),
              ),
              Text(
                context.tr('dashboard_active_program'),
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('dashboard_program_name'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time_rounded, size: 14, color: DashboardColors.activeGreen),
              const SizedBox(width: 4),
              Text(
                context.tr('dashboard_program_duration'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DashboardColors.activeGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.local_fire_department_outlined, size: 14, color: DashboardColors.activeGreen),
              const SizedBox(width: 4),
              Text(
                context.tr('dashboard_program_kcal'),
                style: const TextStyle(fontSize: 11, color: DashboardColors.activeGreen),
              ),
            ],
          ),
          const SizedBox(height: 18),
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

  void _openWorkoutPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutPlanScreen(
          profile: _profile,
        ),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 30,
                        decoration: BoxDecoration(
                          color: isFilled ? DashboardColors.waterBlue : DashboardColors.emptyGrey,
                          borderRadius: BorderRadius.circular(15),
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
    const heights = [70.0, 95.0, 45.0, 88.0, 100.0, 6.0, 6.0];
    final todayWeekday = DateTime.now().weekday;
    // Mon → Sun, with today's bar highlighted.
    final activityData = List.generate(7, (index) {
      return {
        'day': _weekdayLabel(index + 1),
        'height': heights[index],
        'highlight': index + 1 == todayWeekday,
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
          const SizedBox(height: 20),
          SizedBox(
            height: 126,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activityData.map((item) {
                final isHighlight = item['highlight'] == true;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 10,
                      height: (item['height'] as double),
                      decoration: BoxDecoration(
                        color: isHighlight ? DashboardColors.activeGreen : DashboardColors.barIdle,
                        borderRadius: BorderRadius.circular(5),
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 52,
              height: 52,
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
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: DashboardColors.background,
              side: const BorderSide(color: Colors.black12),
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.chevron_right_rounded, color: DashboardColors.primaryDark, size: 20),
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