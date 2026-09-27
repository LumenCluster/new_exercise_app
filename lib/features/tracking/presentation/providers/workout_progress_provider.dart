import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';

/// One visit to the workout player in which at least one set was played.
class WorkoutSession {
  final String title;
  final String date; // yyyy-MM-dd
  final DateTime startedAt;
  final int durationSeconds;
  final int sets;

  const WorkoutSession({
    required this.title,
    required this.date,
    required this.startedAt,
    required this.durationSeconds,
    required this.sets,
  });

  factory WorkoutSession.fromMap(Map<String, dynamic> map) => WorkoutSession(
        title: map['title'] as String? ?? '',
        date: map['date'] as String,
        startedAt: DateTime.parse(map['startedAt'] as String),
        durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
        sets: (map['sets'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'date': date,
        'startedAt': startedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'sets': sets,
      };

  int get minutes => (durationSeconds / 60).ceil();
}

/// Tracks the user's workouts: today's sets (one play-through of a video =
/// one set), the days they were active, and every recorded session.
/// Persisted in Firestore so the Dashboard and Report stay in sync.
class WorkoutProgressProvider extends ChangeNotifier {
  /// Every exercise is played this many times (one play-through = one set).
  static const setsPerExercise = 12;

  /// Length of each exercise video.
  static const secondsPerSet = 10;

  /// Length of the program shown on the Active Program card.
  static const programDays = 30;

  /// MET value for moderate strength / circuit training, used to estimate
  /// calories burned from active time and body weight.
  static const _workoutMet = 6.0;

  int exerciseCount = 0;
  int setsPlayed = 0;
  bool loaded = false;

  /// Dates (yyyy-MM-dd) with at least one set played, including today once
  /// the user plays a set.
  Set<String> activeDates = {};

  /// Recorded sessions, newest first.
  List<WorkoutSession> sessions = [];

  static String dateKey(DateTime date) => date.toIso8601String().split('T').first;

  String get _todayKey => dateKey(DateTime.now());

  /// Days before today on which the user played at least one set.
  int get pastActiveDays => activeDates.where((date) => date != _todayKey).length;

  /// The program day the user is on: every earlier day they worked out
  /// counts, and today is the next one (so a new user is on day 1).
  int get programDay => (pastActiveDays + 1).clamp(1, programDays);

  int get totalSets => exerciseCount * setsPerExercise;

  /// Total workout time: every video × 12 sets × 10 s, in whole minutes.
  int get durationMinutes => (totalSets * secondsPerSet / 60).ceil();

  /// Share of today's sets played, 0–1.
  double get progress => totalSets == 0 ? 0 : (setsPlayed / totalSets).clamp(0.0, 1.0);

  /// Estimated calories burned in [durationSeconds] of training.
  static int kcalBurned(int durationSeconds, double weightKg) =>
      (_workoutMet * weightKg * durationSeconds / 3600).round();

  Future<void> load() async {
    final service = FirestoreService();
    final today = _todayKey;
    final results = await Future.wait([
      service.getWorkoutSetsPlayed(today),
      service.getActiveWorkoutDates(),
      service.getWorkoutSessions(),
    ]);
    setsPlayed = results[0] as int? ?? 0;
    activeDates = (results[1] as List<String>).toSet();
    sessions = [
      for (final map in results[2] as List<Map<String, dynamic>>) WorkoutSession.fromMap(map),
    ];
    loaded = true;
    notifyListeners();
  }

  /// Called when the dashboard's workout list is (re)loaded.
  void setExerciseCount(int count) {
    if (count == exerciseCount) return;
    exerciseCount = count;
    notifyListeners();
  }

  /// Called each time the user finishes a set (a video play-through).
  Future<void> addSetPlayed() async {
    setsPlayed++;
    activeDates.add(_todayKey);
    notifyListeners();
    await FirestoreService().setWorkoutSetsPlayed(_todayKey, setsPlayed);
  }

  /// Called when the user leaves or finishes the workout player.
  Future<void> recordSession({
    required String title,
    required DateTime startedAt,
    required int durationSeconds,
    required int sets,
  }) async {
    if (sets <= 0) return;
    final session = WorkoutSession(
      title: title,
      date: dateKey(startedAt),
      startedAt: startedAt,
      durationSeconds: durationSeconds,
      sets: sets,
    );
    sessions.insert(0, session);
    notifyListeners();
    await FirestoreService().addWorkoutSession(session.toMap());
  }
}
