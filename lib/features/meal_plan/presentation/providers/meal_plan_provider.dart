import 'package:flutter/foundation.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/meal_plan/domain/repositories/meal_repository.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import 'package:untitled/core/utils/nutrition_calculator.dart';

enum LoadState { idle, loading, success, error }

class MealPlanProvider extends ChangeNotifier {
  final MealRepository repository;

  MealPlanProvider({required this.repository});

  UserProfile? profile;
  MealTarget? dailyTarget;
  List<Meal> meals = [];

  LoadState planState = LoadState.idle;
  String? errorMessage;

  final Map<String, LoadState> imageStates = {};
  final Map<String, String> imageErrors = {};

  Future<void> submitProfileAndGenerate(UserProfile newProfile) async {
    profile = newProfile;
    dailyTarget = NutritionCalculator.calculateDailyTarget(newProfile);
    planState = LoadState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      meals = await repository.generateMealPlan(
        profile: newProfile,
        dailyTarget: dailyTarget!,
      );
      planState = LoadState.success;
    } catch (e) {
      errorMessage = e.toString();
      planState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> ensureImageForMeal(Meal meal) async {
    if (meal.imagePath != null) return;

    imageStates[meal.cacheKey] = LoadState.loading;
    imageErrors.remove(meal.cacheKey);
    notifyListeners();

    try {
      final path = await repository.getOrGenerateImage(meal);
      meal.imagePath = path;
      imageStates[meal.cacheKey] = LoadState.success;
    } catch (e) {
      imageStates[meal.cacheKey] = LoadState.error;
      imageErrors[meal.cacheKey] = e.toString();
    }
    notifyListeners();
  }

  void reset() {
    profile = null;
    dailyTarget = null;
    meals = [];
    planState = LoadState.idle;
    imageStates.clear();
    notifyListeners();
  }
}
