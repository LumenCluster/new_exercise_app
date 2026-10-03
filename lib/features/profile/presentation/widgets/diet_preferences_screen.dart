import 'package:flutter/material.dart';
import 'meal_onboarding_steps.dart';

class DietPreferencesScreen extends StatefulWidget {
  const DietPreferencesScreen({super.key});

  @override
  State<DietPreferencesScreen> createState() => _DietPreferencesScreenState();
}

class _DietPreferencesScreenState extends State<DietPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Stored preferences
  List<String> _allergies = [];
  String _eatingStyle = 'standard';
  List<String> _considerations = [];
  List<String> _likedIngredients = [];
  String _eatingHabit = 'cook_at_home';
  int _mealsPerDay = 3;

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

  void _finishOnboarding() {
    // Hand the collected preferences back to whoever pushed this screen.
    Navigator.of(context).pop(<String, dynamic>{
      'allergies': _allergies,
      'eatingStyle': _eatingStyle,
      'considerations': _considerations,
      'likedIngredients': _likedIngredients,
      'eatingHabit': _eatingHabit,
      'mealsPerDay': _mealsPerDay,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Progress Bar Indicator
            if (_currentStep > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: MealColors.textPrimary),
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
                                color: isActive ? MealColors.primaryDark : Colors.black12,
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
                    setState(() => _considerations = items);
                    _nextPage();
                  }),
                  IngredientLikesStep(onNext: (items) {
                    setState(() => _likedIngredients = items);
                    _nextPage();
                  }),
                  EatingHabitsStep(onNext: (habit) {
                    setState(() => _eatingHabit = habit);
                    _nextPage();
                  }),
                  MealsPerDayStep(onNext: (count) {
                    setState(() => _mealsPerDay = count);
                    _nextPage();
                  }),
                  AllSetStep(
                    allergies: _allergies,
                    eatingStyle: _eatingStyle,
                    considerations: _considerations,
                    eatingHabit: _eatingHabit,
                    mealsPerDay: _mealsPerDay,
                    onFinish: _finishOnboarding,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}