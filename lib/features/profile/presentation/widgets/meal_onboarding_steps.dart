import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';

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
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // PART 2 badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MealColors.primaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  context.tr('onboarding_part2_badge'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Left-aligned title & subtitle
              Text(
                context.tr('onboarding_diet_intro_title'),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: MealColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('onboarding_diet_intro_subtitle'),
                style: const TextStyle(
                  fontSize: 13,
                  color: MealColors.textSecondary,
                  height: 1.4,
                ),
              ),

              // Illustration on the right, running off the right edge of the screen
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Transform.translate(
                    // 24 = page padding, plus a little extra so the image bleeds off-screen
                    offset: Offset(24 + screenWidth * 0.06, 0),
                    child: Image.asset(
                      'assets/one.png',
                      width: screenWidth * 0.88,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.restaurant, size: 140, color: MealColors.activeGreen),
                    ),
                  ),
                ),
              ),

              MealActionButton(text: context.tr('common_continue'), onPressed: onNext),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  context.tr('onboarding_about_2_minutes'),
                  style: const TextStyle(fontSize: 11, color: MealColors.textSecondary),
                ),
              ),
              const SizedBox(height: 4),
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

  static const List<Map<String, String>> _items = [
    {'id': 'peanuts', 'labelKey': 'onboarding_allergy_peanuts', 'image': 'assets/peanut.png'},
    {'id': 'tree_nuts', 'labelKey': 'onboarding_allergy_tree_nuts', 'image': 'assets/tree_nuts.png'},
    {'id': 'dairy', 'labelKey': 'onboarding_allergy_dairy', 'image': 'assets/dairy.png'},
    {'id': 'egg', 'labelKey': 'onboarding_allergy_egg', 'image': 'assets/egg.png'},
    {'id': 'wheat_gluten', 'labelKey': 'onboarding_allergy_wheat_gluten', 'image': 'assets/wheat.png'},
    {'id': 'soy', 'labelKey': 'onboarding_allergy_soy', 'image': 'assets/soy.png'},
    {'id': 'fish', 'labelKey': 'onboarding_allergy_fish', 'image': 'assets/fish.png'},
    {'id': 'seafood', 'labelKey': 'onboarding_allergy_shellfish', 'image': 'assets/shelfish.png'},
    {'id': 'sesame', 'labelKey': 'onboarding_allergy_sesame', 'image': 'assets/sasme.png'},
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
              MealStepHeader(
                title: context.tr('onboarding_allergies_title'),
                subtitle: context.tr('onboarding_allergies_subtitle'),
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
                    final itemLabel = context.tr(item['labelKey']!);
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
              // OutlinedButton.icon(
              //   style: OutlinedButton.styleFrom(
              //     minimumSize: const Size(double.infinity, 44),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              //   ),
              //   onPressed: () {},
              //   icon: const Icon(Icons.add, size: 16),
              //   label: Text(context.tr('onboarding_add_custom_food')),
              // ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => widget.onNext([]),
                child: Text(context.tr('onboarding_none_of_these'), style: const TextStyle(color: MealColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              MealActionButton(text: context.tr('common_continue'), onPressed: () => widget.onNext(_selected.toList())),
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

  static const List<Map<String, String>> _styles = [
    {'id': 'standard', 'labelKey': 'onboarding_style_standard', 'image': 'assets/standard.png'},
    {'id': 'pescatarian', 'labelKey': 'onboarding_style_pescatarian', 'image': 'assets/pest.png'},
    {'id': 'vegetarian', 'labelKey': 'onboarding_style_vegetarian', 'image': 'assets/veg.png'},
    {'id': 'vegan', 'labelKey': 'onboarding_style_vegan', 'image': 'assets/vegan.png'},
    {'id': 'keto', 'labelKey': 'onboarding_style_keto', 'image': 'assets/keto.png'},
    {'id': 'mediterranean', 'labelKey': 'onboarding_style_mediterranean', 'image': 'assets/medi.png'},
    {'id': 'paleo', 'labelKey': 'onboarding_style_paleo', 'image': 'assets/paleo.png'},
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
              MealStepHeader(
                title: context.tr('onboarding_eating_style_title'),
                subtitle: context.tr('onboarding_eating_style_subtitle'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _styles.length,
                  itemBuilder: (context, index) {
                    final item = _styles[index];
                    final itemId = item['id']!;
                    final itemLabel = context.tr(item['labelKey']!);
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
                text: context.tr('common_continue'),
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

  static const List<Map<String, String>> _items = [
    {'id': 'diabetes', 'labelKey': 'onboarding_consideration_diabetes', 'image': 'assets/diabetes.png'},
    {'id': 'pcos', 'labelKey': 'onboarding_consideration_pcos', 'image': 'assets/pcos.png'},
    {'id': 'pregnancy', 'labelKey': 'onboarding_consideration_pregnancy', 'image': 'assets/preg.png'},
    {'id': 'allergy_aware', 'labelKey': 'onboarding_consideration_allergy_aware', 'image': 'assets/allergy.png'},
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
              MealStepHeader(
                title: context.tr('onboarding_considerations_title'),
                subtitle: context.tr('onboarding_considerations_subtitle'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 2x2 grid of large emoji cards
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final itemId = item['id']!;
                          final itemLabel = context.tr(item['labelKey']!);
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
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? MealColors.activeBgGreen : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? MealColors.activeGreen : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    itemImage,
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.health_and_safety, size: 52, color: MealColors.textSecondary),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    itemLabel,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
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
                      const SizedBox(height: 16),

                      // "none of these" pill
                      GestureDetector(
                        onTap: () => widget.onNext([]),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.block, size: 18, color: MealColors.textPrimary),
                              const SizedBox(width: 10),
                              Text(
                                context.tr('onboarding_none_of_these'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: MealColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MealActionButton(text: context.tr('common_continue'), onPressed: () => widget.onNext(_selected.toList())),
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

  static const List<Map<String, String>> _items = [
    {'id': 'chicken', 'labelKey': 'onboarding_ingredient_chicken', 'image': 'assets/chicken.png'},
    {'id': 'beef', 'labelKey': 'onboarding_ingredient_beef', 'image': 'assets/meat.png'},
    {'id': 'milk', 'labelKey': 'onboarding_ingredient_milk', 'image': 'assets/dairy.png'},
    {'id': 'eggs', 'labelKey': 'onboarding_ingredient_eggs', 'image': 'assets/egg.png'},
    {'id': 'bread', 'labelKey': 'onboarding_ingredient_bread', 'image': 'assets/bread.png'},
    {'id': 'greens', 'labelKey': 'onboarding_ingredient_greens', 'image': 'assets/veg.png'},
    {'id': 'fish', 'labelKey': 'onboarding_ingredient_fish', 'image': 'assets/fish.png'},
    {'id': 'sweet_potato', 'labelKey': 'onboarding_ingredient_sweet_potato', 'image': 'assets/sweat.png'},
    {'id': 'yogurt', 'labelKey': 'onboarding_ingredient_yogurt', 'image': 'assets/yogurt.png'},
    {'id': 'cheese', 'labelKey': 'onboarding_ingredient_cheese', 'image': 'assets/cheese.png'},
    {'id': 'shrimp', 'labelKey': 'onboarding_ingredient_shrimp', 'image': 'assets/shrimp.png'},
    {'id': 'corn', 'labelKey': 'onboarding_ingredient_corn', 'image': 'assets/corn.png'},
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
              MealStepHeader(
                title: context.tr('onboarding_ingredients_title'),
                subtitle: context.tr('onboarding_ingredients_subtitle'),
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
                    final itemLabel = context.tr(item['labelKey']!);
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
                label: Text(context.tr('onboarding_discover_more'), style: const TextStyle(color: MealColors.textSecondary)),
              ),
              const SizedBox(height: 8),
              MealActionButton(text: context.tr('common_continue'), onPressed: () => widget.onNext(_selected.toList())),
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

  static const List<Map<String, String>> _habits = [
    {'id': 'cook_at_home', 'labelKey': 'onboarding_habit_cook_at_home'},
    {'id': 'eat_out_sometimes', 'labelKey': 'onboarding_habit_eat_out_sometimes'},
    {'id': 'eat_out_often', 'labelKey': 'onboarding_habit_eat_out_often'},
    {'id': 'quick', 'labelKey': 'onboarding_habit_quick_easy'},
  ];

  void _submit() {
    if (_selectedHabit == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr('onboarding_habit_required')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    widget.onNext(_selectedHabit!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              MealStepHeader(
                title: context.tr('onboarding_habits_title'),
                subtitle: context.tr('onboarding_habits_subtitle'),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _habits.length,
                  itemBuilder: (context, index) {
                    final item = _habits[index];
                    final itemId = item['id']!;
                    final itemLabel = context.tr(item['labelKey']!);
                    final isSelected = _selectedHabit == itemId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedHabit = itemId),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? MealColors.activeBgGreen : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? MealColors.activeGreen : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  itemLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: MealColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Radio: outlined circle, or green circle with a check when selected
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? MealColors.activeGreen : Colors.white,
                                  border: isSelected
                                      ? null
                                      : Border.all(color: Colors.black26, width: 1.5),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                text: context.tr('common_continue'),
                onPressed: _submit,
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
              MealStepHeader(
                title: context.tr('onboarding_meals_per_day_title'),
                subtitle: context.tr('onboarding_meals_per_day_subtitle'),
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
                                context.tr('onboarding_meals_count', {'count': '$count'}),
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
                text: context.tr('common_continue'),
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

  // The user's answers from the previous Part 2 steps
  final List<String> allergies;
  final String? eatingStyle;
  final List<String> considerations;
  final String? eatingHabit;
  final int mealsPerDay;

  const AllSetStep({
    super.key,
    required this.onFinish,
    this.allergies = const [],
    this.eatingStyle,
    this.considerations = const [],
    this.eatingHabit,
    this.mealsPerDay = 3,
  });

  static const Map<String, String> _habitKeys = {
    'cook_at_home': 'onboarding_habit_cook_at_home',
    'eat_out_sometimes': 'onboarding_habit_eat_out_sometimes',
    'eat_out_often': 'onboarding_habit_eat_out_often',
    'quick': 'onboarding_habit_quick_easy',
  };

  String _allergyLabel(BuildContext context, String id) =>
      context.tr(id == 'seafood' ? 'onboarding_allergy_shellfish' : 'onboarding_allergy_$id');

  // Joins translated labels, or "None" when nothing was selected
  String _joinOrNone(BuildContext context, List<String> labels) =>
      labels.isEmpty ? context.tr('onboarding_summary_none') : labels.join(', ');

  @override
  Widget build(BuildContext context) {
    final style = eatingStyle ?? 'standard';
    final habitKey = eatingHabit == null
        ? null
        : (_habitKeys[eatingHabit] ?? 'onboarding_habit_$eatingHabit');

    return Scaffold(
      backgroundColor: MealColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      MealStepHeader(
                        title: context.tr('onboarding_diet_summary_title'),
                        subtitle: context.tr('onboarding_diet_summary_subtitle'),
                      ),
                      const SizedBox(height: 20),
                      _buildStyleBanner(context, style),
                      const SizedBox(height: 16),
                      _buildAnswersCard(context, [
                        (
                          icon: Icons.no_food_outlined,
                          label: context.tr('onboarding_summary_allergies'),
                          value: _joinOrNone(
                            context,
                            [for (final a in allergies) _allergyLabel(context, a)],
                          ),
                        ),
                        (
                          icon: Icons.health_and_safety_outlined,
                          label: context.tr('onboarding_summary_dietary_needs'),
                          value: _joinOrNone(
                            context,
                            [for (final c in considerations) context.tr('onboarding_consideration_$c')],
                          ),
                        ),
                        (
                          icon: Icons.restaurant_outlined,
                          label: context.tr('onboarding_summary_eating_habits'),
                          value: habitKey == null
                              ? context.tr('onboarding_summary_none')
                              : context.tr(habitKey),
                        ),
                        (
                          icon: Icons.schedule_outlined,
                          label: context.tr('onboarding_summary_meals_per_day'),
                          value: context.tr('onboarding_meals_count', {'count': '$mealsPerDay'}),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildGreatChoiceCard(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              MealActionButton(text: context.tr('onboarding_get_goals_button'), onPressed: onFinish),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // Dark banner with the chosen eating style and the food bowl on the right
  Widget _buildStyleBanner(BuildContext context, String style) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [MealColors.primaryDark, Color(0xFF2E4D38)],
          ),
        ),
        child: Stack(
          children: [
            // Bowl illustration; anchored low so the icon arc at the top of the image is cropped
            Positioned(
              right: -30,
              bottom: -40,
              height: 220,
              child: Image.asset(
                'assets/one.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: SizedBox(
                width: 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('onboarding_summary_eating_style'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('onboarding_style_$style'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MealColors.activeGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        context.tr('onboarding_style_tag_$style'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // White card listing each answer with an icon, label, value and a check
  Widget _buildAnswersCard(
    BuildContext context,
    List<({IconData icon, String label, String value})> rows,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEFEDE6)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: MealColors.activeBgGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(rows[i].icon, size: 18, color: MealColors.primaryDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rows[i].label,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: MealColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rows[i].value,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: MealColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, size: 20, color: MealColors.activeGreen),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGreatChoiceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MealColors.activeBgGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: MealColors.activeGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('onboarding_great_choice_title'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: MealColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('onboarding_great_choice_body'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: MealColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
