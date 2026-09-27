import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../exercises/data/datasources/goal_video_remote_data_source.dart';
import '../../../exercises/domain/entities/workout_video.dart';
import '../../../exercises/presentation/active_workout_screen.dart';
import '../../../tracking/presentation/providers/workout_progress_provider.dart';

const _primaryDark = Color(0xFF1B2A26);
const _heroDark = Color(0xFF14231C);
const _heroWarm = Color(0xFF5A4632);
const _activeGreen = Color(0xFF8CC63F);
const _rowGrey = Color(0xFFF1F1EF);
const _textPrimary = Color(0xFF1B2A26);
const _textSecondary = Color(0xFF757575);

/// A workout category chip and the Firebase Storage goal folder its
/// exercises are listed from.
typedef _WorkoutCategory = ({String labelKey, String sourceGoal});

/// Every category reads the "muscle gain" folder until per-category
/// folders exist in Firebase Storage — change `sourceGoal` here then.
const List<_WorkoutCategory> _categories = [
  (labelKey: 'workout_full_body', sourceGoal: 'muscle_gain'),
  (labelKey: 'workout_abs', sourceGoal: 'muscle_gain'),
  (labelKey: 'workout_upper', sourceGoal: 'muscle_gain'),
  (labelKey: 'workout_hiit', sourceGoal: 'muscle_gain'),
  (labelKey: 'workout_chest', sourceGoal: 'muscle_gain'),
];

/// Shows a banner for the user's onboarding [primaryGoal], then category
/// chips (Full Body selected by default) and the videos in the selected
/// category's Firebase Storage folder; tapping one opens
/// [ActiveWorkoutScreen] with the whole list as the workout. Only the opened
/// video is downloaded, so the dashboard doesn't fetch all of them up front.
class StorageVideosSection extends StatefulWidget {
  final String? primaryGoal;

  /// Localization key for the section heading.
  final String titleKey;

  /// Optional widget shown at the right of the heading (e.g. "Adjust Plan").
  final Widget? trailing;

  const StorageVideosSection({
    super.key,
    required this.primaryGoal,
    this.titleKey = 'dashboard_exercise_videos_title',
    this.trailing,
  });

  String get goalLabelKey => GoalVideoRemoteDataSource.labelKeyFor(primaryGoal);

  @override
  State<StorageVideosSection> createState() => _StorageVideosSectionState();
}

class _StorageVideosSectionState extends State<StorageVideosSection> {
  int _selectedCategory = 0; // Full Body
  List<WorkoutVideo> _videos = [];
  bool _loading = true;
  bool _failed = false;

  /// Videos already listed, keyed by Storage folder, so switching between
  /// categories that share a folder doesn't list it again.
  final Map<String, List<WorkoutVideo>> _cache = {};

  _WorkoutCategory get _category => _categories[_selectedCategory];
  String get _folder => GoalVideoRemoteDataSource.folderFor(_category.sourceGoal);

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _selectCategory(int index) {
    if (index == _selectedCategory) return;
    setState(() => _selectedCategory = index);
    _loadVideos();
  }

  /// Feeds the workout size to the Active Program card (time and progress).
  void _reportExerciseCount() {
    context.read<WorkoutProgressProvider>().setExerciseCount(_videos.length);
  }

  Future<void> _loadVideos() async {
    final folder = _folder;
    final cached = _cache[folder];
    if (cached != null) {
      setState(() {
        _videos = cached;
        _loading = false;
        _failed = false;
      });
      _reportExerciseCount();
      return;
    }
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final videos = await GoalVideoRemoteDataSource.fetch(_category.sourceGoal);
      _cache[folder] = videos;
      if (!mounted || folder != _folder) return; // stale load for a previous category
      setState(() {
        _videos = videos;
        _loading = false;
      });
      _reportExerciseCount();
    } catch (_) {
      if (!mounted || folder != _folder) return; // stale load for a previous category
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  /// Starts a workout with every video in the selected category, beginning
  /// at the tapped one.
  void _openVideo(int index) {
    _pushWorkout(_videos, index, context.tr(_category.labelKey));
  }

  void _pushWorkout(List<WorkoutVideo> videos, int startIndex, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutScreen(
          videos: videos,
          startIndex: startIndex,
          title: title,
        ),
      ),
    );
  }

  bool _openingGoal = false;

  /// Opens the workout for the user's onboarding goal (the banner), listing
  /// that goal's own Storage folder rather than the selected chip's.
  Future<void> _openGoalWorkout() async {
    if (_openingGoal) return;
    final goal = widget.primaryGoal;
    final folder = GoalVideoRemoteDataSource.folderFor(goal);
    var videos = _cache[folder];
    if (videos == null) {
      setState(() => _openingGoal = true);
      try {
        videos = await GoalVideoRemoteDataSource.fetch(goal);
        _cache[folder] = videos;
      } catch (_) {
        videos = null;
      }
      if (!mounted) return;
      setState(() => _openingGoal = false);
    }
    if (videos == null || videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr(
            videos == null ? 'dashboard_exercise_videos_load_error' : 'dashboard_exercise_videos_empty',
          )),
        ),
      );
      return;
    }
    _pushWorkout(videos, 0, context.tr(widget.goalLabelKey));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr(widget.titleKey),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        const SizedBox(height: 12),
        _buildHeroCard(),
        const SizedBox(height: 14),
        _buildCategoryChips(),
        const SizedBox(height: 12),
        _buildExercisesCard(),
      ],
    );
  }

  // Large banner summarising the goal workout.
  Widget _buildHeroCard() {
    final goal = context.tr(widget.goalLabelKey);

    return GestureDetector(
      onTap: _openGoalWorkout,
      child: Container(
        height: 190,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [_heroWarm, _heroDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -10,
              child: Icon(
                Icons.fitness_center_rounded,
                size: 170,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: _activeGreen,
                child: _openingGoal
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: _heroPill(label: goal)),
                      const SizedBox(width: 8),
                      _heroPill(
                        icon: Icons.access_time_rounded,
                        label: context.tr('dashboard_minutes_short', {
                          'n': '${context.watch<WorkoutProgressProvider>().durationMinutes}',
                        }),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Right inset keeps the text clear of the play badge.
                  Padding(
                    padding: const EdgeInsets.only(right: 52),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr('dashboard_personalized_for_your_goals'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPill({required String label, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Horizontally scrolling category chips; the selected one is filled.
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategory;
          return GestureDetector(
            onTap: () => _selectCategory(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _primaryDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isSelected ? _primaryDark : Colors.black12),
              ),
              child: Text(
                context.tr(_categories[index].labelKey),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : _textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // White card listing each exercise video plus the start button.
  Widget _buildExercisesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('dashboard_goal_exercises', {'goal': context.tr(_category.labelKey)}),
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: _primaryDark)),
      );
    }
    if (_failed) {
      return Center(
        child: Column(
          children: [
            Text(
              context.tr('dashboard_exercise_videos_load_error'),
              style: const TextStyle(fontSize: 11, color: _textSecondary),
            ),
            TextButton(onPressed: _loadVideos, child: Text(context.tr('common_retry'))),
          ],
        ),
      );
    }
    if (_videos.isEmpty) {
      return Text(
        context.tr('dashboard_exercise_videos_empty'),
        style: const TextStyle(fontSize: 11, color: _textSecondary),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < _videos.length; i++) ...[
          _buildExerciseRow(i),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 6),
        _buildStartButton(),
      ],
    );
  }

  Widget _buildExerciseRow(int index) {
    return GestureDetector(
      onTap: () => _openVideo(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _rowGrey,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: _activeGreen, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _videos[index].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('dashboard_exercise_step', {
                      'n': '${index + 1}',
                      'total': '${_videos.length}',
                    }),
                    style: const TextStyle(fontSize: 10, color: _textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _openVideo(0),
        icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
        label: Text(context.tr('dashboard_start_todays_session')),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black26,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
