import 'package:untitled/features/meal_plan/domain/entities/meal.dart';

class MealModel extends Meal {
  MealModel({
    required super.name,
    required super.description,
    required super.cuisineTag,
    required super.calories,
    required super.macros,
    required super.ingredients,
    required super.instructions,
    super.imagePath,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
        name: json['name'],
        description: json['description'],
        cuisineTag: json['cuisineTag'] ?? '',
        calories: (json['calories'] as num).toInt(),
        macros: MacroBreakdownModel.fromJson(json['macros']),
        ingredients: (json['ingredients'] as List)
            .map((i) => IngredientModel.fromJson(i))
            .toList(),
        instructions: List<String>.from(json['instructions']),
        imagePath: json['imagePath'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'cuisineTag': cuisineTag,
        'calories': calories,
        'macros': (macros as MacroBreakdownModel).toJson(),
        'ingredients': ingredients
            .map((i) => (i as IngredientModel).toJson())
            .toList(),
        'instructions': instructions,
        'imagePath': imagePath,
      };
}

class MacroBreakdownModel extends MacroBreakdown {
  MacroBreakdownModel({
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
  });

  factory MacroBreakdownModel.fromJson(Map<String, dynamic> json) =>
      MacroBreakdownModel(
        proteinG: (json['proteinG'] as num).toDouble(),
        carbsG: (json['carbsG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
      };
}

class IngredientModel extends Ingredient {
  IngredientModel({required super.name, required super.quantity});

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      IngredientModel(
        name: json['name'],
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity};
}
