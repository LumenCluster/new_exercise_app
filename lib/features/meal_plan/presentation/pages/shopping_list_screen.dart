import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/localization/app_localizations.dart';
import 'package:untitled/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:untitled/features/meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';

class _ShopColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

class _IngredientUsage {
  final String quantity;
  final String mealName;
  final String dayLabel;
  const _IngredientUsage({required this.quantity, required this.mealName, required this.dayLabel});
}

class _ShoppingItem {
  final String name;
  final List<_IngredientUsage> usages;
  _ShoppingItem(this.name, this.usages);
}

/// Aggregates ingredients across the week's AI-generated recipes into one
/// shopping list; tapping an item shows which meals need it and how much.
class ShoppingListScreen extends StatefulWidget {
  final UserProfile profile;
  final List<DateTime> days;

  const ShoppingListScreen({super.key, required this.profile, required this.days});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final Set<String> _checked = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAllDaysGenerated());
  }

  Future<void> _ensureAllDaysGenerated() async {
    final provider = context.read<WeeklyMealPlanProvider>();
    for (final day in widget.days) {
      await provider.ensureMealsForDay(widget.profile, day);
    }
  }

  List<_ShoppingItem> _buildItems(WeeklyMealPlanProvider provider) {
    const weekdayKeys = ['weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat', 'weekday_sun'];
    final byKey = <String, _ShoppingItem>{};

    for (final day in widget.days) {
      final meals = provider.mealsFor(day);
      final dayLabel = context.tr(weekdayKeys[day.weekday - 1]);
      for (final meal in meals) {
        for (final ingredient in meal.ingredients) {
          final key = ingredient.name.trim().toLowerCase();
          final usage = _IngredientUsage(
            quantity: ingredient.quantity,
            mealName: meal.name,
            dayLabel: dayLabel,
          );
          byKey.putIfAbsent(key, () => _ShoppingItem(ingredient.name, [])).usages.add(usage);
        }
      }
    }

    final items = byKey.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  bool get _anyDayLoading {
    final provider = context.watch<WeeklyMealPlanProvider>();
    return widget.days.any((d) => provider.stateFor(d) == LoadState.loading || provider.stateFor(d) == LoadState.idle);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeeklyMealPlanProvider>();
    final items = _buildItems(provider);
    final hasAnyError = widget.days.any((d) => provider.stateFor(d) == LoadState.error);

    return Scaffold(
      backgroundColor: _ShopColors.background,
      appBar: AppBar(
        backgroundColor: _ShopColors.background,
        elevation: 0,
        foregroundColor: _ShopColors.textPrimary,
        title: Text(context.tr('meal_plan_shopping_list_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _anyDayLoading && items.isEmpty
            ? const Center(child: CircularProgressIndicator(color: _ShopColors.primaryDark))
            : items.isEmpty
                ? Center(
                    child: Text(
                      hasAnyError ? context.tr('meal_plan_shopping_generate_error') : context.tr('meal_plan_no_ingredients_yet'),
                      style: const TextStyle(fontSize: 12, color: _ShopColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _buildItemTile(items[index]),
                  ),
      ),
    );
  }

  Widget _buildItemTile(_ShoppingItem item) {
    final isChecked = _checked.contains(item.name.toLowerCase());

    return GestureDetector(
      onTap: () => _showIngredientDetail(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _ShopColors.cardWhite,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  final key = item.name.toLowerCase();
                  if (isChecked) {
                    _checked.remove(key);
                  } else {
                    _checked.add(key);
                  }
                });
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? _ShopColors.activeGreen : Colors.white,
                  border: isChecked ? null : Border.all(color: Colors.black26, width: 1.5),
                ),
                child: isChecked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _ShopColors.textPrimary,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(
                      item.usages.length == 1 ? 'meal_plan_used_in_one_meal' : 'meal_plan_used_in_many_meals',
                      {'count': '${item.usages.length}'},
                    ),
                    style: const TextStyle(fontSize: 10, color: _ShopColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _ShopColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showIngredientDetail(_ShoppingItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ShopColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ShopColors.textPrimary),
              ),
              const SizedBox(height: 12),
              ...item.usages.map(
                (usage) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${usage.mealName} · ${usage.dayLabel}",
                          style: const TextStyle(fontSize: 12, color: _ShopColors.textPrimary),
                        ),
                      ),
                      Text(
                        usage.quantity,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ShopColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
