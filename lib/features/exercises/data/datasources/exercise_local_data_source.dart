import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise_model.dart';

abstract class ExerciseLocalDataSource {
  Future<List<ExerciseModel>> getExercises();
}

class ExerciseLocalDataSourceImpl implements ExerciseLocalDataSource {
  @override
  Future<List<ExerciseModel>> getExercises() async {
    final raw = await rootBundle.loadString('assets/stretching_exercises.json');
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
