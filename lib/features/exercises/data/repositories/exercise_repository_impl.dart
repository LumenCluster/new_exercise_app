import 'package:untitled/features/exercises/domain/entities/exercise.dart';
import 'package:untitled/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:untitled/features/exercises/data/datasources/exercise_local_data_source.dart';
import 'package:untitled/features/exercises/data/datasources/exercise_remote_data_source.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDataSource localDataSource;
  final ExerciseRemoteDataSource remoteDataSource;

  List<Exercise>? _cache;

  ExerciseRepositoryImpl({required this.localDataSource, required this.remoteDataSource});

  /// Exercises live in Firestore (so content — and video links — can be
  /// updated without an app release). Falls back to the bundled JSON if
  /// Firestore is unreachable or hasn't been seeded, so the feature never
  /// dead-ends the way the app-launch profile check once did.
  Future<List<Exercise>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final remote = await remoteDataSource.getExercises();
      if (remote.isNotEmpty) {
        _cache = remote;
        return _cache!;
      }
    } catch (_) {
      // Fall through to the local bundle below.
    }
    final local = await localDataSource.getExercises();
    _cache = local;
    return _cache!;
  }

  @override
  Future<List<Exercise>> all() => _load();

  @override
  Future<Exercise?> byId(String id) async {
    final list = await _load();
    for (final e in list) {
      if (e.id == id) return e;
    }
    return null;
  }

  @override
  Future<List<Exercise>> byGoal(FitnessGoal goal) async {
    final list = await _load();
    return list.where((e) => e.targetGoals.contains(goal)).toList();
  }

  @override
  Future<List<Exercise>> filter({
    FitnessGoal? goal,
    Difficulty? difficulty,
    StretchCategory? category,
    bool? equipmentNeeded,
    String? muscleGroup,
  }) async {
    final list = await _load();
    return list.where((e) {
      if (goal != null && !e.targetGoals.contains(goal)) return false;
      if (difficulty != null && e.difficulty != difficulty) return false;
      if (category != null && e.category != category) return false;
      if (equipmentNeeded != null && e.equipmentNeeded != equipmentNeeded) return false;
      if (muscleGroup != null &&
          !e.muscleGroups.map((m) => m.toLowerCase()).contains(muscleGroup.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<List<Exercise>> search(String query) async {
    final list = await _load();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return list;
    return list
        .where((e) =>
    e.name.toLowerCase().contains(q) ||
        e.description.toLowerCase().contains(q) ||
        e.muscleGroups.any((m) => m.toLowerCase().contains(q)))
        .toList();
  }

  @override
  Future<List<Exercise>> recommendedSession(FitnessGoal goal, {int limit = 6}) async {
    final matches = await byGoal(goal);
    matches.sort((a, b) {
      const order = {
        StretchCategory.dynamicWarmUp: 0,
        StretchCategory.mobility: 1,
        StretchCategory.staticCooldown: 2,
        StretchCategory.recovery: 3,
      };
      return order[a.category]!.compareTo(order[b.category]!);
    });
    return matches.take(limit).toList();
  }

  @override
  Future<List<Exercise>> recommendedForProfile(UserProfile profile) async {
    final goal = _goalFromPrimaryGoal(profile.primaryGoal);
    var exercises = await recommendedSession(goal);

    if (profile.considerations.contains('no_equipment')) {
      final withoutEquipment = exercises.where((e) => !e.equipmentNeeded).toList();
      if (withoutEquipment.isNotEmpty) exercises = withoutEquipment;
    }

    if (exercises.isEmpty) {
      exercises = await byGoal(goal);
    }

    return exercises;
  }

  FitnessGoal _goalFromPrimaryGoal(String? primaryGoal) {
    switch (primaryGoal) {
      case 'weight_loss':
        return FitnessGoal.loseWeight;
      case 'weight_gain':
        return FitnessGoal.gainWeight;
      case 'muscle_gain':
        return FitnessGoal.gainMuscle;
      case 'maintain_weight':
      default:
        return FitnessGoal.maintainWeight;
    }
  }
}