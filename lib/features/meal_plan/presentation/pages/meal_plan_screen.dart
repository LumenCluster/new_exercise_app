import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/localization/app_localizations.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/meal_plan/presentation/providers/meal_plan_provider.dart';
import 'package:untitled/features/meal_plan/presentation/pages/meal_detail_screen.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('meal_plan_today_title'))),
      body: Consumer<MealPlanProvider>(
        builder: (context, provider, _) {
          switch (provider.planState) {
            case LoadState.loading:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(context.tr('dashboard_designing_meals')),
                    ],
                  ),
                ),
              );
            case LoadState.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(provider.errorMessage ?? context.tr('common_error')),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          if (provider.profile != null) {
                            provider.submitProfileAndGenerate(provider.profile!);
                          }
                        },
                        child: Text(context.tr('common_retry')),
                      ),
                    ],
                  ),
                ),
              );
            case LoadState.success:
              return Column(
                children: [
                  if (provider.dailyTarget != null) _TargetSummary(provider),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.meals.length,
                      itemBuilder: (context, index) {
                        final meal = provider.meals[index];
                        return _MealCard(meal: meal);
                      },
                    ),
                  ),
                ],
              );
            case LoadState.idle:
              return Center(child: Text(context.tr('dashboard_no_meal_plan_yet')));
          }
        },
      ),
    );
  }
}

class _TargetSummary extends StatelessWidget {
  final MealPlanProvider provider;
  const _TargetSummary(this.provider);

  @override
  Widget build(BuildContext context) {
    final t = provider.dailyTarget!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Text(
        context.tr('meal_plan_daily_target', {
          'kcal': '${t.calories}',
          'p': '${t.proteinG}',
          'c': '${t.carbsG}',
          'f': '${t.fatG}',
        }),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _MealCard extends StatefulWidget {
  final Meal meal;
  const _MealCard({required this.meal});

  @override
  State<_MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<_MealCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanProvider>().ensureImageForMeal(widget.meal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealPlanProvider>();
    final imageState = provider.imageStates[widget.meal.cacheKey] ?? LoadState.idle;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MealDetailScreen(meal: widget.meal)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _buildImage(context, widget.meal, imageState),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.meal.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(widget.meal.description, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.meal.calories} kcal  •  P ${widget.meal.macros.proteinG}g  •  C ${widget.meal.macros.carbsG}g  •  F ${widget.meal.macros.fatG}g',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, Meal meal, LoadState state) {
    if (meal.imagePath != null) {
      return Image.file(File(meal.imagePath!), fit: BoxFit.cover);
    }
    if (state == LoadState.error) {
      final error = context.read<MealPlanProvider>().imageErrors[meal.cacheKey];
      return ColoredBox(
        color: Colors.black12,
        child: InkWell(
          onTap: () => context.read<MealPlanProvider>().ensureImageForMeal(meal),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image_outlined),
                const SizedBox(height: 6),
                Text(
                  error ?? context.tr('meal_plan_image_failed'),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(context.tr('meal_plan_tap_to_retry'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }
    return const ColoredBox(
      color: Colors.black12,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
