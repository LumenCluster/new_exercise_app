enum Gender { male, female, other }

enum Goal { gain, lose, maintain }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum EatingPreference {
  none,
  vegetarian,
  vegan,
  halal,
  keto,
  lowCarb,
  highProtein,
}

class UserProfile {
  final String? name;
  final String country;
  final int age;
  final Gender gender;
  final double heightCm;
  final double currentWeightKg;
  final double? targetWeightKg;
  final Goal goal;
  final ActivityLevel activityLevel;
  final EatingPreference eatingPreference;
  final List<String> allergies;
  final int mealsPerDay;
  final String? bodyShape;
  final int? workoutDaysPerWeek;
  final String? fitnessLevel;
  final List<String> considerations;
  final String? eatingStyle;
  final List<String> dietaryConsiderations;
  final List<String> ingredientLikes;
  final String? eatingHabits;
  final String? primaryGoal;
  final List<String> focusAreas;
  final String? improvementGoal;
  final String? targetBodyShape;
  final double? targetBodyFat;

  UserProfile({
    this.name,
    required this.country,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    this.targetWeightKg,
    required this.goal,
    required this.activityLevel,
    required this.eatingPreference,
    this.allergies = const [],
    this.mealsPerDay = 3,
    this.bodyShape,
    this.workoutDaysPerWeek,
    this.fitnessLevel,
    this.considerations = const [],
    this.eatingStyle,
    this.dietaryConsiderations = const [],
    this.ingredientLikes = const [],
    this.eatingHabits,
    this.primaryGoal,
    this.focusAreas = const [],
    this.improvementGoal,
    this.targetBodyShape,
    this.targetBodyFat,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'age': age,
        'gender': gender.name,
        'heightCm': heightCm,
        'currentWeightKg': currentWeightKg,
        'targetWeightKg': targetWeightKg,
        'goal': goal.name,
        'activityLevel': activityLevel.name,
        'eatingPreference': eatingPreference.name,
        'allergies': allergies,
        'mealsPerDay': mealsPerDay,
        'bodyShape': bodyShape,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'fitnessLevel': fitnessLevel,
        'considerations': considerations,
        'eatingStyle': eatingStyle,
        'dietaryConsiderations': dietaryConsiderations,
        'ingredientLikes': ingredientLikes,
        'eatingHabits': eatingHabits,
        'primaryGoal': primaryGoal,
        'focusAreas': focusAreas,
        'improvementGoal': improvementGoal,
        'targetBodyShape': targetBodyShape,
        'targetBodyFat': targetBodyFat,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'],
        country: json['country'] ?? '',
        age: json['age'] ?? 0,
        gender: Gender.values.byName(json['gender'] ?? 'male'),
        heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0.0,
        currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 0.0,
        targetWeightKg: json['targetWeightKg'] != null
            ? (json['targetWeightKg'] as num).toDouble()
            : null,
        goal: Goal.values.byName(json['goal'] ?? 'maintain'),
        activityLevel: ActivityLevel.values.byName(json['activityLevel'] ?? 'moderate'),
        eatingPreference:
            EatingPreference.values.byName(json['eatingPreference'] ?? 'none'),
        allergies: List<String>.from(json['allergies'] ?? []),
        mealsPerDay: json['mealsPerDay'] ?? 3,
        bodyShape: json['bodyShape'],
        workoutDaysPerWeek: json['workoutDaysPerWeek'],
        fitnessLevel: json['fitnessLevel'],
        considerations: List<String>.from(json['considerations'] ?? []),
        eatingStyle: json['eatingStyle'],
        dietaryConsiderations: List<String>.from(json['dietaryConsiderations'] ?? []),
        ingredientLikes: List<String>.from(json['ingredientLikes'] ?? []),
        eatingHabits: json['eatingHabits'],
        primaryGoal: json['primaryGoal'],
        focusAreas: List<String>.from(json['focusAreas'] ?? []),
        improvementGoal: json['improvementGoal'],
        targetBodyShape: json['targetBodyShape'],
        targetBodyFat: (json['targetBodyFat'] as num?)?.toDouble(),
      );
}
