import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/exercise_model.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseModel>> getExercises();
}

/// Reads the shared `exercises` collection seeded by tool/seed_exercises.dart.
/// Firestore rules only allow authenticated reads, so this makes sure an
/// (anonymous) user is signed in first.
class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExerciseRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<ExerciseModel>> getExercises() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    final snap = await _firestore.collection('exercises').get();
    return snap.docs
        .map((doc) => ExerciseModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}
