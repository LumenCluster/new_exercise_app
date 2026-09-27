import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/workout_video.dart';

/// Lists the exercise videos in the Firebase Storage folder that matches the
/// user's onboarding primary goal. Shared by the dashboard and the workout
/// plan screen so both show the same workout.
class GoalVideoRemoteDataSource {
  static const _videoExtensions = {'mp4', 'mov', 'm4v', 'webm', 'mkv', '3gp'};

  /// Onboarding primary-goal id -> (Firebase Storage folder, goal label key).
  static const _goalFolders = {
    'weight_loss': ('weight loss', 'onboarding_goal_weight_loss_label'),
    'weight_gain': ('weight gain', 'onboarding_goal_weight_gain_label'),
    'maintain_weight': ('maintain weight', 'onboarding_goal_maintain_label'),
    'muscle_gain': ('muscle gain', 'onboarding_goal_muscle_gain_label'),
  };

  /// Unknown/missing goals fall back to "maintain weight".
  static (String, String) _entry(String? primaryGoal) =>
      _goalFolders[primaryGoal] ?? _goalFolders['maintain_weight']!;

  static String folderFor(String? primaryGoal) => _entry(primaryGoal).$1;

  static String labelKeyFor(String? primaryGoal) => _entry(primaryGoal).$2;

  /// Every video in the goal's folder (including sub-folders), sorted by name.
  static Future<List<WorkoutVideo>> fetch(String? primaryGoal) async {
    // Storage rules only allow authenticated reads.
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    final refs = await _listVideos(FirebaseStorage.instance.ref(folderFor(primaryGoal)));
    refs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return [
      for (final ref in refs) WorkoutVideo(name: _titleFor(ref.name), storagePath: ref.fullPath),
    ];
  }

  static Future<List<Reference>> _listVideos(Reference folder) async {
    final result = await folder.listAll();
    final videos = result.items.where((ref) {
      final dot = ref.name.lastIndexOf('.');
      return dot != -1 && _videoExtensions.contains(ref.name.substring(dot + 1).toLowerCase());
    }).toList();
    for (final prefix in result.prefixes) {
      videos.addAll(await _listVideos(prefix));
    }
    return videos;
  }

  /// "side_plank-hold.mp4" -> "Side Plank Hold".
  static String _titleFor(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = dot == -1 ? fileName : fileName.substring(0, dot);
    final words = base.replaceAll(RegExp(r'[_\-]+'), ' ').trim().split(RegExp(r'\s+'));
    return words
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
