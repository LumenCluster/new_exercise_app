import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../meal_plan/domain/entities/meal.dart';
import '../../../meal_plan/presentation/providers/meal_plan_provider.dart' show LoadState;
import '../../../meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import '../../../tracking/presentation/providers/workout_progress_provider.dart';
import '../../../meal_plan/presentation/pages/shopping_list_screen.dart';
import '../../../meal_plan/presentation/pages/meal_detail_screen.dart';
import '../../../coach/presentation/pages/coach_chat_screen.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/datasources/goal_video_remote_data_source.dart';
import '../../domain/entities/workout_video.dart';
import '../active_workout_screen.dart';

class _PlanColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const cardLightBg = Color(0xFFEFEFE9);
}

/// Full-screen view of "Your Plan" matching the design layout.
class WorkoutPlanScreen extends StatefulWidget {
  final UserProfile? profile;

  const WorkoutPlanScreen({
    super.key,
    required this.profile,
  });

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  static const _weekdayAbbrevKeys = [
    'weekday_sun', 'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat',
  ];

  String _weekdayAbbrev(int weekday) => context.tr(_weekdayAbbrevKeys[weekday % 7]).toUpperCase();

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late final List<DateTime> _planDays;
  int _selectedDayIndex = 0; // Default selected day: today

  List<WorkoutVideo> _videos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _planDays = List.generate(5, (i) => DateTime(today.year, today.month, today.day + i));
    _loadVideos();
    _ensureMealsForSelectedDay();
  }

  void _ensureMealsForSelectedDay() {
    final profile = widget.profile;
    if (profile == null) return;
    context.read<WeeklyMealPlanProvider>().ensureMealsForDay(profile, _planDays[_selectedDayIndex]);
  }

  void _selectDay(int index) {
    setState(() => _selectedDayIndex = index);
    _ensureMealsForSelectedDay();
  }

  String _formatDate(DateTime date) => '${_monthLabels[date.month - 1]} ${date.day}';

  /// Loads the exercise videos for the user's onboarding goal from Firebase
  /// Storage (the same workout the dashboard shows).
  Future<void> _loadVideos() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final videos = await GoalVideoRemoteDataSource.fetch(widget.profile?.primaryGoal);
      if (!mounted) return;
      setState(() {
        _videos = videos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Opens the active workout with every goal video, starting at [index].
  void _startWorkout(int index) {
    if (_videos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          videos: _videos,
          startIndex: index,
          title: context.tr(GoalVideoRemoteDataSource.labelKeyFor(widget.profile?.primaryGoal)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PlanColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: 100, // Space for floating nav bar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Custom Header ---
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // --- Top Coach Cards (Fitness & Nutrition Coach) ---
                  _buildCoachCards(),
                  const SizedBox(height: 20),

                  // --- This Week's Plan Selector ---
                  _buildWeeklyPlanHeader(),
                  const SizedBox(height: 12),
                  _buildWeeklyDaySelector(),
                  const SizedBox(height: 16),

                  // --- Macronutrients / Calories Overview Banner ---
                  _buildNutrientSummaryCard(),
                  const SizedBox(height: 20),

                  // --- Meals Horizontal Scroll Section ---
                  _buildTodayMealsSection(),
                  const SizedBox(height: 16),

                  // --- Shopping List Banner ---
                  _buildShoppingListCard(),
                  const SizedBox(height: 20),

                  // --- Workout Plan Horizontal Cards Section ---
                  _buildWorkoutPlanSection(),
                  const SizedBox(height: 12),

                  // --- Built-in Rest Days Banner ---
                  _buildRestDaysCard(),
                  const SizedBox(height: 20),

                  // --- Plan Progress Section ---
                  _buildPlanProgressCard(),
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

  // Custom Header Widget
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _PlanColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('exercises_your_plan_title'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _PlanColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 26.0),
          child: Text(
            context.tr('exercises_your_plan_subtitle'),
            style: const TextStyle(
              fontSize: 11,
              color: _PlanColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _fitnessSystemPrompt() {
    final profile = widget.profile;
    final profileContext = profile == null
        ? 'The user has not completed their profile yet.'
        : 'Age ${profile.age}, fitness level ${profile.fitnessLevel ?? 'unspecified'}, '
            'goal ${profile.goal.name}, activity level ${profile.activityLevel.name}, '
            'workout days/week ${profile.workoutDaysPerWeek ?? 'unspecified'}.';
    return 'You are an encouraging, knowledgeable AI fitness coach inside a fitness app. '
        'Give concise, practical, safe workout and exercise advice tailored to the user below. '
        'Keep replies short (2-4 sentences) unless the user asks for detail. '
        "Never diagnose injuries or medical conditions — recommend seeing a professional for those.\n\n"
        'User context: $profileContext';
  }

  String _nutritionSystemPrompt() {
    final profile = widget.profile;
    final profileContext = profile == null
        ? 'The user has not completed their profile yet.'
        : 'Country ${profile.country}, eating preference ${profile.eatingPreference.name}, '
            'allergies ${profile.allergies.isEmpty ? 'none' : profile.allergies.join(', ')}, '
            'goal ${profile.goal.name}, meals/day ${profile.mealsPerDay}.';
    return 'You are a friendly, knowledgeable AI nutrition coach inside a fitness app. '
        'Give concise, practical nutrition and meal advice tailored to the user below, '
        'and strictly respect their allergies and eating preference. '
        'Keep replies short (2-4 sentences) unless the user asks for detail. '
        "Never diagnose medical conditions — recommend seeing a professional for those.\n\n"
        'User context: $profileContext';
  }

  void _openCoachChat({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String systemPrompt,
    required String greeting,
    List<String> suggestions = const [],
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachChatScreen(
          title: title,
          subtitle: subtitle,
          icon: icon,
          accentColor: accentColor,
          systemPrompt: systemPrompt,
          greeting: greeting,
          suggestions: suggestions,
        ),
      ),
    );
  }

  // Coach Cards (Fitness Coach & AI Nutrition Coach)
  Widget _buildCoachCards() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCoachCard(
            title: context.tr('exercises_fitness_coach_title'),
            description: context.tr('exercises_fitness_coach_description'),
            imageAsset: "assets/coach.png",
            bgColor: const Color(0xFFE8F2E2),
            onChatTap: () => _openCoachChat(
              title: context.tr('exercises_fitness_coach_title'),
              subtitle: context.tr('exercises_coach_subtitle_always_available'),
              icon: Icons.fitness_center_rounded,
              accentColor: _PlanColors.activeGreen,
              systemPrompt: _fitnessSystemPrompt(),
              greeting: context.tr('exercises_fitness_coach_greeting'),
              suggestions: [
                context.tr('coach_suggest_stretch'),
                context.tr('coach_suggest_recovery'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildCoachCard(
            title: context.tr('exercises_nutrition_coach_title'),
            description: context.tr('exercises_nutrition_coach_description'),
            imageAsset: "assets/ai_nutrition.png",
            bgColor: const Color(0xFFE8F2E2),
            onChatTap: () => _openCoachChat(
              title: context.tr('exercises_nutrition_coach_short_title'),
              subtitle: context.tr('exercises_coach_subtitle_always_available'),
              icon: Icons.eco_rounded,
              accentColor: const Color(0xFF6B8E23),
              systemPrompt: _nutritionSystemPrompt(),
              greeting: context.tr('exercises_nutrition_coach_greeting'),
              suggestions: [
                context.tr('coach_suggest_swap_meal'),
                context.tr('coach_suggest_protein_snack'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachCard({
    required String title,
    required String description,
    required String imageAsset,
    required Color bgColor,
    required VoidCallback onChatTap,
  }) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [bgColor, Color.lerp(bgColor, Colors.white, 0.5)!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD3E6C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Coach cut-out image anchored to the bottom-right edge
          Positioned(
            right: 4,
            bottom: 0,
            top: 6,
            child: Image.asset(
              imageAsset,
              width: 120,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const SizedBox(
                width: 120,
                child: Icon(Icons.person, color: _PlanColors.primaryDark, size: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 130, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _PlanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _PlanColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Material(
                  color: _PlanColors.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onChatTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.tr('exercises_chat_now'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 13),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Weekly Plan Header
  Widget _buildWeeklyPlanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('exercises_this_weeks_plan', {
            'start': _formatDate(_planDays.first),
            'end': _formatDate(_planDays.last),
          }),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _PlanColors.textPrimary,
            height: 1.2,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Text(
            context.tr('exercises_view_all'),
            style: const TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // Horizontal Day Bar Widget
  Widget _buildWeeklyDaySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_planDays.length, (index) {
        final date = _planDays[index];
        final isToday = index == 0;
        final isSelected = index == _selectedDayIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () => _selectDay(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _PlanColors.activeBgGreen : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _PlanColors.activeGreen : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _weekdayAbbrev(date.weekday),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _PlanColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday ? _PlanColors.activeGreen : Colors.transparent,
                      border: isToday ? null : Border.all(color: Colors.black12, width: 1.5),
                    ),
                    child: isToday
                        ? const Icon(Icons.today, size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: _PlanColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Macro/Calorie Summary Horizontal Cards — totals for the selected day's meals.
  Widget _buildNutrientSummaryCard() {
    final selectedDay = _planDays[_selectedDayIndex];

    return Consumer<WeeklyMealPlanProvider>(
      builder: (context, provider, _) {
        final meals = provider.mealsFor(selectedDay);

        var calories = 0;
        var proteinG = 0.0;
        var carbsG = 0.0;
        var fatG = 0.0;
        for (final meal in meals) {
          calories += meal.calories;
          proteinG += meal.macros.proteinG;
          carbsG += meal.macros.carbsG;
          fatG += meal.macros.fatG;
        }
        final hasData = meals.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _PlanColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientItem(
                icon: Icons.local_fire_department_outlined,
                iconColor: const Color(0xFF6B8E23),
                bgColor: const Color(0xFFEBF5E8),
                label: context.tr('exercises_calories_label'),
                value: hasData ? "$calories Kcal" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.fitness_center_rounded,
                iconColor: const Color(0xFFE08A00),
                bgColor: const Color(0xFFFFF3E0),
                label: context.tr('exercises_protein_label'),
                value: hasData ? "${proteinG.round()} g" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.eco_outlined,
                iconColor: const Color(0xFF29B6F6),
                bgColor: const Color(0xFFE1F5FE),
                label: context.tr('exercises_carbs_label'),
                value: hasData ? "${carbsG.round()} g" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFFAB47BC),
                bgColor: const Color(0xFFF3E5F5),
                label: context.tr('exercises_fats_label'),
                value: hasData ? "${fatG.round()} g" : "—",
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutrientItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: _PlanColors.textSecondary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
        ),
      ],
    );
  }

  String _mealCategoryLabel(int index) {
    const keys = ['meal_breakfast', 'meal_lunch', 'meal_dinner'];
    if (index < keys.length) return context.tr(keys[index]);
    return context.tr('meal_snack_n', {'n': '${index - keys.length + 1}'});
  }

  // Today's Meals Cards — AI-generated recipes for the selected day.
  Widget _buildTodayMealsSection() {
    final selectedDay = _planDays[_selectedDayIndex];
    const weekdayNameKeys = [
      'exercises_weekday_monday', 'exercises_weekday_tuesday', 'exercises_weekday_wednesday',
      'exercises_weekday_thursday', 'exercises_weekday_friday', 'exercises_weekday_saturday', 'exercises_weekday_sunday',
    ];
    final title = context.tr('exercises_meals_title', {
      'weekday': context.tr(weekdayNameKeys[selectedDay.weekday - 1]),
      'date': _formatDate(selectedDay),
    });

    if (widget.profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary)),
          const SizedBox(height: 12),
          Text(
            context.tr('exercises_complete_profile_for_recipes'),
            style: const TextStyle(fontSize: 12, color: _PlanColors.textSecondary),
          ),
        ],
      );
    }

    return Consumer<WeeklyMealPlanProvider>(
      builder: (context, provider, _) {
        final state = provider.stateFor(selectedDay);
        final meals = provider.mealsFor(selectedDay);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary)),
            const SizedBox(height: 12),
            if (state == LoadState.loading)
              const SizedBox(
                height: 190,
                child: Center(child: CircularProgressIndicator(color: _PlanColors.primaryDark)),
              )
            else if (state == LoadState.error)
              SizedBox(
                height: 190,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('exercises_recipes_error'),
                        style: const TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _ensureMealsForSelectedDay, child: Text(context.tr('common_retry'))),
                    ],
                  ),
                ),
              )
            else if (meals.isEmpty)
              SizedBox(
                height: 60,
                child: Center(
                  child: Text(context.tr('exercises_no_recipes_yet'), style: const TextStyle(fontSize: 12, color: _PlanColors.textSecondary)),
                ),
              )
            else
              SizedBox(
                height: 190,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: meals.length,
                  itemBuilder: (context, index) => _PlanMealCard(
                    day: selectedDay,
                    meal: meals[index],
                    categoryLabel: _mealCategoryLabel(index),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openShoppingList() {
    final profile = widget.profile;
    if (profile == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShoppingListScreen(profile: profile, days: _planDays),
      ),
    );
  }

  // Shopping List Banner Card
  Widget _buildShoppingListCard() {
    return GestureDetector(
      onTap: _openShoppingList,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _PlanColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('exercises_shopping_list_title'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('exercises_shopping_list_subtitle'),
                  style: const TextStyle(fontSize: 9, color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openShoppingList,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _PlanColors.primaryDark,
              minimumSize: const Size(80, 30),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: Text(context.tr('exercises_view_list'), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            label: const Icon(Icons.arrow_forward, size: 10),
          ),
        ],
      ),
      ),
    );
  }

  // Horizontal Workout Plan Section
  Widget _buildWorkoutPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('exercises_workout_plan_section_title'),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
            ),
            GestureDetector(
              onTap: () => _startWorkout(0),
              child: Text(
                context.tr('exercises_view_full_plan'),
                style: const TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWorkoutHorizontalList(),
      ],
    );
  }

  Widget _buildWorkoutHorizontalList() {
    if (_loading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator(color: _PlanColors.primaryDark)),
      );
    }
    if (_error != null) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('exercises_load_workouts_error'),
                style: const TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadVideos, child: Text(context.tr('common_retry'))),
            ],
          ),
        ),
      );
    }
    if (_videos.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            context.tr('dashboard_exercise_videos_empty'),
            style: const TextStyle(fontSize: 12, color: _PlanColors.textSecondary),
          ),
        ),
      );
    }

    final subtitle = '${ActiveWorkoutScreen.setsPerExercise} ${context.tr('common_sets')}';

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final workout = _videos[index];
          final isActive = index < 2;

          return GestureDetector(
            onTap: () => _startWorkout(index),
            child: Container(
            width: 125,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? _PlanColors.activeBgGreen : _PlanColors.cardLightBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isActive ? _PlanColors.activeGreen : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActive ? _PlanColors.activeGreen : Colors.black12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      context.tr('weekday_mon').toUpperCase(),
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : _PlanColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                Text(
                  workout.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                ),
                const Spacer(),
                Image.asset(
                  "assets/fit.png",
                  height: 58,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.fitness_center_outlined, size: 40, color: _PlanColors.primaryDark),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  // Built-in Rest Days Banner
  Widget _buildRestDaysCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _PlanColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _PlanColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.self_improvement, color: _PlanColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('exercises_rest_days_title'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('exercises_rest_days_subtitle'),
                  style: const TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Plan Progress Card — live values from WorkoutProgressProvider. Listening here (not in
  // build) keeps the per-second updates during a workout from rebuilding the whole screen.
  static const _plannedWorkoutsPerWeek = 5;

  /// "45s", "12m 05s" or "1h 05m".
  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  Widget _buildPlanProgressCard() {
    final progress = context.read<WorkoutProgressProvider>();
    return ListenableBuilder(
      listenable: Listenable.merge([progress, progress.liveTick]),
      builder: (context, _) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final weekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
        final weekEnd = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);

        // One workout = every goal video × sets × video length.
        final perWorkoutSeconds = _videos.isNotEmpty
            ? _videos.length * ActiveWorkoutScreen.setsPerExercise * WorkoutProgressProvider.secondsPerSet
            : 20 * 60;
        final weeklyTargetSeconds = perWorkoutSeconds * _plannedWorkoutsPerWeek;

        final weekSeconds = progress.secondsBetween(weekStart, weekEnd);
        final todaySeconds = progress.secondsBetween(today, tomorrow);
        final workoutDays = progress.workoutDaysBetween(weekStart, weekEnd);
        final streak = progress.currentStreak;
        final ratio = (weekSeconds / weeklyTargetSeconds).clamp(0.0, 1.0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _PlanColors.cardWhite,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('exercises_plan_progress_title'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                  ),
                  if (progress.workoutInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _PlanColors.activeBgGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${context.tr('exercises_live')} · ${_formatDuration(progress.liveSessionSeconds)}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      '${(ratio * 100).round()}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _PlanColors.activeGreen),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('exercises_progress_subtitle'),
                style: const TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(weekSeconds),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      context.tr('exercises_time_this_week', {'target': _formatDuration(weeklyTargetSeconds)}),
                      style: const TextStyle(fontSize: 10, color: _PlanColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: ratio),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: _PlanColors.cardLightBg,
                    color: _PlanColors.activeGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildProgressStat(
                    context.tr('exercises_workouts_completed_label'),
                    context.tr('exercises_fraction', {'a': '$workoutDays', 'b': '$_plannedWorkoutsPerWeek'}),
                    Icons.fitness_center,
                  ),
                  _buildProgressStat(
                    context.tr('exercises_today_time_label'),
                    _formatDuration(todaySeconds),
                    Icons.timer_outlined,
                  ),
                  _buildProgressStat(
                    context.tr('exercises_active_streak_label'),
                    context.tr(streak == 1 ? 'exercises_day_count_one' : 'exercises_days_count', {'n': '$streak'}),
                    Icons.local_fire_department,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: _PlanColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 12, color: _PlanColors.activeGreen),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  // Floating Bottom Navigation Bar Widget
  Widget _buildBottomNavigationBar() {
    return AppBottomNavBar(currentTab: AppTab.plan, profile: widget.profile);
  }
}

class _PlanMealCard extends StatefulWidget {
  final DateTime day;
  final Meal meal;
  final String categoryLabel;

  const _PlanMealCard({required this.day, required this.meal, required this.categoryLabel});

  @override
  State<_PlanMealCard> createState() => _PlanMealCardState();
}

class _PlanMealCardState extends State<_PlanMealCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeeklyMealPlanProvider>().ensureImageForMeal(widget.day, widget.meal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeeklyMealPlanProvider>();
    final imageState = provider.imageStateFor(widget.day, widget.meal);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openRecipe,
      child: Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _PlanColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: _buildImage(imageState),
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _PlanColors.primaryDark.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${widget.meal.calories} kcal",
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.categoryLabel,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _PlanColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            widget.meal.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            widget.meal.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
          ),
        ],
      ),
      ),
    );
  }

  void _openRecipe() {
    try {
      // Use the provider's latest copy so the recipe gets the image if it
      // finished loading after this card was built (same as the dashboard).
      // A plain loop, not firstWhere(orElse:): the list's runtime type is
      // List<MealModel>, so an orElse returning a Meal throws a type error.
      Meal meal = widget.meal;
      for (final m in context.read<WeeklyMealPlanProvider>().mealsFor(widget.day)) {
        if (m.cacheKey == widget.meal.cacheKey) {
          meal = m;
          break;
        }
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealDetailScreen(meal: meal, categoryLabel: widget.categoryLabel),
        ),
      );
    } catch (e, st) {
      debugPrint('[PlanMealCard] open recipe failed: $e\n$st');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Open recipe failed: $e')));
    }
  }

  Widget _buildImage(LoadState state) {
    if (widget.meal.imagePath != null) {
      return Image.file(File(widget.meal.imagePath!), fit: BoxFit.cover);
    }
    if (state == LoadState.error) {
      return GestureDetector(
        onTap: () => context.read<WeeklyMealPlanProvider>().ensureImageForMeal(widget.day, widget.meal),
        child: Container(
          color: _PlanColors.background,
          child: const Icon(Icons.refresh, size: 18, color: _PlanColors.textSecondary),
        ),
      );
    }
    return Container(
      color: _PlanColors.background,
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