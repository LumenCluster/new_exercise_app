import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../../meal_plan/domain/entities/meal.dart';
import '../../../meal_plan/presentation/providers/meal_plan_provider.dart' show LoadState;
import '../../../meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import '../../../meal_plan/presentation/pages/shopping_list_screen.dart';
import '../../../coach/presentation/pages/coach_chat_screen.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';

class _WorkoutCard {
  final String name;
  final String subtitle;
  const _WorkoutCard(this.name, this.subtitle);
}

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
  final ExerciseRepository repository;

  const WorkoutPlanScreen({
    super.key,
    required this.profile,
    required this.repository,
  });

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  static const _weekdayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  late final List<DateTime> _planDays;
  int _selectedDayIndex = 0; // Default selected day: today

  List<Exercise> _exercises = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _planDays = List.generate(5, (i) => DateTime(today.year, today.month, today.day + i));
    _loadExercises();
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

  Future<void> _loadExercises() async {
    final profile = widget.profile;
    if (profile == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final exercises = await widget.repository.recommendedForProfile(profile);
      if (!mounted) return;
      setState(() {
        _exercises = exercises;
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
            const Text(
              "Your Plan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _PlanColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Padding(
          padding: EdgeInsets.only(left: 26.0),
          child: Text(
            "Personalized workouts & meals, powered by AI",
            style: TextStyle(
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
        ),
      ),
    );
  }

  // Coach Cards (Fitness Coach & AI Nutrition Coach)
  Widget _buildCoachCards() {
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCoachCard(
            title: "Fitness Coach",
            description: "Your AI fitness coach for smarter workouts. Ask anything!",
            imageAsset: "assets/fitness_coach.png",
            bgColor: const Color(0xFFE8F2E2),
            onChatTap: () => _openCoachChat(
              title: "Fitness Coach",
              subtitle: "AI · always available",
              icon: Icons.fitness_center_rounded,
              accentColor: _PlanColors.activeGreen,
              systemPrompt: _fitnessSystemPrompt(),
              greeting: "Hi! I'm your fitness coach. Ask me about your workouts, form, or how to progress.",
            ),
          ),
          const SizedBox(width: 12),
          _buildCoachCard(
            title: "AI Nutrition Coach",
            description: "Get personalized nutrition advice, meal ideas & more",
            imageAsset: "assets/nutrition_coach.png",
            bgColor: const Color(0xFFEFEFE9),
            onChatTap: () => _openCoachChat(
              title: "Nutrition Coach",
              subtitle: "AI · always available",
              icon: Icons.eco_rounded,
              accentColor: const Color(0xFF6B8E23),
              systemPrompt: _nutritionSystemPrompt(),
              greeting: "Hi! I'm your nutrition coach. Ask me about your meals, macros, or diet swaps.",
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
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _PlanColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: _PlanColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onChatTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PlanColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 26),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Chat Now >",
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imageAsset,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 100,
                color: Colors.white24,
                child: const Icon(Icons.person, color: _PlanColors.primaryDark),
              ),
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
          "This Week's Plan\n(${_formatDate(_planDays.first)} - ${_formatDate(_planDays.last)})",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _PlanColors.textPrimary,
            height: 1.2,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            "View All",
            style: TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
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
                    _weekdayLabels[date.weekday % 7],
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
                label: "CALORIES",
                value: hasData ? "$calories Kcal" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.fitness_center_rounded,
                iconColor: const Color(0xFFE08A00),
                bgColor: const Color(0xFFFFF3E0),
                label: "PROTEIN",
                value: hasData ? "${proteinG.round()} g" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.eco_outlined,
                iconColor: const Color(0xFF29B6F6),
                bgColor: const Color(0xFFE1F5FE),
                label: "CARBS",
                value: hasData ? "${carbsG.round()} g" : "—",
              ),
              _buildNutrientItem(
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFFAB47BC),
                bgColor: const Color(0xFFF3E5F5),
                label: "FATS",
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

  static String _mealCategoryLabel(int index) {
    const labels = ['BREAKFAST', 'LUNCH', 'DINNER'];
    if (index < labels.length) return labels[index];
    return 'SNACK ${index - labels.length + 1}';
  }

  // Today's Meals Cards — AI-generated recipes for the selected day.
  Widget _buildTodayMealsSection() {
    final selectedDay = _planDays[_selectedDayIndex];
    final weekdayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final title = "Meals (${weekdayNames[selectedDay.weekday - 1]}, ${_formatDate(selectedDay)})";

    if (widget.profile == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary)),
          const SizedBox(height: 12),
          const Text(
            "Complete your profile to get AI-generated recipes.",
            style: TextStyle(fontSize: 12, color: _PlanColors.textSecondary),
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
                      const Text(
                        "Couldn't generate recipes for this day.",
                        style: TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _ensureMealsForSelectedDay, child: const Text("Retry")),
                    ],
                  ),
                ),
              )
            else if (meals.isEmpty)
              const SizedBox(
                height: 60,
                child: Center(
                  child: Text("No recipes generated yet.", style: TextStyle(fontSize: 12, color: _PlanColors.textSecondary)),
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
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Shopping List",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  "All ingredients you need for this week's meals",
                  style: TextStyle(fontSize: 9, color: Colors.white70),
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
            icon: const Text("View List", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
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
            const Text(
              "Workout Plan",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "View Full Plan",
                style: TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
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
              const Text(
                "Couldn't load your workouts.",
                style: TextStyle(fontSize: 11, color: _PlanColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadExercises, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    // Default mock cards if repository returned empty
    final workoutList = _exercises.isNotEmpty
        ? _exercises.map((e) => _WorkoutCard(e.name, e.prescriptionLabel)).toList()
        : const [
      _WorkoutCard("Full Body Strength", "25 min"),
      _WorkoutCard("Core & Abs Blast", "15 min"),
      _WorkoutCard("Full Body Burn", "20 min"),
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: workoutList.length,
        itemBuilder: (context, index) {
          final workout = workoutList[index];
          final isActive = index < 2;

          return Container(
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
                      "MON",
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
                const Icon(Icons.fitness_center_outlined, size: 40, color: _PlanColors.primaryDark),
                const Spacer(),
                Text(
                  workout.subtitle,
                  style: const TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
                ),
              ],
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
              children: const [
                Text(
                  "Built-in Rest Days",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  "Rest days help your body recover so you can grow even stronger.",
                  style: TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Plan Progress Card
  Widget _buildPlanProgressCard() {
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
              const Text(
                "Plan Progress",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _PlanColors.textPrimary),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: const [
                    Text("View Progress", style: TextStyle(fontSize: 10, color: _PlanColors.textSecondary)),
                    Icon(Icons.arrow_drop_down, size: 16, color: _PlanColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Keep up your momentum to reach your fitness targets",
            style: TextStyle(fontSize: 9, color: _PlanColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressStat("Workouts Completed", "5 / 12", Icons.fitness_center),
              _buildProgressStat("Meals Followed", "18 / 21", Icons.restaurant_menu),
              _buildProgressStat("Active Streak", "12 Days", Icons.local_fire_department),
            ],
          ),
        ],
      ),
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

    return Container(
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
                    color: _PlanColors.primaryDark.withOpacity(0.85),
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
    );
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