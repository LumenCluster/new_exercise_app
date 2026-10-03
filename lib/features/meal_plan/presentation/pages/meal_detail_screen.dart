import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled/core/database/firestore_service.dart';
import 'package:untitled/core/localization/app_localizations.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';

class _RecipeColors {
  static const background = Colors.white;
  static const primaryDark = Color(0xFF14261C);
  static const activeGreen = Color(0xFF8CC63F);
  static const greenBg = Color(0xFFEBF5E8);
  static const chipGrey = Color(0xFFF1F3F6);
  static const iconBeige = Color(0xFFF7F1E3);
  static const divider = Color(0xFFEFF1F4);
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

/// Full recipe for one meal: photo header, calories, macros, ingredients,
/// numbered instructions and a button to log the meal for today.
class MealDetailScreen extends StatefulWidget {
  final Meal meal;

  /// Badge above the title, e.g. "BREAKFAST". Hidden when null.
  final String? categoryLabel;

  const MealDetailScreen({super.key, required this.meal, this.categoryLabel});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  static const _headerHeight = 300.0;

  bool _favorite = false;
  bool _logged = false;
  bool _logging = false;

  Meal get _meal => widget.meal;

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  @override
  void initState() {
    super.initState();
    _loadLogged();
  }

  Future<void> _loadLogged() async {
    try {
      final logged = await FirestoreService().getLoggedMeals(_todayKey);
      if (!mounted) return;
      setState(() => _logged = logged.contains(_meal.cacheKey));
    } catch (_) {
      // Not knowing the logged state just leaves the button enabled.
    }
  }

  Future<void> _logMeal() async {
    setState(() => _logging = true);
    try {
      await FirestoreService().logMeal(_todayKey, _meal.cacheKey, _meal.calories);
      if (!mounted) return;
      setState(() {
        _logged = true;
        _logging = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('meal_detail_logged'))),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _logging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RecipeColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            // Content sheet overlaps the photo slightly with rounded corners.
            Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: _RecipeColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleBlock(),
                    const SizedBox(height: 20),
                    _buildMacros(),
                    const SizedBox(height: 22),
                    _buildIngredients(),
                    const SizedBox(height: 22),
                    _buildInstructions(),
                    const SizedBox(height: 24),
                    _buildLogButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: _headerHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _meal.imagePath != null
              ? Image.file(File(_meal.imagePath!), fit: BoxFit.cover)
              : Container(
                  color: _RecipeColors.greenBg,
                  child: const Icon(Icons.restaurant_rounded, size: 64, color: _RecipeColors.activeGreen),
                ),
          Positioned(
            top: topInset + 12,
            left: 16,
            child: _circleButton(
              icon: Icons.arrow_back_rounded,
              color: _RecipeColors.textPrimary,
              onTap: () => Navigator.maybePop(context),
            ),
          ),
          Positioned(
            top: topInset + 12,
            right: 16,
            child: _circleButton(
              icon: _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: Colors.redAccent,
              onTap: () => setState(() => _favorite = !_favorite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.categoryLabel != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _RecipeColors.greenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.categoryLabel!,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                    color: _RecipeColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (_meal.cuisineTag.isNotEmpty)
              Flexible(
                child: Text(
                  _meal.cuisineTag,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _RecipeColors.textSecondary),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _meal.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: _RecipeColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_meal.calories}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _RecipeColors.activeGreen,
                  ),
                ),
                const Text(
                  'kcal',
                  style: TextStyle(fontSize: 11, color: _RecipeColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        if (_meal.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _meal.description,
            style: const TextStyle(fontSize: 12, height: 1.4, color: _RecipeColors.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildMacros() {
    String grams(double g) => g.round().toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('meal_detail_macros'),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: _RecipeColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _macroChip(context.tr('meal_detail_protein', {'g': grams(_meal.macros.proteinG)}), highlighted: true),
            _macroChip(context.tr('meal_detail_carbs', {'g': grams(_meal.macros.carbsG)})),
            _macroChip(context.tr('meal_detail_fat', {'g': grams(_meal.macros.fatG)})),
          ],
        ),
      ],
    );
  }

  Widget _macroChip(String label, {bool highlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? _RecipeColors.greenBg : _RecipeColors.chipGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted ? _RecipeColors.activeGreen.withValues(alpha: 0.6) : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _RecipeColors.textPrimary),
      ),
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('meal_plan_ingredients_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _RecipeColors.textPrimary),
            ),
            Text(
              context.tr('meal_detail_items', {'n': '${_meal.ingredients.length}'}),
              style: const TextStyle(fontSize: 12, color: _RecipeColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _RecipeColors.divider),
          ),
          child: Column(
            children: [
              for (var i = 0; i < _meal.ingredients.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: _RecipeColors.divider),
                _ingredientRow(_meal.ingredients[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _ingredientRow(Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _RecipeColors.iconBeige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_outlined, size: 18, color: _RecipeColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: const TextStyle(fontSize: 13, color: _RecipeColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ingredient.quantity,
            style: const TextStyle(fontSize: 12, color: _RecipeColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('meal_detail_quick_instructions'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _RecipeColors.textPrimary),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _meal.instructions.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _RecipeColors.activeGreen,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _meal.instructions[i],
                    style: const TextStyle(fontSize: 13, height: 1.45, color: _RecipeColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLogButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _logged || _logging ? null : _logMeal,
        icon: _logging
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Icon(_logged ? Icons.check_circle_rounded : Icons.check_rounded, size: 20),
        label: Text(context.tr(_logged ? 'meal_detail_logged' : 'meal_detail_log_meal')),
        style: ElevatedButton.styleFrom(
          backgroundColor: _RecipeColors.primaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _logged ? _RecipeColors.activeGreen : _RecipeColors.primaryDark,
          disabledForegroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.black26,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
