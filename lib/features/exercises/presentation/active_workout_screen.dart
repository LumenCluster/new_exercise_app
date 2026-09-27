import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/localization/app_localizations.dart';
import '../../tracking/presentation/providers/workout_progress_provider.dart';
import '../domain/entities/workout_video.dart';
import 'widgets/exercise_video_player.dart';

// --- Colors ---
class AppColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeGreenBg = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);
}

// =============================================================================
// 1. ACTIVE WORKOUT SCREEN (Left Image)
// =============================================================================
class ActiveWorkoutScreen extends StatefulWidget {
  /// Sets per exercise. One play-through of the video counts as one set.
  static const setsPerExercise = 12;

  /// Every exercise in the category, in playlist order.
  final List<WorkoutVideo> videos;

  /// Exercise to start with. The playlist starts here and wraps around, so
  /// every exercise in [videos] is still played once.
  final int startIndex;

  /// Header title (e.g. the goal name). Falls back to the program name.
  final String? title;

  const ActiveWorkoutScreen({
    super.key,
    required this.videos,
    this.startIndex = 0,
    this.title,
  }) : assert(videos.length > 0);

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  static const _sets = ActiveWorkoutScreen.setsPerExercise;

  final _playerKey = GlobalKey<ExerciseVideoPlayerState>();
  late final List<WorkoutVideo> _playlist;
  int _index = 0;
  int _currentSet = 1;
  bool _paused = false;
  bool _finished = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  // Session bookkeeping for the Report screen's workout history.
  late final WorkoutProgressProvider _progress;
  final DateTime _startedAt = DateTime.now();
  String _sessionTitle = '';
  int _setsThisSession = 0;
  bool _sessionRecorded = false;

  WorkoutVideo get _current => _playlist[_index];

  @override
  void initState() {
    super.initState();
    _progress = context.read<WorkoutProgressProvider>();
    final start = widget.startIndex.clamp(0, widget.videos.length - 1);
    _playlist = [
      ...widget.videos.sublist(start),
      ...widget.videos.sublist(0, start),
    ];
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sessionTitle = widget.title ?? context.tr('dashboard_program_name');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordSession(); // user left mid-workout
    super.dispose();
  }

  void _playedSet() {
    _setsThisSession++;
    _progress.addSetPlayed();
  }

  /// Saves this visit as a workout session (once, and only if a set was
  /// played).
  void _recordSession() {
    if (_sessionRecorded) return;
    _sessionRecorded = true;
    _progress.recordSession(
      title: _sessionTitle,
      startedAt: _startedAt,
      durationSeconds: _elapsed.inSeconds,
      sets: _setsThisSession,
    );
  }

  /// Called by the player each time the video ends. Returns whether the
  /// video should play again (i.e. there are sets left for this exercise).
  bool _onVideoCompleted() {
    _playedSet();
    if (_currentSet < _sets) {
      setState(() => _currentSet++);
      return true;
    }
    _goToNextExercise();
    return false;
  }

  void _completeSet() {
    _playedSet();
    if (_currentSet < _sets) {
      setState(() => _currentSet++);
      _playerKey.currentState?.restart();
    } else {
      _goToNextExercise();
    }
  }

  /// Moves on to the next exercise (after 12 sets, or when skipped), or to
  /// the completion screen after the last one.
  void _goToNextExercise() {
    if (_finished) return;
    if (_index + 1 < _playlist.length) {
      setState(() {
        _index++;
        _currentSet = 1;
      });
    } else {
      _finished = true;
      _timer?.cancel();
      _recordSession();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WorkoutCompleteScreen()),
      );
    }
  }

  void _togglePause() => setState(() => _paused = !_paused);

  String _formatElapsed() {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final upNext = _playlist.sublist(_index + 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildActiveExerciseCard(),
                    if (upNext.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        context.tr('exercises_up_next'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (final video in upNext) ...[
                        _buildUpNextTile(
                          video.name,
                          '$_sets ${context.tr('common_sets')}',
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textPrimary),
          ),
        ),
        Column(
          children: [
            Text(
              widget.title ?? context.tr('dashboard_program_name'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _formatElapsed(),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: _togglePause,
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _paused ? Icons.play_arrow_rounded : Icons.pause,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final total = _playlist.length;
    final done = _index;
    final progress = done / total;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('exercises_progress_completed', {'done': '$done', 'total': '$total'}),
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.activeGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: const Color(0xFFE2E6E2),
            color: AppColors.activeGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveExerciseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Container
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: ExerciseVideoPlayer(
                    key: _playerKey,
                    videoStoragePath: _current.storagePath,
                    backgroundColor: AppColors.primaryDark,
                    accentColor: AppColors.activeGreen,
                    autoPlay: true,
                    paused: _paused,
                    onPlaybackCompleted: _onVideoCompleted,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr('exercises_active_badge'),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _current.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              children: [
                TextSpan(text: '${context.tr('exercises_set_prefix')} '),
                TextSpan(
                  text: '$_currentSet ${context.tr('exercises_of')} $_sets',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Target Rest Time Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.activeGreenBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "45s",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.activeGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('exercises_target_rest_time'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('exercises_rest_starts_hint'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextTile(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fitness_center, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('exercises_complete_set'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _goToNextExercise,
            child: Text(
              context.tr('exercises_skip_exercise'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. WORKOUT COMPLETE SCREEN (Right Image)
// =============================================================================
class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Trophy Icon Container
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2F3CE),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          color: AppColors.activeGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDark, size: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('exercises_workout_complete_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        context.tr('exercises_workout_complete_body', {'program': context.tr('dashboard_program_name')}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 Grid Stats
                    Row(
                      children: [
                        Expanded(child: _buildStatTile(context.tr('exercises_total_duration'), "42m 15s", Icons.timer_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatTile(context.tr('exercises_calories_burned'), "320 kcal", Icons.local_fire_department_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatTile(context.tr('exercises_sets_completed'), context.tr('exercises_fraction', {'a': '15', 'b': '15'}), Icons.assignment_outlined, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatTile(context.tr('exercises_total_reps'), '168 ${context.tr('common_reps')}', Icons.refresh_rounded, const Color(0xFFEBF5E8), AppColors.activeGreen)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Completed Exercises Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('exercises_completed_exercises_title'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          context.tr('exercises_count_of_count', {'a': '5', 'b': '5'}),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.activeGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildCompletedExerciseTile(context.tr('exercise_name_bench_press'), '3 ${context.tr('common_sets')} • 10 ${context.tr('common_reps')} • 135 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_squats'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 185 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_leg_press'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 270 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_romanian_deadlifts'), '3 ${context.tr('common_sets')} • 12 ${context.tr('common_reps')} • 155 lbs'),
                    const SizedBox(height: 8),
                    _buildCompletedExerciseTile(context.tr('exercise_name_shoulder_press'), '3 ${context.tr('common_sets')} • 10 ${context.tr('common_reps')} • 95 lbs'),
                  ],
                ),
              ),
            ),
            _buildBottomControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color iconBgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedExerciseTile(String title, String details) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fitness_center, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: AppColors.activeGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              child: Text(
                context.tr('common_done'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {},
            child: Text(
              context.tr('exercises_share_summary'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}