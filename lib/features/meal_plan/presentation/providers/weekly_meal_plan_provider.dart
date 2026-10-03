import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';
import 'package:untitled/core/utils/nutrition_calculator.dart';
import 'package:untitled/features/meal_plan/data/models/meal_model.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/meal_plan/domain/repositories/meal_repository.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import 'meal_plan_provider.dart' show LoadState;

/// Generates and caches one AI recipe set per calendar day, so the
/// "Plan" screen can show a different day's meals without re-hitting
/// the Gemini API every time the user flips days.
class WeeklyMealPlanProvider extends ChangeNotifier {
  final MealRepository repository;

  WeeklyMealPlanProvider({required this.repository});

  final Map<String, List<Meal>> _mealsByDay = {};
  final Map<String, LoadState> _stateByDay = {};
  final Map<String, String> _errorByDay = {};
  final Map<String, LoadState> _imageStateByKey = {};

  static String dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

  static String _cacheKey(DateTime day) => 'meal_plan_${dayKey(day)}';

  List<Meal> mealsFor(DateTime day) => _mealsByDay[dayKey(day)] ?? const [];

  LoadState stateFor(DateTime day) => _stateByDay[dayKey(day)] ?? LoadState.idle;

  String? errorFor(DateTime day) => _errorByDay[dayKey(day)];

  LoadState imageStateFor(DateTime day, Meal meal) =>
      _imageStateByKey['${dayKey(day)}_${meal.cacheKey}'] ?? LoadState.idle;

  Future<void> ensureMealsForDay(UserProfile profile, DateTime day) async {
    final key = dayKey(day);
    if (_stateByDay[key] == LoadState.loading || _stateByDay[key] == LoadState.success) {
      return;
    }

    _stateByDay[key] = LoadState.loading;
    _errorByDay.remove(key);
    notifyListeners();

    try {
      final cached = await FirestoreService().getCacheValue(_cacheKey(day));
      List<Meal> meals;
      if (cached != null) {
        final decoded = jsonDecode(cached) as List;
        meals = decoded.map((m) => MealModel.fromJson(m)).toList();
        for (final meal in meals) {
          if (meal.imagePath != null && !File(meal.imagePath!).existsSync()) {
            meal.imagePath = null;
          }
        }
      } else {
        final target = NutritionCalculator.calculateDailyTarget(profile);
        meals = await repository.generateMealPlan(profile: profile, dailyTarget: target);
        await _persistDay(day, meals);
      }
      _mealsByDay[key] = meals;
      _stateByDay[key] = LoadState.success;
    } catch (e) {
      _errorByDay[key] = e.toString();
      _stateByDay[key] = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> ensureImageForMeal(DateTime day, Meal meal) async {
    if (meal.imagePath != null) return;
    final imageKey = '${dayKey(day)}_${meal.cacheKey}';
    if (_imageStateByKey[imageKey] == LoadState.loading) return;

    _imageStateByKey[imageKey] = LoadState.loading;
    notifyListeners();

    try {
      final path = await repository.getOrGenerateImage(meal);
      meal.imagePath = path;
      _imageStateByKey[imageKey] = LoadState.success;
      final meals = _mealsByDay[dayKey(day)];
      if (meals != null) await _persistDay(day, meals);
    } catch (_) {
      _imageStateByKey[imageKey] = LoadState.error;
    }
    notifyListeners();
  }

  Future<void> _persistDay(DateTime day, List<Meal> meals) async {
    final encoded = jsonEncode(meals.map((m) => (m as MealModel).toJson()).toList());
    await FirestoreService().setCacheValue(_cacheKey(day), encoded);
  }
}
