import 'package:flutter/material.dart';
import 'package:untitled/features/exercises/domain/entities/exercise.dart';
import 'package:untitled/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final ExerciseRepository repository;
  const ExerciseLibraryScreen({super.key, required this.repository});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  FitnessGoal? _selectedGoal;
  late Future<List<Exercise>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.all();
  }

  void _applyGoal(FitnessGoal? goal) {
    setState(() {
      _selectedGoal = goal;
      _future = goal == null ? widget.repository.all() : widget.repository.byGoal(goal);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stretching Library')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _GoalFilterBar(selected: _selectedGoal, onSelect: _applyGoal),
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final exercises = snapshot.data ?? [];
                  if (exercises.isEmpty) {
                    return const Center(child: Text('No stretches found.'));
                  }
                  // Group by category for a scannable, sectioned list.
                  final grouped = <StretchCategory, List<Exercise>>{};
                  for (final e in exercises) {
                    grouped.putIfAbsent(e.category, () => []).add(e);
                  }
                  final categories = grouped.keys.toList()
                    ..sort((a, b) => a.index.compareTo(b.index));

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categories.length,
                    itemBuilder: (context, sectionIndex) {
                      final category = categories[sectionIndex];
                      final items = grouped[category]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
                            child: Text(
                              category.label,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          for (final exercise in items) _ExerciseTile(exercise: exercise),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalFilterBar extends StatelessWidget {
  final FitnessGoal? selected;
  final ValueChanged<FitnessGoal?> onSelect;

  const _GoalFilterBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _chip(context, null, 'All'),
          for (final goal in FitnessGoal.values) _chip(context, goal, goal.label),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, FitnessGoal? goal, String label) {
    final isSelected = selected == goal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelect(goal),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseTile({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: _ExerciseThumbnail(gifAsset: exercise.gifAsset),
        title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${exercise.difficulty.label} · ${exercise.prescriptionLabel}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.gifAsset != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: _ExerciseMedia(gifAsset: exercise.gifAsset!, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(exercise.description),
                const SizedBox(height: 10),
                _PrescriptionRow(exercise: exercise),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: exercise.muscleGroups
                      .map((m) => Chip(
                    label: Text(m),
                    visualDensity: VisualDensity.compact,
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                ...exercise.instructions.asMap().entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('${entry.key + 1}. ${entry.value}'),
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

/// Small info row summarizing sets/reps/hold time, side, and whether
/// equipment is needed — the "how many times we do it" details.
class _PrescriptionRow extends StatelessWidget {
  final Exercise exercise;
  const _PrescriptionRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _infoPill(context, Icons.repeat, exercise.prescriptionLabel, scheme),
        if (exercise.perSide)
          _infoPill(context, Icons.compare_arrows, 'Both sides', scheme),
        if (exercise.equipmentNeeded)
          _infoPill(context, Icons.fitness_center, 'Needs equipment', scheme)
        else
          _infoPill(context, Icons.check_circle_outline, 'No equipment', scheme),
      ],
    );
  }

  Widget _infoPill(BuildContext context, IconData icon, String label, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSecondaryContainer),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: scheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

class _ExerciseThumbnail extends StatelessWidget {
  final String? gifAsset;
  const _ExerciseThumbnail({required this.gifAsset});

  @override
  Widget build(BuildContext context) {
    const size = 48.0;
    if (gifAsset == null) {
      return _placeholder(context, size);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: _ExerciseMedia(
          gifAsset: gifAsset!,
          fit: BoxFit.cover,
          placeholderBuilder: (ctx) => _placeholder(ctx, size),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.self_improvement,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}

/// Renders a stretch's bundled GIF asset. All GIFs are shipped with the
/// app under assets/gifs/ — there's no remote fetch involved.
class _ExerciseMedia extends StatelessWidget {
  final String gifAsset;
  final BoxFit fit;
  final WidgetBuilder? placeholderBuilder;

  const _ExerciseMedia({
    required this.gifAsset,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      gifAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        if (placeholderBuilder != null) return placeholderBuilder!(context);
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      },
    );
  }
}