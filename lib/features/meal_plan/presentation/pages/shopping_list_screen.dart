import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/localization/app_localizations.dart';
import 'package:untitled/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:untitled/features/meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';

class _ShopColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const accentGreen = Color(0xFF3E7D2B);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const border = Color(0xFFE9E9E3);
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

  String get key => name.trim().toLowerCase();
}

enum _ShopCategory { produce, proteins, dairy, pantry, extras }

extension on _ShopCategory {
  String get labelKey => switch (this) {
        _ShopCategory.produce => 'meal_plan_shopping_cat_produce',
        _ShopCategory.proteins => 'meal_plan_shopping_cat_proteins',
        _ShopCategory.dairy => 'meal_plan_shopping_cat_dairy',
        _ShopCategory.pantry => 'meal_plan_shopping_cat_pantry',
        _ShopCategory.extras => 'meal_plan_shopping_cat_extras',
      };

  IconData get icon => switch (this) {
        _ShopCategory.produce => Icons.eco_outlined,
        _ShopCategory.proteins => Icons.set_meal_outlined,
        _ShopCategory.dairy => Icons.egg_outlined,
        _ShopCategory.pantry => Icons.rice_bowl_outlined,
        _ShopCategory.extras => Icons.shopping_basket_outlined,
      };
}

/// Ingredients carry no category from the AI, so they are grouped by keyword.
/// Checked in order — more specific groups first (e.g. "peanut butter" is pantry, not dairy).
const _categoryKeywords = <_ShopCategory, List<String>>{
  _ShopCategory.pantry: [
    'peanut butter', 'almond butter', 'coconut milk', 'rice', 'oat', 'oats', 'quinoa', 'pasta', 'noodle', 'bread',
    'tortilla', 'wrap', 'flour', 'couscous', 'barley', 'granola', 'cereal', 'oil', 'vinegar', 'seed', 'chia', 'flax',
    'nut', 'almond', 'walnut', 'cashew', 'peanut', 'pecan', 'pistachio', 'lentil', 'bean', 'chickpea', 'salt',
    'pepper flake', 'spice', 'cumin', 'paprika', 'turmeric', 'cinnamon', 'oregano', 'sauce', 'soy sauce', 'stock',
    'broth', 'sugar', 'cocoa', 'baking', 'cracker', 'protein powder',
  ],
  _ShopCategory.dairy: [
    'milk', 'yogurt', 'yoghurt', 'cheese', 'feta', 'mozzarella', 'parmesan', 'cottage', 'butter', 'cream', 'egg',
    'ghee', 'paneer', 'kefir', 'ricotta',
  ],
  _ShopCategory.proteins: [
    'chicken', 'beef', 'turkey', 'pork', 'lamb', 'salmon', 'tuna', 'cod', 'fish', 'shrimp', 'prawn', 'tofu',
    'tempeh', 'seitan', 'steak', 'fillet', 'mince', 'bacon', 'ham', 'sausage', 'sardine', 'tilapia', 'edamame',
  ],
  _ShopCategory.produce: [
    'spinach', 'kale', 'lettuce', 'arugula', 'cabbage', 'broccoli', 'cauliflower', 'carrot', 'tomato', 'cucumber',
    'pepper', 'onion', 'garlic', 'ginger', 'potato', 'zucchini', 'eggplant', 'mushroom', 'celery', 'asparagus',
    'pea', 'corn', 'avocado', 'banana', 'apple', 'berry', 'berries', 'blueberr', 'strawberr', 'raspberr', 'orange',
    'lemon', 'lime', 'mango', 'pineapple', 'grape', 'pear', 'peach', 'kiwi', 'melon', 'herb', 'cilantro',
    'parsley', 'basil', 'mint', 'dill', 'scallion', 'leek', 'beet', 'squash', 'pumpkin', 'radish', 'sprout',
    'greens', 'fruit', 'vegetable', 'date', 'fig', 'pomegranate', 'cherry', 'cherries',
  ],
};

/// Grocery staples that slip through the pantry list but read better as "Extras".
const _extrasOverrides = ['honey', 'maple syrup', 'syrup', 'jam', 'dark chocolate', 'chocolate', 'coffee', 'tea'];

_ShopCategory _categorize(String name) {
  final lower = name.toLowerCase();
  bool matches(String keyword) => RegExp(r'\b' + RegExp.escape(keyword)).hasMatch(lower);

  if (_extrasOverrides.any(matches)) return _ShopCategory.extras;
  // "eggplant"/"peppercorn" style collisions: produce words that contain another group's keyword win.
  if (matches('black pepper')) return _ShopCategory.pantry;
  if (['eggplant', 'bell pepper', 'green bean', 'sweet potato'].any(matches)) return _ShopCategory.produce;
  for (final entry in _categoryKeywords.entries) {
    if (entry.value.any(matches)) return entry.key;
  }
  return _ShopCategory.extras;
}

/// Sums quantities like "200g" + "150 g" when the units agree; otherwise lists them.
String _combineQuantities(List<String> quantities) {
  final pattern = RegExp(r'^\s*(\d+(?:[.,]\d+)?)\s*(.*?)\s*$');
  num total = 0;
  String? unit;
  for (final q in quantities) {
    final match = pattern.firstMatch(q);
    if (match == null) {
      unit = null;
      break;
    }
    final thisUnit = match.group(2)!.toLowerCase();
    if (unit != null && unit != thisUnit) {
      unit = null;
      break;
    }
    unit = thisUnit;
    total += num.parse(match.group(1)!.replaceAll(',', '.'));
  }

  if (unit != null) {
    final number = total == total.roundToDouble() ? total.toInt().toString() : total.toStringAsFixed(1);
    return unit.isEmpty ? number : (unit.length <= 2 ? '$number$unit' : '$number $unit');
  }

  final unique = quantities.map((q) => q.trim()).where((q) => q.isNotEmpty).toSet().toList();
  if (unique.length <= 2) return unique.join(' + ');
  return '${unique.take(2).join(' + ')} …';
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

  Map<_ShopCategory, List<_ShoppingItem>> _groupByCategory(List<_ShoppingItem> items) {
    final grouped = <_ShopCategory, List<_ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(_categorize(item.name), () => []).add(item);
    }
    // Keep the fixed category order from the enum.
    return {
      for (final category in _ShopCategory.values)
        if (grouped[category] != null) category: grouped[category]!,
    };
  }

  bool get _anyDayLoading {
    final provider = context.watch<WeeklyMealPlanProvider>();
    return widget.days.any((d) => provider.stateFor(d) == LoadState.loading || provider.stateFor(d) == LoadState.idle);
  }

  void _toggle(_ShoppingItem item) {
    setState(() {
      if (!_checked.remove(item.key)) _checked.add(item.key);
    });
  }

  void _toggleAll(List<_ShoppingItem> items, bool allDone) {
    setState(() {
      if (allDone) {
        _checked.clear();
      } else {
        _checked.addAll(items.map((i) => i.key));
      }
    });
  }

  Future<void> _copyList(Map<_ShopCategory, List<_ShoppingItem>> grouped) async {
    final buffer = StringBuffer('${context.tr('meal_plan_shopping_list_title')}\n');
    grouped.forEach((category, items) {
      buffer.writeln('\n${context.tr(category.labelKey)}');
      for (final item in items) {
        final mark = _checked.contains(item.key) ? '☑' : '☐';
        buffer.writeln('$mark ${item.name} — ${_combineQuantities(item.usages.map((u) => u.quantity).toList())}');
      }
    });
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('meal_plan_shopping_copied'))),
    );
  }

  String _dateRange() {
    if (widget.days.isEmpty) return '';
    final localizations = MaterialLocalizations.of(context);
    final first = localizations.formatShortMonthDay(widget.days.first);
    final last = localizations.formatShortMonthDay(widget.days.last);
    return ' ($first - $last)';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeeklyMealPlanProvider>();
    final items = _buildItems(provider);
    final grouped = _groupByCategory(items);
    final hasAnyError = widget.days.any((d) => provider.stateFor(d) == LoadState.error);

    Widget body;
    if (_anyDayLoading && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator(color: _ShopColors.primaryDark));
    } else if (items.isEmpty) {
      body = Center(
        child: Text(
          hasAnyError ? context.tr('meal_plan_shopping_generate_error') : context.tr('meal_plan_no_ingredients_yet'),
          style: const TextStyle(fontSize: 12, color: _ShopColors.textSecondary),
        ),
      );
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          for (final entry in grouped.entries) ...[
            _buildCategoryCard(entry.key, entry.value),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: _ShopColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(grouped),
            Expanded(child: body),
            if (items.isNotEmpty) _buildFooter(items),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<_ShopCategory, List<_ShoppingItem>> grouped) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: _ShopColors.textPrimary),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: _ShopColors.textPrimary, size: 22),
                onPressed: grouped.isEmpty ? null : () => _copyList(grouped),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('meal_plan_shopping_list_title'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _ShopColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _ShopColors.activeGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${context.tr('meal_plan_shopping_for_week')}${_dateRange()}',
                        style: const TextStyle(fontSize: 12, color: _ShopColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_ShopCategory category, List<_ShoppingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: _ShopColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ShopColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _ShopColors.activeBgGreen,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(category.icon, size: 17, color: _ShopColors.accentGreen),
                ),
                const SizedBox(width: 10),
                Text(
                  context.tr(category.labelKey),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _ShopColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          for (final item in items) ...[
            const Divider(height: 1, thickness: 1, color: _ShopColors.border),
            _buildItemRow(item),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(_ShoppingItem item) {
    final isChecked = _checked.contains(item.key);
    final quantity = _combineQuantities(item.usages.map((u) => u.quantity).toList());

    return InkWell(
      onTap: () => _showIngredientDetail(item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 2, 14, 2),
        child: Row(
          children: [
            // Generous hit area so the check is easy to tap without opening the detail sheet.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggle(item),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? _ShopColors.activeGreen : Colors.white,
                    border: isChecked ? null : Border.all(color: Colors.black26, width: 1.5),
                  ),
                  child: isChecked ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isChecked ? _ShopColors.textSecondary : _ShopColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                quantity,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _ShopColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(List<_ShoppingItem> items) {
    final total = items.length;
    final done = items.where((i) => _checked.contains(i.key)).length;
    final allDone = done == total;
    final percent = total == 0 ? 0 : (done * 100 / total).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      decoration: const BoxDecoration(
        color: _ShopColors.background,
        border: Border(top: BorderSide(color: _ShopColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('meal_plan_shopping_progress', {'done': '$done', 'total': '$total'}),
                  style: const TextStyle(fontSize: 12, color: _ShopColors.textSecondary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _ShopColors.activeBgGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ShopColors.accentGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 4,
              backgroundColor: _ShopColors.border,
              color: _ShopColors.activeGreen,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _toggleAll(items, allDone),
              style: ElevatedButton.styleFrom(
                backgroundColor: _ShopColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(allDone ? Icons.refresh_rounded : Icons.check_circle_outline_rounded, size: 20),
              label: Text(
                context.tr(allDone ? 'meal_plan_shopping_unmark_all' : 'meal_plan_shopping_mark_all'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
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
              const SizedBox(height: 2),
              Text(
                context.tr(
                  item.usages.length == 1 ? 'meal_plan_used_in_one_meal' : 'meal_plan_used_in_many_meals',
                  {'count': '${item.usages.length}'},
                ),
                style: const TextStyle(fontSize: 11, color: _ShopColors.textSecondary),
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
