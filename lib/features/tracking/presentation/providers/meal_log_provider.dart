import 'package:flutter/foundation.dart';
import 'package:untitled/core/database/firestore_service.dart';

/// Tracks the days on which the user logged a meal, so the Dashboard's
/// streak updates as soon as a meal is logged.
class MealLogProvider extends ChangeNotifier {
  /// Dates (yyyy-MM-dd) with at least one logged meal.
  Set<String> loggedDates = {};
  bool loaded = false;

  String get _todayKey => DateTime.now().toIso8601String().split('T').first;

  Future<void> load() async {
    loggedDates = (await FirestoreService().getMealLogDates()).toSet();
    loaded = true;
    notifyListeners();
  }

  /// Records [mealKey] as eaten today.
  Future<void> logMeal(String mealKey, int calories) async {
    final today = _todayKey;
    await FirestoreService().logMeal(today, mealKey, calories);
    loggedDates.add(today);
    notifyListeners();
  }
}
