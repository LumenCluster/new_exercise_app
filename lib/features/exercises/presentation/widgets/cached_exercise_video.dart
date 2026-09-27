import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

/// Storage paths currently being saved to the cache, so the same video
/// isn't downloaded twice at once.
final _downloading = <String>{};

/// Creates a controller for the exercise video at Firebase Storage [path].
///
/// If the video was already saved locally it plays from that file, so
/// replays (seeking back to the start) are instant. Otherwise it streams
/// right away — no waiting for a full download — and saves a local copy in
/// the background for next time. Web has no file system, so it always
/// streams.
Future<VideoPlayerController> createCachedVideoController(String path) async {
  final ref = FirebaseStorage.instance.ref(path);
  if (!kIsWeb) {
    final file = await _cacheFileFor(path);
    if (await file.exists()) return VideoPlayerController.file(file);
    _saveInBackground(ref, file);
  }
  return VideoPlayerController.networkUrl(Uri.parse(await ref.getDownloadURL()));
}

Future<File> _cacheFileFor(String path) async {
  final dir = await getTemporaryDirectory();
  final fileName = path.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return File('${dir.path}/exercise_videos/$fileName');
}

Future<void> _saveInBackground(Reference ref, File file) async {
  if (!_downloading.add(ref.fullPath)) return;
  try {
    // Download to a temp name first so an interrupted download is never
    // mistaken for a complete cached video.
    final partial = File('${file.path}.part');
    await partial.parent.create(recursive: true);
    await ref.writeToFile(partial);
    await partial.rename(file.path);
  } catch (_) {
    // Caching is best-effort; the video still streams next time.
  } finally {
    _downloading.remove(ref.fullPath);
  }
}
