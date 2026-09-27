import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/profile/domain/entities/user_profile.dart';

/// Firestore-backed persistence for per-user app data: profile, the daily
/// weight/water logs, and the generic AI-plan cache. Each device is
/// identified by an anonymous Firebase Auth user, so data lives at
/// `users/{uid}` and is scoped to that uid by Firestore security rules.
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  Future<String>? _uidFuture;

  Future<String> get _uid {
    return _uidFuture ??= _signIn();
  }

  Future<String> _signIn() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
    return user!.uid;
  }

  Future<DocumentReference<Map<String, dynamic>>> get _userDoc async {
    final uid = await _uid;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  Future<CollectionReference<Map<String, dynamic>>> _subcollection(String name) async {
    final userDoc = await _userDoc;
    return userDoc.collection(name);
  }

  /// Daily weight check-in, keyed by yyyy-MM-dd.
  Future<void> logWeight(String date, double weight) async {
    final col = await _subcollection('weight_logs');
    await col.doc(date).set({'weight': weight});
  }

  Future<double?> getWeightForDate(String date) async {
    final col = await _subcollection('weight_logs');
    final snap = await col.doc(date).get();
    final weight = snap.data()?['weight'];
    return (weight as num?)?.toDouble();
  }

  /// Full weight history, oldest first.
  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    final col = await _subcollection('weight_logs');
    final snap = await col.orderBy(FieldPath.documentId).get();
    return snap.docs.map((d) => {'date': d.id, 'weight': d.data()['weight']}).toList();
  }

  /// Glasses of water logged for a given day, keyed by yyyy-MM-dd.
  Future<void> setWaterGlasses(String date, int glasses) async {
    final col = await _subcollection('water_logs');
    await col.doc(date).set({'glasses': glasses});
  }

  Future<int?> getWaterGlasses(String date) async {
    final col = await _subcollection('water_logs');
    final snap = await col.doc(date).get();
    return (snap.data()?['glasses'] as num?)?.toInt();
  }

  Future<void> setWorkoutSetsPlayed(String date, int sets) async {
    final col = await _subcollection('workout_logs');
    await col.doc(date).set({'setsPlayed': sets});
  }

  Future<int?> getWorkoutSetsPlayed(String date) async {
    final col = await _subcollection('workout_logs');
    final snap = await col.doc(date).get();
    return (snap.data()?['setsPlayed'] as num?)?.toInt();
  }

  /// Records a meal as eaten on [date], keyed by the meal's cache key.
  Future<void> logMeal(String date, String mealKey, int calories) async {
    final col = await _subcollection('meal_logs');
    await col.doc(date).set({
      'meals': {mealKey: calories},
    }, SetOptions(merge: true));
  }

  /// Cache keys of the meals logged on [date].
  Future<Set<String>> getLoggedMeals(String date) async {
    final col = await _subcollection('meal_logs');
    final snap = await col.doc(date).get();
    final meals = snap.data()?['meals'] as Map<String, dynamic>?;
    return meals?.keys.toSet() ?? {};
  }

  /// Stores one finished (or left early) workout session.
  Future<void> addWorkoutSession(Map<String, dynamic> session) async {
    final col = await _subcollection('workout_sessions');
    await col.add({...session, 'createdAt': FieldValue.serverTimestamp()});
  }

  /// Every recorded workout session, newest first.
  Future<List<Map<String, dynamic>>> getWorkoutSessions() async {
    final col = await _subcollection('workout_sessions');
    final snap = await col.orderBy('startedAt', descending: true).get();
    return [for (final doc in snap.docs) doc.data()];
  }

  /// Dates (yyyy-MM-dd) on which the user played at least one workout set.
  Future<List<String>> getActiveWorkoutDates() async {
    final col = await _subcollection('workout_logs');
    final snap = await col.where('setsPlayed', isGreaterThan: 0).get();
    return [for (final doc in snap.docs) doc.id];
  }

  /// Generic string cache, used to remember AI-generated content (e.g. a
  /// day's meal/workout plan) so it isn't regenerated more than once per day.
  Future<void> setCacheValue(String key, String value) async {
    final col = await _subcollection('cache');
    await col.doc(key).set({'value': value});
  }

  Future<String?> getCacheValue(String key) async {
    final col = await _subcollection('cache');
    final snap = await col.doc(key).get();
    return snap.data()?['value'] as String?;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final userDoc = await _userDoc;
    await userDoc.set({'profile': profile.toJson()}, SetOptions(merge: true));
  }

  Future<UserProfile?> getProfile() async {
    final userDoc = await _userDoc;
    final snap = await userDoc.get();
    final data = snap.data()?['profile'];
    if (data == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<void> _deleteAll(CollectionReference<Map<String, dynamic>> col) async {
    final snap = await col.get();
    if (snap.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Used by "Restart Data": wipes logged progress and generated-plan
  /// cache, but keeps the profile so onboarding isn't repeated.
  Future<void> clearTrackingData() async {
    await _deleteAll(await _subcollection('weight_logs'));
    await _deleteAll(await _subcollection('water_logs'));
    await _deleteAll(await _subcollection('cache'));
  }

  /// Used by "Delete Data": wipes everything, including the profile, so
  /// the app falls back to onboarding on next launch.
  Future<void> clearAllData() async {
    final userDoc = await _userDoc;
    await userDoc.set({'profile': FieldValue.delete()}, SetOptions(merge: true));
    await _deleteAll(await _subcollection('cache'));
    await _deleteAll(await _subcollection('weight_logs'));
    await _deleteAll(await _subcollection('water_logs'));
  }
}
