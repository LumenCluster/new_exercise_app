import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';

class MealDetailScreen extends StatelessWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(meal.name),
              background: meal.imagePath != null
                  ? Image.file(File(meal.imagePath!), fit: BoxFit.cover)
                  : Container(color: Colors.black12),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text('${meal.calories} kcal')),
                      Chip(label: Text('P ${meal.macros.proteinG}g')),
                      Chip(label: Text('C ${meal.macros.carbsG}g')),
                      Chip(label: Text('F ${meal.macros.fatG}g')),
                      if (meal.cuisineTag.isNotEmpty) Chip(label: Text(meal.cuisineTag)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...meal.ingredients.map(
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${i.name} — ${i.quantity}')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...meal.instructions.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                child: Text('${e.key + 1}', style: const TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(e.value)),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
