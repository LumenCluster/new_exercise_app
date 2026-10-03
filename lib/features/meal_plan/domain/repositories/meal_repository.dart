import '../entities/meal.dart';
import '../../../profile/domain/entities/user_profile.dart';

abstract class MealRepository {
  Future<List<Meal>> generateMealPlan({
    required UserProfile profile,
    required MealTarget dailyTarget,
  });

  Future<String> getOrGenerateImage(Meal meal);
}
