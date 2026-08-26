import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/meal_plan/domain/repositories/meal_repository.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import 'package:untitled/features/meal_plan/data/datasources/meal_remote_data_source.dart';

class MealRepositoryImpl implements MealRepository {
  final MealRemoteDataSource remoteDataSource;

  MealRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Meal>> generateMealPlan({
    required UserProfile profile,
    required MealTarget dailyTarget,
  }) async {
    final models = await remoteDataSource.generateMealPlan(
      profile: profile,
      dailyTarget: dailyTarget,
    );
    // Explicitly cast to List<Meal> if needed, though models is List<MealModel>
    // and MealModel extends Meal.
    return models;
  }

  @override
  Future<String> getOrGenerateImage(Meal meal) async {
    return await remoteDataSource.getOrGenerateImage(meal);
  }
}
