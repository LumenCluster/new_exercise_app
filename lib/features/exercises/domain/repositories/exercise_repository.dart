import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import '../entities/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> all();
  Future<Exercise?> byId(String id);
  Future<List<Exercise>> byGoal(FitnessGoal goal);
  Future<List<Exercise>> filter({
    FitnessGoal? goal,
    Difficulty? difficulty,
    StretchCategory? category,
    bool? equipmentNeeded,
    String? muscleGroup,
  });
  Future<List<Exercise>> search(String query);
  Future<List<Exercise>> recommendedSession(FitnessGoal goal, {int limit = 6});

  /// Builds today's exercise list purely from the user's onboarding
  /// preferences (primary goal + considerations) — no network call.
  Future<List<Exercise>> recommendedForProfile(UserProfile profile);
}
