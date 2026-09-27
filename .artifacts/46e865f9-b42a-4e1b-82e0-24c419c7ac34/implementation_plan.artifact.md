# Planning: Arrange Project in Clean Architecture

This plan outlines the steps to reorganize the current Flutter project into a Clean Architecture structure, separating concerns into `data`, `domain`, and `presentation` layers, organized by features.

## User Review Required

> [!IMPORTANT]
> This refactoring will involve moving almost all files in the `lib/` directory. This will break existing imports, which I will fix as part of the process.
> I will also introduce Repository interfaces in the `domain` layer to strictly adhere to Clean Architecture.

> [!WARNING]
> I will move `lib/data/stretching_exercises.json` to the `assets/` directory at the project root. You will need to ensure this is correctly declared in your `pubspec.yaml` (I will attempt to update it).

## Proposed Changes

### Core & Common
- Move shared utilities and constants to `lib/core`.

#### [NEW] [api_config.dart](file:///E:/untitled/lib/core/constants/api_config.dart)
- Move from `lib/data/ApiConfig.dart`.

#### [NEW] [nutrition_calculator.dart](file:///E:/untitled/lib/core/utils/nutrition_calculator.dart)
- Move from `lib/NutritionCalculator.dart`.

---

### Feature: Meal Plan
Group all meal planning related logic, UI, and data handling.

#### [NEW] [meal.dart](file:///E:/untitled/lib/features/meal_plan/domain/entities/meal.dart)
- Entity definition (from `lib/Meal.dart`).
#### [NEW] [meal_repository.dart](file:///E:/untitled/lib/features/meal_plan/domain/repositories/meal_repository.dart)
- Repository interface.
#### [NEW] [meal_model.dart](file:///E:/untitled/lib/features/meal_plan/data/models/meal_model.dart)
- Data model with `fromJson`/`toJson` (inheriting from entity).
#### [NEW] [meal_remote_data_source.dart](file:///E:/untitled/lib/features/meal_plan/data/datasources/meal_remote_data_source.dart)
- Wrapper for Gemini and Imagen services.
#### [NEW] [meal_repository_impl.dart](file:///E:/untitled/lib/features/meal_plan/data/repositories/meal_repository_impl.dart)
- Implementation of the repository.
#### [NEW] [meal_plan_provider.dart](file:///E:/untitled/lib/features/meal_plan/presentation/providers/meal_plan_provider.dart)
- Refactored to use repository.
#### [NEW] [meal_plan_screen.dart](file:///E:/untitled/lib/features/meal_plan/presentation/pages/meal_plan_screen.dart)
#### [NEW] [meal_detail_screen.dart](file:///E:/untitled/lib/features/meal_plan/presentation/pages/meal_detail_screen.dart)

---

### Feature: Exercises
Group all exercise and stretching related logic.

#### [NEW] [exercise.dart](file:///E:/untitled/lib/features/exercises/domain/entities/exercise.dart)
#### [NEW] [exercise_repository.dart](file:///E:/untitled/lib/features/exercises/domain/repositories/exercise_repository.dart)
#### [NEW] [exercise_model.dart](file:///E:/untitled/lib/features/exercises/data/models/exercise_model.dart)
#### [NEW] [exercise_local_data_source.dart](file:///E:/untitled/lib/features/exercises/data/datasources/exercise_local_data_source.dart)
- For loading `stretching_exercises.json`.
#### [NEW] [exercise_gif_remote_data_source.dart](file:///E:/untitled/lib/features/exercises/data/datasources/exercise_gif_remote_data_source.dart)
- Move from `lib/data/exercise_gif_service.dart`.
#### [NEW] [exercise_repository_impl.dart](file:///E:/untitled/lib/features/exercises/data/repositories/exercise_repository_impl.dart)
#### [NEW] [exercise_library_screen.dart](file:///E:/untitled/lib/features/exercises/presentation/pages/exercise_library_screen.dart)

---

### Feature: Profile
Group user profile input and management.

#### [NEW] [user_profile.dart](file:///E:/untitled/lib/features/profile/domain/entities/user_profile.dart)
#### [NEW] [profile_input_screen.dart](file:///E:/untitled/lib/features/profile/presentation/pages/profile_input_screen.dart)

---

### Cleanup
- Delete old files in `lib/` and `lib/data/` once migrated.
- Update `lib/main.dart` imports.

## Verification Plan

### Automated Tests
- Verify project compilation.
- Add a simple unit test for `NutritionCalculator`.

### Manual Verification
- Verify User Profile input.
- Verify Meal Plan generation and images.
- Verify Exercise Library browsing and GIF loading.
