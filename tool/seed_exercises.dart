// One-time admin script: uploads the exercise demo videos to Firebase
// Storage and seeds Firestore's `exercises` collection from
// assets/stretching_exercises.json + the matched video paths.
//
// Run with: dart run tool/seed_exercises.dart
//
// Talks to Firebase over plain REST (Identity Toolkit + Firestore + Storage
// REST APIs), signing in anonymously with the app's public web API key —
// no Firebase CLI, gcloud, or service account needed. Requires the
// `exercises` (Firestore) and `exercise_videos/` (Storage) paths to
// temporarily allow authenticated writes — see the printed rules below.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _apiKey = 'AIzaSyA9uDHtLWoKHWovvNY6EU_ekpdULt1q-6M';
const _projectId = 'noorish-hub-and-exercise';
const _bucket = 'noorish-hub-and-exercise.firebasestorage.app';
const _videoRoot = r'D:\exercise videos';

String _normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');

Future<String> _signInAnonymously() async {
  final res = await http.post(
    Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'returnSecureToken': true}),
  );
  if (res.statusCode != 200) {
    throw Exception('Anonymous sign-in failed: ${res.statusCode} ${res.body}');
  }
  return (jsonDecode(res.body) as Map<String, dynamic>)['idToken'] as String;
}

Map<String, File> _findVideos() {
  final dir = Directory(_videoRoot);
  if (!dir.existsSync()) {
    throw Exception('Video folder not found: $_videoRoot');
  }
  final byNormalizedName = <String, File>{};
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.toLowerCase().endsWith('.mp4')) continue;
    final base = entity.uri.pathSegments.last.replaceAll('.mp4', '');
    // Strip a leading "N. " ordering prefix, e.g. "3. Standing Toe Touch" -> "Standing Toe Touch".
    final name = base.replaceFirst(RegExp(r'^\d+\.\s*'), '');
    byNormalizedName[_normalize(name)] = entity;
  }
  return byNormalizedName;
}

Object? _firestoreValue(dynamic v) {
  if (v == null) return {'nullValue': null};
  if (v is String) return {'stringValue': v};
  if (v is bool) return {'booleanValue': v};
  if (v is int) return {'integerValue': '$v'};
  if (v is double) return {'doubleValue': v};
  if (v is List) {
    return {
      'arrayValue': {
        'values': v.map(_firestoreValue).toList(),
      },
    };
  }
  throw Exception('Unsupported Firestore value type: ${v.runtimeType}');
}

Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> json) {
  return json.map((k, v) => MapEntry(k, _firestoreValue(v)));
}

Future<void> _uploadVideo(String idToken, String exerciseId, File file) async {
  final objectPath = Uri.encodeComponent('exercise_videos/$exerciseId.mp4');
  final res = await http.post(
    Uri.parse('https://firebasestorage.googleapis.com/v0/b/$_bucket/o?uploadType=media&name=$objectPath'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'video/mp4',
    },
    body: await file.readAsBytes(),
  );
  if (res.statusCode != 200) {
    throw Exception('Upload failed for $exerciseId: ${res.statusCode} ${res.body}');
  }
}

Future<void> _writeExerciseDoc(String idToken, String exerciseId, Map<String, dynamic> fields) async {
  final res = await http.patch(
    Uri.parse('https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/exercises/$exerciseId'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'fields': _toFirestoreFields(fields)}),
  );
  if (res.statusCode != 200) {
    throw Exception('Firestore write failed for $exerciseId: ${res.statusCode} ${res.body}');
  }
}

Future<void> main() async {
  stdout.writeln('Signing in anonymously...');
  final idToken = await _signInAnonymously();

  stdout.writeln('Scanning $_videoRoot for videos...');
  final videos = _findVideos();
  stdout.writeln('Found ${videos.length} video files.');

  stdout.writeln('Loading assets/stretching_exercises.json...');
  final raw = await File('assets/stretching_exercises.json').readAsString();
  final exercises = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

  final matchedVideoKeys = <String>{};
  var uploaded = 0;
  var skippedNoVideo = 0;

  for (final exercise in exercises) {
    final id = exercise['id'] as String;
    final name = exercise['name'] as String;
    final videoFile = videos[_normalize(name)];

    final fields = Map<String, dynamic>.from(exercise);
    if (videoFile != null) {
      matchedVideoKeys.add(_normalize(name));
      final storagePath = 'exercise_videos/$id.mp4';
      stdout.writeln('Uploading video for "$name" -> $storagePath ...');
      await _uploadVideo(idToken, id, videoFile);
      fields['videoStoragePath'] = storagePath;
      uploaded++;
    } else {
      fields['videoStoragePath'] = null;
      skippedNoVideo++;
      stdout.writeln('No video match for "$name" — seeding without video.');
    }

    await _writeExerciseDoc(idToken, id, fields);
  }

  final unusedVideos = videos.keys.toSet().difference(matchedVideoKeys);
  if (unusedVideos.isNotEmpty) {
    stdout.writeln('\nWARNING: ${unusedVideos.length} video file(s) did not match any exercise name:');
    for (final key in unusedVideos) {
      stdout.writeln('  - ${videos[key]!.path}');
    }
  }

  stdout.writeln('\nDone. Seeded ${exercises.length} exercises ($uploaded with video, $skippedNoVideo without).');
}
