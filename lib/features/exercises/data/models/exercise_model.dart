import 'package:untitled/features/exercises/domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.instructions,
    required super.targetGoals,
    required super.muscleGroups,
    required super.difficulty,
    required super.category,
    required super.durationSeconds,
    super.sets,
    super.reps,
    super.holdSeconds,
    super.perSide,
    super.equipmentNeeded,
    super.imageAsset,
    super.gifAsset,
    super.videoStoragePath,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      instructions: (json['instructions'] as List).cast<String>(),
      targetGoals: (json['targetGoals'] as List)
          .map((g) => FitnessGoal.values.firstWhere((e) => e.name == g))
          .toList(),
      muscleGroups: (json['muscleGroups'] as List).cast<String>(),
      difficulty: Difficulty.values.firstWhere(
            (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      category: StretchCategory.values.firstWhere(
            (c) => c.name == json['category'],
        orElse: () => StretchCategory.staticCooldown,
      ),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      sets: json['sets'] as int? ?? 1,
      reps: json['reps'] as int?,
      holdSeconds: json['holdSeconds'] as int?,
      perSide: json['perSide'] as bool? ?? false,
      equipmentNeeded: json['equipmentNeeded'] as bool? ?? false,
      imageAsset: json['imageAsset'] as String?,
      gifAsset: json['gifAsset'] as String?,
      videoStoragePath: json['videoStoragePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'instructions': instructions,
    'targetGoals': targetGoals.map((g) => g.name).toList(),
    'muscleGroups': muscleGroups,
    'difficulty': difficulty.name,
    'category': category.name,
    'durationSeconds': durationSeconds,
    'sets': sets,
    'reps': reps,
    'holdSeconds': holdSeconds,
    'perSide': perSide,
    'equipmentNeeded': equipmentNeeded,
    'imageAsset': imageAsset,
    'gifAsset': gifAsset,
    'videoStoragePath': videoStoragePath,
  };
}