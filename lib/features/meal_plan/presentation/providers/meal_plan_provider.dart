import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/database_helper.dart';
import 'package:untitled/features/meal_plan/data/models/meal_model.dart';
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

  String _todayKey() => DateTime.now().toIso8601String().split('T').first;

  String get _mealsCacheKey => 'meal_plan_${_todayKey()}';

  Future<void> submitProfileAndGenerate(UserProfile newProfile) async {
    profile = newProfile;
    dailyTarget = NutritionCalculator.calculateDailyTarget(newProfile);
    planState = LoadState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final cached = await DatabaseHelper().getCacheValue(_mealsCacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached) as List;
        meals = decoded.map((m) => MealModel.fromJson(m)).toList();
        // A cached imagePath only stays valid if the file is still on disk.
        for (final meal in meals) {
          if (meal.imagePath != null && !File(meal.imagePath!).existsSync()) {
            meal.imagePath = null;
          }
        }
      } else {
        meals = await repository.generateMealPlan(
          profile: newProfile,
          dailyTarget: dailyTarget!,
        );
        await _persistMealsCache();
      }
      planState = LoadState.success;
    } catch (e) {
      errorMessage = e.toString();
      planState = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> _persistMealsCache() async {
    final encoded = jsonEncode(
      meals.map((m) => (m as MealModel).toJson()).toList(),
    );
    await DatabaseHelper().setCacheValue(_mealsCacheKey, encoded);
  }

  Future<void> ensureImageForMeal(Meal meal) async {
    if (meal.imagePath != null) return;
    if (imageStates[meal.cacheKey] == LoadState.loading) return;

    imageStates[meal.cacheKey] = LoadState.loading;
    imageErrors.remove(meal.cacheKey);
    notifyListeners();

    try {
      final path = await repository.getOrGenerateImage(meal);
      meal.imagePath = path;
      imageStates[meal.cacheKey] = LoadState.success;
      await _persistMealsCache();
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
