import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/exercise.dart';
import '../widgets/exercise_video_player.dart';

class _DetailColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

/// Full-screen detail view for a single exercise: plays its demo video
/// (streamed from Firebase Storage via [Exercise.videoStoragePath]) and
/// lists its instructions.
class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;

    return Scaffold(
      backgroundColor: _DetailColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _DetailColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _DetailColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ExerciseVideoPlayer(
                    videoStoragePath: exercise.videoStoragePath,
                    backgroundColor: _DetailColors.primaryDark,
                    accentColor: _DetailColors.activeGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                exercise.prescriptionLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _DetailColors.activeGreen),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description,
                style: const TextStyle(fontSize: 13, color: _DetailColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              if (exercise.muscleGroups.isNotEmpty) ...[
                Text(
                  context.tr('exercises_muscle_groups_label'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _DetailColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: exercise.muscleGroups
                      .map((m) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _DetailColors.cardWhite,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(m, style: const TextStyle(fontSize: 11, color: _DetailColors.textPrimary)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                context.tr('exercises_instructions_title'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _DetailColors.textPrimary),
              ),
              const SizedBox(height: 10),
              ...exercise.instructions.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: _DetailColors.primaryDark, shape: BoxShape.circle),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 13, color: _DetailColors.textPrimary, height: 1.4),
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
    );
  }

}
