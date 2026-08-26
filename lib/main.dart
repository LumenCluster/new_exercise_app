import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'features/meal_plan/data/datasources/meal_remote_data_source.dart';
import 'features/meal_plan/data/repositories/meal_repository_impl.dart';
import 'features/meal_plan/domain/repositories/meal_repository.dart';
import 'features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'features/exercises/data/datasources/exercise_local_data_source.dart';
import 'features/exercises/data/repositories/exercise_repository_impl.dart';
import 'features/exercises/domain/repositories/exercise_repository.dart';
import 'features/profile/presentation/pages/profile_input_screen.dart';
import 'core/constants/app_colors.dart';

void main() {
  final client = http.Client();

  final mealRemoteDataSource = MealRemoteDataSourceImpl(client: client);
  final mealRepository = MealRepositoryImpl(remoteDataSource: mealRemoteDataSource);

  final exerciseLocalDataSource = ExerciseLocalDataSourceImpl();
  final exerciseRepository = ExerciseRepositoryImpl(
    localDataSource: exerciseLocalDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<MealRepository>.value(value: mealRepository),
        Provider<ExerciseRepository>.value(value: exerciseRepository),
        ChangeNotifierProvider(
          create: (_) => MealPlanProvider(repository: mealRepository),
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
      home: const ProfileInputScreen(),
    );
  }
}
