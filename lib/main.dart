import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'features/meal_plan/data/datasources/meal_remote_data_source.dart';
import 'features/meal_plan/data/repositories/meal_repository_impl.dart';
import 'features/meal_plan/domain/repositories/meal_repository.dart';
import 'features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'features/meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import 'features/exercises/data/datasources/exercise_local_data_source.dart';
import 'features/exercises/data/repositories/exercise_repository_impl.dart';
import 'features/exercises/domain/repositories/exercise_repository.dart';
import 'features/coach/data/datasources/coach_remote_data_source.dart';
import 'features/coach/data/repositories/coach_repository_impl.dart';
import 'features/coach/domain/repositories/coach_repository.dart';
import 'features/tracking/presentation/providers/water_intake_provider.dart';
import 'features/tracking/presentation/providers/weight_log_provider.dart';
import 'core/constants/app_colors.dart';
import 'app_launcher.dart';

void main() {
  final client = http.Client();

  final mealRemoteDataSource = MealRemoteDataSourceImpl(client: client);
  final mealRepository = MealRepositoryImpl(remoteDataSource: mealRemoteDataSource);

  final exerciseLocalDataSource = ExerciseLocalDataSourceImpl();
  final exerciseRepository = ExerciseRepositoryImpl(
    localDataSource: exerciseLocalDataSource,
  );

  final coachRemoteDataSource = CoachRemoteDataSourceImpl(client: client);
  final coachRepository = CoachRepositoryImpl(remoteDataSource: coachRemoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<MealRepository>.value(value: mealRepository),
        Provider<ExerciseRepository>.value(value: exerciseRepository),
        Provider<CoachRepository>.value(value: coachRepository),
        ChangeNotifierProvider(
          create: (_) => MealPlanProvider(repository: mealRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WeeklyMealPlanProvider(repository: mealRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => WaterIntakeProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => WeightLogProvider()..load(),
        ),
      ],
      child: const MealPlannerApp(),
    ),
  );
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.component,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const AppLauncher(),
    );
  }
}
