enum FitnessGoal {
  gainWeight,
  loseWeight,
  gainMuscle,
  maintainWeight,
}

extension FitnessGoalX on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.gainWeight:
        return 'Gain Weight';
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.gainMuscle:
        return 'Gain Muscle';
      case FitnessGoal.maintainWeight:
        return 'Maintain Weight';
    }
  }
}

enum Difficulty { beginner, intermediate, advanced }

extension DifficultyX on Difficulty {
  String get label => name[0].toUpperCase() + name.substring(1);
}

enum StretchCategory { dynamicWarmUp, staticCooldown, mobility, recovery }

extension StretchCategoryX on StretchCategory {
  String get label {
    switch (this) {
      case StretchCategory.dynamicWarmUp:
        return 'Dynamic Warm-Up';
      case StretchCategory.staticCooldown:
        return 'Static Cooldown';
      case StretchCategory.mobility:
        return 'Mobility';
      case StretchCategory.recovery:
        return 'Recovery';
    }
  }
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> instructions;
  final List<FitnessGoal> targetGoals;
  final List<String> muscleGroups;
  final Difficulty difficulty;
  final StretchCategory category;

  /// Total hold time in seconds for a single rep/set (0 if this is a
  /// rep-counted movement rather than a timed hold).
  final int durationSeconds;

  /// How many sets to perform, e.g. 2.
  final int sets;

  /// Number of reps per set, e.g. 10. Null for hold-based stretches.
  final int? reps;

  /// Hold time in seconds per rep/set, e.g. 30. Null for rep-based movements.
  final int? holdSeconds;

  /// Whether this stretch should be repeated on the other side of the body.
  final bool perSide;

  final bool equipmentNeeded;
  final String? imageAsset;

  /// GIF bundled with the app, e.g. 'assets/gifs/standing_quad_stretch.gif'.
  /// This is the only GIF source now — every stretch in our JSON ships
  /// with its own asset, so there's no remote lookup involved.
  final String? gifAsset;

  /// Firebase Storage path for this exercise's demo video, e.g.
  /// 'exercise_videos/standing_quad_stretch.mp4'. Null if no video exists
  /// yet for this exercise. Resolved to a download URL at playback time.
  final String? videoStoragePath;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.instructions,
    required this.targetGoals,
    required this.muscleGroups,
    required this.difficulty,
    required this.category,
    required this.durationSeconds,
    this.sets = 1,
    this.reps,
    this.holdSeconds,
    this.perSide = false,
    this.equipmentNeeded = false,
    this.imageAsset,
    this.gifAsset,
    this.videoStoragePath,
  });

  /// Human-readable prescription, e.g. "3 x 10 reps · each side"
  /// or "2 x 30s hold".
  String get prescriptionLabel {
    final buffer = StringBuffer();
    if (reps != null) {
      buffer.write('$sets x $reps reps');
    } else if (holdSeconds != null) {
      buffer.write('$sets x ${holdSeconds}s hold');
    } else if (durationSeconds > 0) {
      buffer.write('${durationSeconds}s hold');
    } else {
      buffer.write('$sets set${sets == 1 ? '' : 's'}');
    }
    if (perSide) buffer.write(' · each side');
    return buffer.toString();
  }

  Exercise copyWith({
    String? gifAsset,
    int? sets,
    int? reps,
    int? holdSeconds,
    bool? perSide,
    String? videoStoragePath,
  }) {
    return Exercise(
      id: id,
      name: name,
      description: description,
      instructions: instructions,
      targetGoals: targetGoals,
      muscleGroups: muscleGroups,
      difficulty: difficulty,
      category: category,
      durationSeconds: durationSeconds,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      holdSeconds: holdSeconds ?? this.holdSeconds,
      perSide: perSide ?? this.perSide,
      equipmentNeeded: equipmentNeeded,
      imageAsset: imageAsset,
      gifAsset: gifAsset ?? this.gifAsset,
      videoStoragePath: videoStoragePath ?? this.videoStoragePath,
    );
  }
}