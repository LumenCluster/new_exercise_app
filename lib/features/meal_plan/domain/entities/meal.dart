class MacroBreakdown {
  final double proteinG;
  final double carbsG;
  final double fatG;

  MacroBreakdown({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}

class Ingredient {
  final String name;
  final String quantity;

  Ingredient({required this.name, required this.quantity});
}

class Meal {
  final String name;
  final String description;
  final String cuisineTag;
  final int calories;
  final MacroBreakdown macros;
  final List<Ingredient> ingredients;
  final List<String> instructions;

  String? imagePath;

  Meal({
    required this.name,
    required this.description,
    required this.cuisineTag,
    required this.calories,
    required this.macros,
    required this.ingredients,
    required this.instructions,
    this.imagePath,
  });

  String get cacheKey =>
      name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
}

class MealTarget {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  MealTarget({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}
