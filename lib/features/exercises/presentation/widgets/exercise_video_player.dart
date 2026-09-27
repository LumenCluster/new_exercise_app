import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/localization/app_localizations.dart';
import 'cached_exercise_video.dart';

/// Streams and plays an exercise's demo video from Firebase Storage,
/// given its [videoStoragePath]. Shared by [ExerciseDetailScreen] and
/// [ActiveWorkoutScreen] so both get the same loading/error/retry behavior.
class ExerciseVideoPlayer extends StatefulWidget {
  final String? videoStoragePath;
  final Color backgroundColor;
  final Color accentColor;

  /// Start playing as soon as the video is loaded.
  final bool autoPlay;

  /// Pauses playback while true and resumes when it goes back to false.
  final bool paused;

  /// Called every time the video plays through to the end. Return true to
  /// play it again from the start, false to stop. When null the video simply
  /// loops forever.
  final bool Function()? onPlaybackCompleted;

  const ExerciseVideoPlayer({
    super.key,
    required this.videoStoragePath,
    this.backgroundColor = const Color(0xFF1B2A26),
    this.accentColor = const Color(0xFF8CC63F),
    this.autoPlay = false,
    this.paused = false,
    this.onPlaybackCompleted,
  });

  @override
  State<ExerciseVideoPlayer> createState() => ExerciseVideoPlayerState();
}

class ExerciseVideoPlayerState extends State<ExerciseVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _loading = false;
  bool _failed = false;
  bool _wasCompleted = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoStoragePath != widget.videoStoragePath) {
      _disposeControllers();
      _initVideo();
    } else if (oldWidget.paused != widget.paused) {
      widget.paused ? _videoController?.pause() : _videoController?.play();
    }
  }

  /// Jumps back to the start of the video and plays it (unless paused).
  void restart() {
    final controller = _videoController;
    if (controller == null) return;
    controller.seekTo(Duration.zero);
    if (!widget.paused) controller.play();
  }

  void _onVideoTick() {
    final controller = _videoController;
    if (controller == null || widget.onPlaybackCompleted == null) return;
    final completed = controller.value.isCompleted;
    if (completed && !_wasCompleted) {
      _wasCompleted = true;
      if (widget.onPlaybackCompleted!()) restart();
    } else if (!completed) {
      _wasCompleted = false;
    }
  }

  void _disposeControllers() {
    _videoController?.removeListener(_onVideoTick);
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    _wasCompleted = false;
  }

  Future<void> _initVideo() async {
    final path = widget.videoStoragePath;
    if (path == null) return;

    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      final videoController = await createCachedVideoController(path);
      await videoController.initialize();
      // Unmounted, or switched to another video while this one was loading.
      if (!mounted || path != widget.videoStoragePath) {
        videoController.dispose();
        return;
      }

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: widget.autoPlay && !widget.paused,
        // With a completion callback we replay manually so each play-through
        // can be counted.
        looping: widget.onPlaybackCompleted == null,
        // Replays seek back to the start; don't flash a spinner while that
        // happens (the first load has its own loader above).
        bufferingBuilder: widget.onPlaybackCompleted == null ? null : (_) => const SizedBox.shrink(),
        aspectRatio: videoController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.accentColor,
          handleColor: widget.accentColor,
          bufferedColor: Colors.white54,
          backgroundColor: Colors.white24,
        ),
      );
      videoController.addListener(_onVideoTick);

      setState(() {
        _videoController = videoController;
        _chewieController = chewieController;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || path != widget.videoStoragePath) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoStoragePath == null) {
      return _buildFallback(context.tr('exercises_video_unavailable'));
    }
    if (_loading) {
      return Container(
        color: widget.backgroundColor,
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_failed || _chewieController == null) {
      return _buildFallback(context.tr('exercises_video_load_error'), retry: _initVideo);
    }
    return Chewie(controller: _chewieController!);
  }

  Widget _buildFallback(String message, {VoidCallback? retry}) {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.self_improvement, size: 40, color: Colors.white54),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ),
            if (retry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: retry,
                child: Text(context.tr('common_retry'), style: TextStyle(color: widget.accentColor)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
