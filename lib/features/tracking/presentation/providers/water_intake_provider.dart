import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';

/// Tracks today's water intake and persists it, so the Dashboard's water
/// tracker and the Report screen's water card always agree.
class WaterIntakeProvider extends ChangeNotifier {
  final int targetGlasses;

  int glasses = 0;
  bool loaded = false;

  WaterIntakeProvider({this.targetGlasses = 8});

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  Future<void> load() async {
    final saved = await FirestoreService().getWaterGlasses(_todayKey);
    glasses = saved ?? 0;
    loaded = true;
    notifyListeners();
  }

  Future<void> setGlasses(int value) async {
    glasses = value.clamp(0, targetGlasses);
    notifyListeners();
    await FirestoreService().setWaterGlasses(_todayKey, glasses);
  }

  Future<void> addGlass() async {
    if (glasses < targetGlasses) await setGlasses(glasses + 1);
  }
}
