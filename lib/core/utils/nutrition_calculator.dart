import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';

class NutritionCalculator {
  static double _activityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
      case ActivityLevel.veryActive:
        return 1.9;
    }
  }

  static double calculateBMR(UserProfile p) {
    final base = 10 * p.currentWeightKg + 6.25 * p.heightCm - 5 * p.age;
    switch (p.gender) {
      case Gender.male:
        return base + 5;
      case Gender.female:
        return base - 161;
      case Gender.other:
        return base - 78;
    }
  }

  static double calculateTDEE(UserProfile p) {
    return calculateBMR(p) * _activityMultiplier(p.activityLevel);
  }

  static int calculateTargetCalories(UserProfile p) {
    final tdee = calculateTDEE(p);
    switch (p.goal) {
      case Goal.gain:
        return (tdee + 400).round();
      case Goal.lose:
        return (tdee - 400).round();
      case Goal.maintain:
        return tdee.round();
    }
  }

  static MealTarget calculateDailyTarget(UserProfile p) {
    final calories = calculateTargetCalories(p);

    double proteinPerKg;
    switch (p.goal) {
      case Goal.gain:
        proteinPerKg = 1.8;
        break;
      case Goal.lose:
        proteinPerKg = 2.0;
        break;
      case Goal.maintain:
        proteinPerKg = 1.6;
        break;
    }

    final proteinG = proteinPerKg * p.currentWeightKg;
    final proteinCals = proteinG * 4;

    final fatCals = calories * 0.28;
    final fatG = fatCals / 9;

    final remainingCals = calories - proteinCals - fatCals;
    final carbsG = (remainingCals > 0 ? remainingCals : 0) / 4;

    return MealTarget(
      calories: calories,
      proteinG: double.parse(proteinG.toStringAsFixed(1)),
      carbsG: double.parse(carbsG.toStringAsFixed(1)),
      fatG: double.parse(fatG.toStringAsFixed(1)),
    );
  }

  static MealTarget perMealTarget(MealTarget daily, int mealsPerDay) {
    return MealTarget(
      calories: (daily.calories / mealsPerDay).round(),
      proteinG: double.parse((daily.proteinG / mealsPerDay).toStringAsFixed(1)),
      carbsG: double.parse((daily.carbsG / mealsPerDay).toStringAsFixed(1)),
      fatG: double.parse((daily.fatG / mealsPerDay).toStringAsFixed(1)),
    );
  }
}
