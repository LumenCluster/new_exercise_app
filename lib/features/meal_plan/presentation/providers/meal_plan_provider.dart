import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';
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
      final cached = await FirestoreService().getCacheValue(_mealsCacheKey);
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
    await FirestoreService().setCacheValue(_mealsCacheKey, encoded);
  }

  Future<void> ensureImageForMeal(Meal meal) async {
    if (meal.imagePath != null) {
      debugPrint('[MealImage] ${meal.cacheKey}: already has path ${meal.imagePath}');
      return;
    }
    if (imageStates[meal.cacheKey] == LoadState.loading) {
      debugPrint('[MealImage] ${meal.cacheKey}: already loading, skipped');
      return;
    }

    debugPrint('[MealImage] ${meal.cacheKey}: requesting image');
    imageStates[meal.cacheKey] = LoadState.loading;
    imageErrors.remove(meal.cacheKey);
    notifyListeners();

    try {
      final path = await repository.getOrGenerateImage(meal);
      final file = File(path);
      debugPrint(
        '[MealImage] ${meal.cacheKey}: got $path '
        '(exists=${file.existsSync()}, '
        'bytes=${file.existsSync() ? file.lengthSync() : 0})',
      );
      meal.imagePath = path;
      // The meal list may have been reloaded while the image was generating,
      // so also apply the path to the current instance of this meal.
      for (final m in meals) {
        if (m.cacheKey == meal.cacheKey) m.imagePath = path;
      }
      imageStates[meal.cacheKey] = LoadState.success;
      await _persistMealsCache();
    } catch (e, st) {
      debugPrint('[MealImage] ${meal.cacheKey}: FAILED $e\n$st');
      imageStates[meal.cacheKey] = LoadState.error;
      imageErrors[meal.cacheKey] = e.toString();
    }
    notifyListeners();
  }

  /// Returns the provider's current instance of [meal] (matched by cacheKey),
  /// so widgets holding an older object still see the latest imagePath.
  Meal currentMeal(Meal meal) {
    for (final m in meals) {
      if (m.cacheKey == meal.cacheKey) return m;
    }
    return meal;
  }

  /// Discards an image file that failed to decode and generates it again.
  Future<void> retryImage(Meal meal) async {
    final path = meal.imagePath;
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    for (final m in meals) {
      if (m.cacheKey == meal.cacheKey) m.imagePath = null;
    }
    meal.imagePath = null;
    imageStates.remove(meal.cacheKey);
    await ensureImageForMeal(currentMeal(meal));
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
