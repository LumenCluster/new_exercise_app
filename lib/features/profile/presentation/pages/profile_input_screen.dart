import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/constants/app_colors.dart';
import 'package:untitled/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import '../../../../core/database/firestore_service.dart';
import '../../../dashboard/presentation/dashboard_screen.dart';
import '../widgets/onboarding_steps.dart';
import '../widgets/fitness_summary_step.dart';
import '../widgets/meal_onboarding_steps.dart';
import '../widgets/goals_focus_onboarding_steps.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  State<ProfileInputScreen> createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 25;

  // Data storage - Part 1 (Fitness)
  String? _name;
  Gender _gender = Gender.female;
  int _age = 26;
  double _height = 170.0;
  double _weight = 65.5;
  String? _bodyShape;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  int _workoutDays = 4;
  String? _fitnessLevel;
  List<String> _considerations = [];

  // Data storage - Part 2 (Meals)
  List<String> _allergies = [];
  String? _eatingStyle;
  List<String> _dietaryConsiderations = [];
  List<String> _ingredientLikes = [];
  String? _eatingHabits;
  int _mealsPerDay = 3;

  // Data storage - Part 3 (Goals & Focus)
  String? _primaryGoal;
  List<String> _focusAreas = [];
  String? _improvementGoal;
  String? _targetBodyShape;
  double? _targetBodyFat;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Goal _mapPrimaryGoalToGoal(String? primaryGoal) {
    switch (primaryGoal) {
      case 'weight_loss':
        return Goal.lose;
      case 'weight_gain':
      case 'muscle_gain':
        return Goal.gain;
      case 'maintain_weight':
      default:
        return Goal.maintain;
    }
  }

  void _submit() async {
    print("Submit process started...");
    try {
      final profile = UserProfile(
        name: _name,
        country: "Unknown",
        age: _age,
        gender: _gender,
        heightCm: _height,
        currentWeightKg: _weight,
        goal: _mapPrimaryGoalToGoal(_primaryGoal),
        activityLevel: _activityLevel,
        eatingPreference: EatingPreference.none,
        bodyShape: _bodyShape,
        workoutDaysPerWeek: _workoutDays,
        fitnessLevel: _fitnessLevel,
        considerations: _considerations,
        allergies: _allergies,
        eatingStyle: _eatingStyle,
        dietaryConsiderations: _dietaryConsiderations,
        ingredientLikes: _ingredientLikes,
        eatingHabits: _eatingHabits,
        mealsPerDay: _mealsPerDay,
        primaryGoal: _primaryGoal,
        focusAreas: _focusAreas,
        improvementGoal: _improvementGoal,
        targetBodyShape: _targetBodyShape,
        targetBodyFat: _targetBodyFat,
      );

      print("Saving profile to database...");
      // Save to database
      await FirestoreService().saveProfile(profile);
      print("Profile saved successfully.");

      if (mounted) {
        print("Triggering meal plan generation...");
        context.read<MealPlanProvider>().submitProfileAndGenerate(profile);

        print("Navigating to Dashboard...");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e, stack) {
      print("ERROR IN SUBMIT: $e");
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.textPrimary),
                      onPressed: _previousPage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: List.generate(_totalSteps - 1, (index) {
                          final isActive = index < _currentStep;
                          return Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2.0),
                              height: 4,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.component.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentStep = index),
                children: [
                  // --- Part 1: Fitness ---
                  IntroStep(onNext: _nextPage),
                  AboutYouIntroStep(onNext: _nextPage),
                  NameGenderStep(onNext: (name, gender) {
                    setState(() {
                      _name = name;
                      _gender = gender;
                    });
                    _nextPage();
                  }),
                  AgeStep(onNext: (age) {
                    setState(() => _age = age);
                    _nextPage();
                  }),
                  HeightStep(onNext: (height) {
                    setState(() => _height = height);
                    _nextPage();
                  }),
                  WeightStep(onNext: (weight) {
                    setState(() => _weight = weight);
                    _nextPage();
                  }),
                  BodyShapeStep(
                    onNext: (shape, fatRange) {
                      setState(() => _bodyShape = shape);
                      _nextPage();
                    },
                  ),
                  ActivityLevelStep(onNext: (level) {
                    setState(() => _activityLevel = level);
                    _nextPage();
                  }),
                  FrequencyStep(onNext: (days) {
                    setState(() => _workoutDays = days);
                    _nextPage();
                  }),
                  FitnessLevelStep(onNext: (level) {
                    setState(() => _fitnessLevel = level);
                    _nextPage();
                  }),
                  ConsiderationsStep(onNext: (considerations) {
                    setState(() => _considerations = considerations);
                    _nextPage();
                  }),
                  FitnessSummaryStep(
                    heightCm: _height,
                    weightKg: _weight,
                    activityLevel: _activityLevel,
                    fitnessLevel: _fitnessLevel,
                    bodyShape: _bodyShape,
                    onContinue: _nextPage,
                    onEdit: _goToPage,
                  ),

                  // --- Part 2: Meals ---
                  DietIntroStep(onNext: _nextPage),
                  FoodAllergiesStep(onNext: (allergies) {
                    setState(() => _allergies = allergies);
                    _nextPage();
                  }),
                  EatingStyleStep(onNext: (style) {
                    setState(() => _eatingStyle = style);
                    _nextPage();
                  }),
                  DietaryConsiderationsStep(onNext: (items) {
                    setState(() => _dietaryConsiderations = items);
                    _nextPage();
                  }),
                  IngredientLikesStep(onNext: (items) {
                    setState(() => _ingredientLikes = items);
                    _nextPage();
                  }),
                  EatingHabitsStep(onNext: (habit) {
                    setState(() => _eatingHabits = habit);
                    _nextPage();
                  }),
                  MealsPerDayStep(onNext: (count) {
                    setState(() => _mealsPerDay = count);
                    _nextPage();
                  }),
                  AllSetStep(onFinish: _nextPage),

                  // --- Part 3: Goals & Focus ---
                  GoalsIntroStep(onNext: _nextPage),
                  PrimaryGoalStep(onNext: (goal) {
                    setState(() => _primaryGoal = goal);
                    _nextPage();
                  }),
                  TargetFocusStep(onNext: (areas) {
                    setState(() => _focusAreas = areas);
                    _nextPage();
                  }),
                  ImproveGoalStep(onNext: (goal) {
                    setState(() => _improvementGoal = goal);
                    _nextPage();
                  }),
                  TargetBodyShapeStep(onNext: (shape, fat) {
                    setState(() {
                      _targetBodyShape = shape;
                      _targetBodyFat = fat;
                    });
                    _submit();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
