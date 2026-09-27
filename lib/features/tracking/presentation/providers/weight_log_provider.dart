import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';

class WeightLogEntry {
  final String date; // yyyy-MM-dd
  final double weight;
  const WeightLogEntry(this.date, this.weight);
}

/// Daily weight check-ins, oldest first, backed by the database so the
/// Report screen can chart real progress over time.
class WeightLogProvider extends ChangeNotifier {
  List<WeightLogEntry> history = [];
  bool loaded = false;

  String get todayKey => DateTime.now().toIso8601String().split('T').first;

  bool get hasLoggedToday => history.isNotEmpty && history.last.date == todayKey;

  double? get latestWeight => history.isNotEmpty ? history.last.weight : null;

  Future<void> load() async {
    final rows = await FirestoreService().getWeightHistory();
    history = rows
        .map((r) => WeightLogEntry(r['date'] as String, (r['weight'] as num).toDouble()))
        .toList();
    loaded = true;
    notifyListeners();
  }

  Future<void> logWeight(double weight) async {
    final date = todayKey;
    await FirestoreService().logWeight(date, weight);
    final idx = history.indexWhere((e) => e.date == date);
    if (idx >= 0) {
      history[idx] = WeightLogEntry(date, weight);
    } else {
      history.add(WeightLogEntry(date, weight));
      history.sort((a, b) => a.date.compareTo(b.date));
    }
    notifyListeners();
  }
}
