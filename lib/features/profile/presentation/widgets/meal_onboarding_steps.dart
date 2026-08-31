import 'package:flutter/material.dart';

// --- Shared Colors ---
class MealColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

// --- Common Step Header ---
class MealStepHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const MealStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MealColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: MealColors.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// --- Common Button ---
class MealActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const MealActionButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MealColors.primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 1. DIET PREFERENCES INTRO STEP
// ==========================================
class DietIntroStep extends StatelessWidget {
  final VoidCallback onNext;

  const DietIntroStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "PART 2",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const MealStepHeader(
                title: "Diet Preferences",
                subtitle: "Tell us about your eating habits & preferences.",
              ),
              const Spacer(),
              Image.asset(
                'assets/one.png',
                height: 260,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.restaurant, size: 140, color: MealColors.activeGreen),
              ),
              const Spacer(),
              MealActionButton(text: "Continue", onPressed: onNext),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. FOOD ALLERGIES STEP
// ==========================================
class FoodAllergiesStep extends StatefulWidget {
  final Function(List<String> allergies) onNext;

  const FoodAllergiesStep({super.key, required this.onNext});

  @override
  State<FoodAllergiesStep> createState() => _FoodAllergiesStepState();
}

class _FoodAllergiesStepState extends State<FoodAllergiesStep> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _items = [
    {'id': 'peanuts', 'label': 'Peanuts', 'image': 'assets/peanut.png'},
    {'id': 'tree_nuts', 'label': 'Tree Nuts', 'image': 'assets/tree_nuts.png'},
    {'id': 'dairy', 'label': 'Dairy', 'image': 'assets/dairy.png'},
    {'id': 'egg', 'label': 'Egg', 'image': 'assets/egg.png'},
    {'id': 'wheat_gluten', 'label': 'Wheat/Gluten', 'image': 'assets/wheat.png'},
    {'id': 'soy', 'label': 'Soy', 'image': 'assets/soy.png'},
    {'id': 'fish', 'label': 'Fish', 'image': 'assets/fish.png'},
    {'id': 'seafood', 'label': 'Shelfish', 'image': 'assets/shelfish.png'},
    {'id': 'sesame', 'label': 'Sesame', 'image': 'assets/sasme.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "Do you have any food allergies?",
                subtitle: "Select all that apply for you.",
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final itemId = item['id']!;
                    final itemLabel = item['label']!;
                    final itemImage = item['image']!;
                    final isSelected = _selected.contains(itemId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(itemId);
                          } else {
                            _selected.add(itemId);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? MealColors.activeBgGreen : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? MealColors.activeGreen : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              itemImage,
                              height: 36,
                              width: 36,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.no_food, size: 32, color: MealColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              itemLabel,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: MealColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Add custom food"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => widget.onNext([]),
                child: const Text("I do not have any", style: TextStyle(color: MealColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              MealActionButton(text: "Continue", onPressed: () => widget.onNext(_selected.toList())),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
// ==========================================
// 3. EATING STYLE STEP
// ==========================================
class EatingStyleStep extends StatefulWidget {
  final Function(String style) onNext;

  const EatingStyleStep({super.key, required this.onNext});

  @override
  State<EatingStyleStep> createState() => _EatingStyleStepState();
}

class _EatingStyleStepState extends State<EatingStyleStep> {
  String? _selectedStyle;

  final List<Map<String, String>> _styles = [
    {'id': 'standard', 'label': 'Standard (No Specialty Diet)', 'image': 'assets/standard.png'},
    {'id': 'pescatarian', 'label': 'Pescatarian', 'image': 'assets/pest.png'},
    {'id': 'vegetarian', 'label': 'Vegetarian', 'image': 'assets/veg.png'},
    {'id': 'vegan', 'label': 'Vegan', 'image': 'assets/vegan.png'},
    {'id': 'keto', 'label': 'Keto / Low Carb', 'image': 'assets/keto.png'},
    {'id': 'mediterranean', 'label': 'Mediterranean', 'image': 'assets/medi.png'},
    {'id': 'paleo', 'label': 'Paleo', 'image': 'assets/paleo.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "What best describes your eating style?",
                subtitle: "Choose the one that best describes you.",
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _styles.length,
                  itemBuilder: (context, index) {
                    final item = _styles[index];
                    final itemId = item['id']!;
                    final itemLabel = item['label']!;
                    final itemImage = item['image']!;
                    final isSelected = _selectedStyle == itemId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedStyle = itemId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? MealColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? MealColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                itemImage,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.restaurant_menu, size: 24, color: MealColors.textSecondary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  itemLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: MealColors.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? MealColors.activeGreen : Colors.white,
                                  border: isSelected
                                      ? null
                                      : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MealActionButton(
                text: "Continue",
                onPressed: _selectedStyle != null ? () => widget.onNext(_selectedStyle!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. DIETARY CONSIDERATIONS STEP
// ==========================================
class DietaryConsiderationsStep extends StatefulWidget {
  final Function(List<String> items) onNext;

  const DietaryConsiderationsStep({super.key, required this.onNext});

  @override
  State<DietaryConsiderationsStep> createState() => _DietaryConsiderationsStepState();
}

class _DietaryConsiderationsStepState extends State<DietaryConsiderationsStep> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _items = [
    {'id': 'diabetes', 'label': 'Diabetes', 'image': 'assets/diabetes.png'},
    {'id': 'pcos', 'label': 'PCOS', 'image': 'assets/pcos.png'},
    {'id': 'pregnancy', 'label': 'Pregnancy', 'image': 'assets/preg.png'},
    {'id': 'allergy_aware', 'label': 'Allergy-aware', 'image': 'assets/allergy.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "Any dietary considerations?",
                subtitle: "Select all that apply to you.",
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final itemId = item['id']!;
                    final itemLabel = item['label']!;
                    final itemImage = item['image']!;
                    final isSelected = _selected.contains(itemId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(itemId);
                          } else {
                            _selected.add(itemId);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? MealColors.activeBgGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? MealColors.activeGreen : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              itemImage,
                              height: 40,
                              width: 40,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.health_and_safety, size: 36, color: MealColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              itemLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: MealColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => widget.onNext([]),
                child: const Text("I do not have any", style: TextStyle(color: MealColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              MealActionButton(text: "Continue", onPressed: () => widget.onNext(_selected.toList())),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class IngredientLikesStep extends StatefulWidget {
  final Function(List<String> items) onNext;

  const IngredientLikesStep({super.key, required this.onNext});

  @override
  State<IngredientLikesStep> createState() => _IngredientLikesStepState();
}

class _IngredientLikesStepState extends State<IngredientLikesStep> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _items = [
    {'id': 'chicken', 'label': 'Chicken', 'image': 'assets/chicken.png'},
    {'id': 'beef', 'label': 'Beef', 'image': 'assets/meat.png'},
    {'id': 'milk', 'label': 'Milk', 'image': 'assets/dairy.png'},
    {'id': 'eggs', 'label': 'Eggs', 'image': 'assets/egg.png'},
    {'id': 'bread', 'label': 'Bread', 'image': 'assets/bread.png'},
    {'id': 'greens', 'label': 'Greens', 'image': 'assets/veg.png'},
    {'id': 'fish', 'label': 'Fish', 'image': 'assets/fish.png'},
    {'id': 'sweet_potato', 'label': 'Sweet Potato', 'image': 'assets/sweat.png'},
    {'id': 'yogurt', 'label': 'Yogurt', 'image': 'assets/yogurt.png'},
    {'id': 'cheese', 'label': 'Cheese', 'image': 'assets/cheese.png'},
    {'id': 'shrimp', 'label': 'Shrimp', 'image': 'assets/shrimp.png'},
    {'id': 'corn', 'label': 'Corn', 'image': 'assets/corn.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "What material do you like the most?",
                subtitle: "Select all that apply for you.",
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final itemId = item['id']!;
                    final itemLabel = item['label']!;
                    final itemImage = item['image']!;
                    final isSelected = _selected.contains(itemId);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(itemId);
                          } else {
                            _selected.add(itemId);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: isSelected ? MealColors.activeBgGreen : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? MealColors.activeGreen : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              itemImage,
                              height: 32,
                              width: 32,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.fastfood, size: 28, color: MealColors.textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              itemLabel,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: MealColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 16, color: MealColors.textSecondary),
                label: const Text("Discover More", style: TextStyle(color: MealColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              MealActionButton(text: "Continue", onPressed: () => widget.onNext(_selected.toList())),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 6. EATING HABITS STEP
// ==========================================
class EatingHabitsStep extends StatefulWidget {
  final Function(String habit) onNext;

  const EatingHabitsStep({super.key, required this.onNext});

  @override
  State<EatingHabitsStep> createState() => _EatingHabitsStepState();
}

class _EatingHabitsStepState extends State<EatingHabitsStep> {
  String? _selectedHabit;

  final List<Map<String, String>> _habits = [
    {'id': 'balanced', 'label': 'Balanced Meals'},
    {'id': 'high_protein', 'label': 'High Protein / Low Carb'},
    {'id': 'low_cal', 'label': 'Low Calorie / Lean'},
    {'id': 'quick', 'label': 'Quick & Easy Prep Meals'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "How would you describe your eating habits?",
                subtitle: "This helps us plan your meals better.",
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final item = _habits[index];
                    final itemId = item['id']!;
                    final itemLabel = item['label']!;
                    final isSelected = _selectedHabit == itemId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedHabit = itemId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? MealColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? MealColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: MealColors.textPrimary,
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? MealColors.activeGreen : Colors.white,
                                  border: isSelected
                                      ? null
                                      : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MealActionButton(
                text: "Continue",
                onPressed: _selectedHabit != null ? () => widget.onNext(_selectedHabit!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 7. MEALS PER DAY STEP
// ==========================================
class MealsPerDayStep extends StatefulWidget {
  final Function(int count) onNext;

  const MealsPerDayStep({super.key, required this.onNext});

  @override
  State<MealsPerDayStep> createState() => _MealsPerDayStepState();
}

class _MealsPerDayStepState extends State<MealsPerDayStep> {
  int? _selectedMeals;

  final List<int> _counts = [2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const MealStepHeader(
                title: "How many meals do you prefer per day?",
                subtitle: "This helps us plan your daily routine.",
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _counts.length,
                  itemBuilder: (context, index) {
                    final count = _counts[index];
                    final isSelected = _selectedMeals == count;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMeals = count),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: isSelected ? MealColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? MealColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$count Meals",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: MealColors.textPrimary,
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? MealColors.activeGreen : Colors.white,
                                  border: isSelected
                                      ? null
                                      : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              MealActionButton(
                text: "Continue",
                onPressed: _selectedMeals != null ? () => widget.onNext(_selectedMeals!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 8. FINAL ALL SET STEP
// ==========================================
class AllSetStep extends StatelessWidget {
  final VoidCallback onFinish;

  const AllSetStep({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                "All set!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MealColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "We've got everything we need to\ncreate your personalized nutrition plan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: MealColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              MealActionButton(text: "Get goals and focus", onPressed: onFinish),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}