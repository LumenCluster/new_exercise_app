import 'package:untitled/features/exercises/domain/entities/exercise.dart';
import 'package:untitled/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:untitled/features/exercises/data/datasources/exercise_local_data_source.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseLocalDataSource localDataSource;

  List<Exercise>? _cache;

  ExerciseRepositoryImpl({required this.localDataSource});

  Future<List<Exercise>> _load() async {
    if (_cache != null) return _cache!;
    final models = await localDataSource.getExercises();
    _cache = models;
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
}