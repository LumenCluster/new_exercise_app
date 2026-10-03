import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../meal_plan/presentation/providers/meal_plan_provider.dart' show LoadState;
import '../../../meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import '../../../meal_plan/presentation/pages/meal_detail_screen.dart';
import '../../../tracking/presentation/providers/water_intake_provider.dart';
import '../../../tracking/presentation/providers/weight_log_provider.dart';
import '../../../tracking/presentation/providers/workout_progress_provider.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/localization/app_localizations.dart';

class _ReportColors {
  static const background = Color(0xFFF8F7F2);
  static const primaryDark = Color(0xFF14261C);
  static const activeGreen = Color(0xFF8CC63F);
  static const deepGreen = Color(0xFF5B8C2A);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const chipBg = Color(0xFFEFEFE9);
  static const goalAmber = Color(0xFFE0B04A);
  static const orange = Color(0xFFE8772E);
  static const orangeBg = Color(0xFFFFF1E6);
  static const blue = Color(0xFF3F7FE0);
  static const blueBg = Color(0xFFE8F0FC);
  static const idleGrey = Color(0xFFE6E8EE);
}

/// Weight-goal progress derived from the weight log and profile.
class _GoalProgress {
  final double? start;
  final double? current;
  final double? target;
  final double? percent;
  final String goalLabelKey;

  const _GoalProgress({this.start, this.current, this.target, this.percent, required this.goalLabelKey});
}

/// A report achievement and whether/when the user earned it.
class _Achievement {
  final String emoji;
  final String titleKey;
  final String descKey;
  final double progress; // 0–1
  final String progressLabel; // e.g. "6/10"
  final DateTime? achievedOn;

  const _Achievement(this.emoji, this.titleKey, this.descKey, this.progress, this.progressLabel, this.achievedOn);

  bool get completed => achievedOn != null;
}

class ReportScreen extends StatefulWidget {
  final UserProfile? profile;

  const ReportScreen({super.key, required this.profile});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _weekdayKeys = [
    'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu', 'weekday_fri', 'weekday_sat', 'weekday_sun',
  ];
  static const _monthKeys = [
    'report_month_jan', 'report_month_feb', 'report_month_mar', 'report_month_apr', 'report_month_may', 'report_month_jun',
    'report_month_jul', 'report_month_aug', 'report_month_sep', 'report_month_oct', 'report_month_nov', 'report_month_dec',
  ];

  int _selectedTabIndex = 0; // 0: Weight, 1: Nutrition, 2: Achievements

  /// Today and the next 6 days — the meal plan's week (Nutrition tab).
  late final List<DateTime> _weekDays;

  /// Monday → Sunday of the current calendar week (activity stats/streak).
  late final List<DateTime> _calendarWeek;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekDays = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    _calendarWeek = List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final weightProvider = context.read<WeightLogProvider>();
      final waterProvider = context.read<WaterIntakeProvider>();
      final workoutProvider = context.read<WorkoutProgressProvider>();
      await Future.wait([weightProvider.load(), waterProvider.load(), workoutProvider.load()]);
      if (!mounted) return;

      final profile = widget.profile;
      if (profile != null) {
        final mealsProvider = context.read<WeeklyMealPlanProvider>();
        for (final day in _weekDays) {
          mealsProvider.ensureMealsForDay(profile, day);
        }
      }

      if (!mounted) return;
      if (!weightProvider.hasLoggedToday) {
        _showWeightCheckInDialog(weightProvider);
      }
    });
  }

  // ==================== DATA HELPERS ====================

  String _formatDate(DateTime date) => '${context.tr(_monthKeys[date.month - 1])} ${date.day}';

  String _formatDateWithYear(DateTime date) => '${_formatDate(date)}, ${date.year}';

  /// Body weight used for calorie estimates: latest weigh-in, else profile.
  double _bodyWeight(WeightLogProvider weights) =>
      weights.latestWeight ?? widget.profile?.currentWeightKg ?? 70;

  _GoalProgress _goalProgress(WeightLogProvider weightProvider) {
    final profile = widget.profile;
    final history = weightProvider.history;
    final start = history.isNotEmpty ? history.first.weight : profile?.currentWeightKg;
    final current = history.isNotEmpty ? history.last.weight : profile?.currentWeightKg;
    final target = profile?.targetWeightKg;

    if (start == null || current == null || target == null) {
      return _GoalProgress(start: start, current: current, target: target, goalLabelKey: 'report_weight_goal');
    }
    if (profile!.goal == Goal.lose && start > target) {
      final percent = ((start - current) / (start - target)).clamp(0.0, 1.0);
      return _GoalProgress(start: start, current: current, target: target, percent: percent, goalLabelKey: 'report_weight_loss_goal');
    }
    if (profile.goal == Goal.gain && target > start) {
      final percent = ((current - start) / (target - start)).clamp(0.0, 1.0);
      return _GoalProgress(start: start, current: current, target: target, percent: percent, goalLabelKey: 'report_weight_gain_goal');
    }
    final maxDeviation = (start - target).abs().clamp(0.5, double.infinity);
    final percent = (1 - ((current - target).abs() / maxDeviation)).clamp(0.0, 1.0);
    return _GoalProgress(start: start, current: current, target: target, percent: percent, goalLabelKey: 'report_maintain_weight');
  }

  List<WorkoutSession> _sessionsThisWeek(WorkoutProgressProvider workouts) {
    final first = WorkoutProgressProvider.dateKey(_calendarWeek.first);
    final last = WorkoutProgressProvider.dateKey(_calendarWeek.last);
    return workouts.sessions.where((s) => s.date.compareTo(first) >= 0 && s.date.compareTo(last) <= 0).toList();
  }

  // ==================== WEIGHT CHECK-IN ====================

  void _showWeightCheckInDialog(WeightLogProvider provider) {
    final initial = provider.latestWeight ?? widget.profile?.currentWeightKg;
    final controller = TextEditingController(text: initial?.toStringAsFixed(1) ?? '');
    String? error;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: _ReportColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(context.tr('report_weight_checkin_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('report_weight_checkin_body'),
                    style: const TextStyle(fontSize: 12, color: _ReportColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      suffixText: 'kg',
                      errorText: error,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.tr('report_weight_checkin_skip'), style: const TextStyle(color: _ReportColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ReportColors.primaryDark,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final value = double.tryParse(controller.text.trim());
                    if (value == null || value <= 0) {
                      setDialogState(() => error = context.tr('report_weight_checkin_invalid'));
                      return;
                    }
                    provider.logWeight(value);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(context.tr('common_save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReportColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildOverallProgressCard(),
                  const SizedBox(height: 16),
                  _buildTabToggle(),
                  const SizedBox(height: 16),
                  if (_selectedTabIndex == 0) ...[
                    _buildWeightView(),
                  ] else if (_selectedTabIndex == 1) ...[
                    _buildNutritionView(),
                  ] else ...[
                    _buildAchievementsView(),
                  ],
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: AppBottomNavBar(currentTab: AppTab.report, profile: widget.profile),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 4, right: 10),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _ReportColors.textPrimary),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('report_header_title'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('report_header_subtitle'),
                style: const TextStyle(fontSize: 12, color: _ReportColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Top Progress Banner — real weight history vs. profile goal ---
  Widget _buildOverallProgressCard() {
    return Consumer<WeightLogProvider>(
      builder: (context, weightProvider, _) {
        final goal = _goalProgress(weightProvider);
        final start = goal.start;
        final current = goal.current;
        final target = goal.target;

        String? changeLabel;
        if (start != null && current != null && (start - current).abs() >= 0.05) {
          final delta = (start - current).abs().toStringAsFixed(1);
          changeLabel = context.tr(current < start ? 'report_kg_lost' : 'report_kg_gained', {'value': delta});
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _ReportColors.primaryDark,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('report_overall_progress_label'),
                          style: const TextStyle(fontSize: 9, letterSpacing: 0.5, color: Colors.white60, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(goal.goalLabelKey),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  if (goal.percent != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(goal.percent! * 100).round()} %',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ReportColors.activeGreen),
                        ),
                        Text(context.tr('report_percent_complete'), style: const TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(context.tr('dashboard_program_progress'), style: const TextStyle(fontSize: 10, color: Colors.white70)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: goal.percent ?? 0,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  color: _ReportColors.activeGreen,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      changeLabel ??
                          (current != null
                              ? context.tr('report_stat_current', {'value': current.toStringAsFixed(1)})
                              : context.tr('report_stat_current_empty')),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _ReportColors.activeGreen),
                    ),
                  ),
                  if (current != null && target != null)
                    Expanded(
                      child: Text(
                        context.tr('report_kg_to_go', {'value': (current - target).abs().toStringAsFixed(1)}),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      target != null
                          ? context.tr('report_goal_value', {'value': target.toStringAsFixed(1)})
                          : context.tr('report_stat_goal_empty'),
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _ReportColors.goalAmber),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Tab Toggle ---
  Widget _buildTabToggle() {
    final tabs = [context.tr('report_tab_weight'), context.tr('report_tab_nutrition'), context.tr('report_tab_achievements')];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _ReportColors.cardWhite,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? _ReportColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : _ReportColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==================== TAB 1: WEIGHT VIEW ====================
  Widget _buildWeightView() {
    return Consumer2<WorkoutProgressProvider, WeightLogProvider>(
      builder: (context, workouts, weights, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyStatsCard(workouts, weights),
            const SizedBox(height: 14),
            _buildWeightTimelineCard(weights),
            const SizedBox(height: 14),
            _buildWeeklyStreakCard(workouts),
            const SizedBox(height: 20),
            _buildExerciseHistory(workouts, weights),
          ],
        );
      },
    );
  }

  // Workouts / calories burned / active time for the current week.
  Widget _buildWeeklyStatsCard(WorkoutProgressProvider workouts, WeightLogProvider weights) {
    final week = _sessionsThisWeek(workouts);
    final seconds = week.fold<int>(0, (sum, s) => sum + s.durationSeconds);
    final kcal = WorkoutProgressProvider.kcalBurned(seconds, _bodyWeight(weights));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Expanded(
            child: _statColumn(
              icon: Icons.fitness_center_rounded,
              iconColor: _ReportColors.deepGreen,
              iconBg: _ReportColors.activeBgGreen,
              label: context.tr('report_stat_workouts'),
              value: '${week.length}',
              unit: context.tr('report_stat_completed'),
            ),
          ),
          Expanded(
            child: _statColumn(
              icon: Icons.local_fire_department_rounded,
              iconColor: _ReportColors.orange,
              iconBg: _ReportColors.orangeBg,
              label: context.tr('report_stat_calories'),
              value: '$kcal',
              unit: 'kcal',
            ),
          ),
          Expanded(
            child: _statColumn(
              icon: Icons.schedule_rounded,
              iconColor: _ReportColors.blue,
              iconBg: _ReportColors.blueBg,
              label: context.tr('report_stat_time'),
              value: '${(seconds / 60).round()}',
              unit: context.tr('report_stat_min'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
              Text(unit, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTimelineCard(WeightLogProvider weights) {
    final history = weights.history;
    final current = weights.latestWeight ?? widget.profile?.currentWeightKg;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('report_weight_timeline_title'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
              ),
              GestureDetector(
                onTap: () => _showWeightLogSheet(weights),
                child: Text(
                  context.tr('report_view_all'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ReportColors.activeGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                current != null
                    ? context.tr('report_current_weight_kg', {'value': current.toStringAsFixed(1)})
                    : context.tr('report_no_weighins'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showWeightCheckInDialog(weights),
                child: const Icon(Icons.edit_outlined, size: 16, color: _ReportColors.activeGreen),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (history.length < 2)
            SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  context.tr('report_weight_trend_hint'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 130,
              width: double.infinity,
              child: CustomPaint(
                painter: _WeightChartPainter(
                  weights: history.map((e) => e.weight).toList(),
                  tooltip: '${history.last.weight.toStringAsFixed(1)} kg',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: _WeightChartPainter.axisWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _sampleDatesForLabels(history)
                    .map((e) => Text(
                          _formatDate(DateTime.parse(e.date)),
                          style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Picks up to 5 evenly-spaced entries from the weight history to label
  /// under the chart, so a long history doesn't overcrowd the axis.
  List<WeightLogEntry> _sampleDatesForLabels(List<WeightLogEntry> history) {
    if (history.length <= 5) return history;
    final step = (history.length - 1) / 4;
    return List.generate(5, (i) => history[(i * step).round()]);
  }

  void _showWeightLogSheet(WeightLogProvider weights) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ReportColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return Consumer<WeightLogProvider>(
          builder: (context, weights, _) {
            final entries = weights.history.reversed.toList();
            return _SheetScaffold(
              title: context.tr('report_weight_timeline_title'),
              action: TextButton.icon(
                onPressed: () => _showWeightCheckInDialog(weights),
                icon: const Icon(Icons.add, size: 16, color: _ReportColors.deepGreen),
                label: Text(context.tr('report_log_weight'), style: const TextStyle(color: _ReportColors.deepGreen, fontWeight: FontWeight.bold)),
              ),
              child: entries.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(context.tr('report_weight_log_empty'), style: const TextStyle(fontSize: 12, color: _ReportColors.textSecondary)),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < entries.length; i++)
                          _weightLogRow(entries[i], i + 1 < entries.length ? entries[i + 1] : null),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _weightLogRow(WeightLogEntry entry, WeightLogEntry? previous) {
    final delta = previous == null ? null : entry.weight - previous.weight;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatDateWithYear(DateTime.parse(entry.date)),
              style: const TextStyle(fontSize: 12, color: _ReportColors.textSecondary),
            ),
          ),
          if (delta != null && delta.abs() >= 0.05)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                '${delta > 0 ? '+' : '−'}${delta.abs().toStringAsFixed(1)}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: delta > 0 ? _ReportColors.orange : _ReportColors.deepGreen),
              ),
            ),
          Text(
            '${entry.weight.toStringAsFixed(1)} kg',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // Donut of active days this week plus a Mon–Sun check row.
  Widget _buildWeeklyStreakCard(WorkoutProgressProvider workouts) {
    final todayKey = WorkoutProgressProvider.dateKey(DateTime.now());
    final activeDays = _calendarWeek.where((d) => workouts.activeDates.contains(WorkoutProgressProvider.dateKey(d))).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _RingPainter(activeDays / 7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$activeDays/7', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                    Text(context.tr('report_days'), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('report_weekly_streak_title'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  context.tr('report_weekly_streak_body', {'n': '$activeDays'}),
                  style: const TextStyle(fontSize: 10, height: 1.3, color: _ReportColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (final day in _calendarWeek)
                      Expanded(
                        child: _streakDayPill(
                          day,
                          active: workouts.activeDates.contains(WorkoutProgressProvider.dateKey(day)),
                          future: WorkoutProgressProvider.dateKey(day).compareTo(todayKey) > 0,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakDayPill(DateTime day, {required bool active, required bool future}) {
    final Color bg = active ? _ReportColors.activeBgGreen : _ReportColors.idleGrey.withValues(alpha: future ? 0.5 : 1);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Icon(
            active ? Icons.check_rounded : (future ? Icons.remove_rounded : Icons.close_rounded),
            size: 12,
            color: active ? _ReportColors.deepGreen : _ReportColors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(_weekdayKeys[day.weekday - 1]),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(fontSize: 8, color: active ? _ReportColors.deepGreen : _ReportColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseHistory(WorkoutProgressProvider workouts, WeightLogProvider weights) {
    final sessions = workouts.sessions;
    final bodyWeight = _bodyWeight(weights);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('report_exercise_history_title'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
            ),
            if (sessions.isNotEmpty)
              GestureDetector(
                onTap: () => _showSessionsSheet(bodyWeight),
                child: Text(
                  context.tr('report_view_all'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ReportColors.activeGreen),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(18)),
            child: Text(
              context.tr('report_no_workouts_yet'),
              style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary),
            ),
          )
        else
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: math.min(sessions.length, 10),
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: 240,
                child: _sessionCard(sessions[index], bodyWeight),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sessionCard(WorkoutSession session, double bodyWeight) {
    final kcal = WorkoutProgressProvider.kcalBurned(session.durationSeconds, bodyWeight);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _ReportColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: _ReportColors.chipBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.fitness_center_rounded, size: 22, color: _ReportColors.primaryDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDateWithYear(session.startedAt),
                      style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _sessionChip(
                Icons.timer_outlined,
                context.tr('report_minutes_value', {'n': '${session.minutes}'}),
                _ReportColors.deepGreen,
                _ReportColors.activeBgGreen,
              ),
              const SizedBox(width: 8),
              _sessionChip(
                Icons.local_fire_department_rounded,
                context.tr('report_kcal_value', {'n': '$kcal'}),
                _ReportColors.orange,
                _ReportColors.orangeBg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sessionChip(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  void _showSessionsSheet(double bodyWeight) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _ReportColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final sessions = context.read<WorkoutProgressProvider>().sessions;
        return _SheetScaffold(
          title: context.tr('report_exercise_history_title'),
          child: Column(
            children: [
              for (final session in sessions)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(color: _ReportColors.chipBg, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.fitness_center_rounded, size: 18, color: _ReportColors.primaryDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(session.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              '${_formatDateWithYear(session.startedAt)} • ${context.tr('report_sets_value', {'n': '${session.sets}'})}',
                              style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.tr('report_minutes_value', {'n': '${session.minutes}'}),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                          ),
                          Text(
                            context.tr('report_kcal_value', {
                              'n': '${WorkoutProgressProvider.kcalBurned(session.durationSeconds, bodyWeight)}',
                            }),
                            style: const TextStyle(fontSize: 10, color: _ReportColors.orange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==================== TAB 2: NUTRITION VIEW ====================

  static const _proteinColor = Color(0xFF7FAF4E);
  static const _carbsColor = Color(0xFFF4A3A3);
  static const _fatColor = Color(0xFFF6C045);

  /// Energy in one kilogram of body weight, used to turn the weight goal
  /// into a calorie target.
  static const _kcalPerKg = 7700;

  Widget _buildNutritionView() {
    final profile = widget.profile;

    if (profile == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
        child: Text(
          context.tr('report_complete_profile_nutrition'),
          style: const TextStyle(fontSize: 12, color: _ReportColors.textSecondary),
        ),
      );
    }

    final dailyTarget = NutritionCalculator.calculateDailyTarget(profile);

    return Consumer3<WeeklyMealPlanProvider, WeightLogProvider, WorkoutProgressProvider>(
      builder: (context, mealsProvider, weightProvider, workouts, _) {
        final today = _weekDays.first;
        final weekTotals = [
          for (final day in _weekDays) mealsProvider.mealsFor(day).fold<int>(0, (sum, m) => sum + m.calories),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionReportCard(mealsProvider, today),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildWeightGoalCard(weightProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildCaloriesBurnedCard(workouts, weightProvider)),
              ],
            ),
            const SizedBox(height: 14),
            _buildWeeklyCaloriesCard(mealsProvider, weekTotals, dailyTarget.calories),
          ],
        );
      },
    );
  }

  // Today's macro split as a donut, from the generated meal plan.
  Widget _buildNutritionReportCard(WeeklyMealPlanProvider mealsProvider, DateTime today) {
    final meals = mealsProvider.mealsFor(today);
    final state = mealsProvider.stateFor(today);

    var proteinG = 0.0;
    var carbsG = 0.0;
    var fatG = 0.0;
    var totalKcal = 0;
    for (final meal in meals) {
      proteinG += meal.macros.proteinG;
      carbsG += meal.macros.carbsG;
      fatG += meal.macros.fatG;
      totalKcal += meal.calories;
    }
    final proteinCals = proteinG * 4;
    final carbsCals = carbsG * 4;
    final fatCals = fatG * 9;
    final macroCals = proteinCals + carbsCals + fatCals;
    final proteinFrac = macroCals > 0 ? proteinCals / macroCals : 0.0;
    final carbsFrac = macroCals > 0 ? carbsCals / macroCals : 0.0;
    final fatFrac = macroCals > 0 ? fatCals / macroCals : 0.0;

    String macroValue(double g, double frac) => '${g.round()}g (${(frac * 100).round()}%)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('report_nutrition_report_title'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
              ),
              if (meals.isNotEmpty)
                GestureDetector(
                  onTap: () => _showTodaysMealsSheet(today),
                  child: Text(
                    context.tr('report_view_all'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ReportColors.activeGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state == LoadState.loading)
            const SizedBox(height: 140, child: Center(child: CircularProgressIndicator(color: _ReportColors.primaryDark)))
          else if (meals.isEmpty)
            SizedBox(
              height: 60,
              child: Center(
                child: Text(context.tr('report_no_recipes_today'), style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary)),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutChartPainter(
                      segments: [
                        (proteinFrac, _proteinColor),
                        (carbsFrac, _carbsColor),
                        (fatFrac, _fatColor),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatThousands(totalKcal),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                          ),
                          const Text('kcal', style: TextStyle(fontSize: 11, color: _ReportColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMacroLegendItem(_proteinColor, context.tr('report_protein'), macroValue(proteinG, proteinFrac)),
                      const SizedBox(height: 12),
                      _buildMacroLegendItem(_carbsColor, context.tr('report_carbs'), macroValue(carbsG, carbsFrac)),
                      const SizedBox(height: 12),
                      _buildMacroLegendItem(_fatColor, context.tr('report_fats'), macroValue(fatG, fatFrac)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMacroLegendItem(Color color, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ReportColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(value, style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary)),
        ),
      ],
    );
  }

  // Current vs. target weight with the same goal % as the top card.
  Widget _buildWeightGoalCard(WeightLogProvider weightProvider) {
    final goal = _goalProgress(weightProvider);
    final current = goal.current;
    final target = goal.target;

    return _nutritionStatCard(
      icon: Icons.trending_down_rounded,
      iconColor: _ReportColors.deepGreen,
      iconBg: _ReportColors.activeBgGreen,
      label: context.tr(goal.goalLabelKey),
      value: current?.toStringAsFixed(1) ?? '—',
      suffix: target != null ? ' / ${target.toStringAsFixed(1)} kg' : ' kg',
      progress: goal.percent ?? 0,
      color: _ReportColors.activeGreen,
    );
  }

  // Calories burned in workouts vs. the energy needed to reach the weight
  // goal (kg to change × 7,700 kcal).
  Widget _buildCaloriesBurnedCard(WorkoutProgressProvider workouts, WeightLogProvider weightProvider) {
    final bodyWeight = _bodyWeight(weightProvider);
    final burned = workouts.sessions.fold<int>(
      0,
      (sum, s) => sum + WorkoutProgressProvider.kcalBurned(s.durationSeconds, bodyWeight),
    );
    final goal = _goalProgress(weightProvider);
    final kgToChange = goal.start != null && goal.target != null ? (goal.start! - goal.target!).abs() : 0.0;
    final targetKcal = (kgToChange * _kcalPerKg).round();

    return _nutritionStatCard(
      icon: Icons.local_fire_department_rounded,
      iconColor: _ReportColors.blue,
      iconBg: _ReportColors.blueBg,
      label: context.tr('report_stat_calories'),
      value: _formatThousands(burned),
      suffix: targetKcal > 0 ? ' / ${_formatThousands(targetKcal)} kcal' : ' kcal',
      progress: targetKcal > 0 ? burned / targetKcal : 0,
      color: _ReportColors.blue,
    );
  }

  Widget _nutritionStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String suffix,
    required double progress,
    required Color color,
  }) {
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: value,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                          ),
                          TextSpan(
                            text: suffix,
                            style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: clamped,
                    minHeight: 6,
                    backgroundColor: color.withValues(alpha: 0.15),
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(clamped * 100).round()}%',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _ReportColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Planned calories for each day of the meal-plan week vs. the daily goal.
  Widget _buildWeeklyCaloriesCard(WeeklyMealPlanProvider mealsProvider, List<int> weekTotals, int goalKcal) {
    const chartHeight = 160.0;
    const labelHeight = 20.0; // weekday label + gap under each bar
    const barAreaHeight = chartHeight - labelHeight;

    final loadedTotals = weekTotals.where((t) => t > 0).toList();
    final avgKcal = loadedTotals.isEmpty ? 0 : (loadedTotals.reduce((a, b) => a + b) / loadedTotals.length).round();

    // Axis top: the larger of the goal and the biggest day, rounded up to 500.
    final peak = math.max(goalKcal, weekTotals.fold<int>(0, math.max));
    final axisMax = math.max(500, (peak / 500).ceil() * 500).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('report_weekly_calories_title'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels, centred on the gridlines drawn behind the bars.
                SizedBox(
                  width: 34,
                  child: Stack(
                    children: [
                      for (var i = 0; i <= 3; i++)
                        Positioned(
                          left: 0,
                          top: barAreaHeight * (1 - i / 3) - 6,
                          child: Text(
                            _formatThousands((axisMax * i / 3).round()),
                            style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E)),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: barAreaHeight,
                        child: CustomPaint(painter: _GridPainter(lines: 4)),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(_weekDays.length, (index) {
                          final day = _weekDays[index];
                          final total = weekTotals[index];
                          final loading = mealsProvider.stateFor(day) == LoadState.loading;
                          final onTarget = goalKcal > 0 && total > 0 && (total - goalKcal).abs() <= goalKcal * 0.1;

                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (loading)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 1.5),
                                  )
                                else
                                  Container(
                                    width: 20,
                                    height: math.max(4.0, barAreaHeight * (total / axisMax)),
                                    decoration: BoxDecoration(
                                      color: onTarget ? _ReportColors.activeGreen : const Color(0xFFE3EAF2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                SizedBox(
                                  height: labelHeight,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      context.tr(_weekdayKeys[day.weekday - 1]),
                                      style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loadedTotals.isEmpty
                    ? context.tr('report_avg_dash')
                    : context.tr('report_avg_kcal', {'avg': _formatThousands(avgKcal)}),
                style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary),
              ),
              Text(
                context.tr('report_goal_kcal', {'goal': _formatThousands(goalKcal)}),
                style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "15300" -> "15,300".
  String _formatThousands(int value) =>
      value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  // Today's meals with calories and macros; tapping one opens its recipe.
  void _showTodaysMealsSheet(DateTime today) {
    const categoryKeys = ['meal_breakfast', 'meal_lunch', 'meal_dinner'];
    String categoryLabel(int index) => index < categoryKeys.length
        ? context.tr(categoryKeys[index])
        : context.tr('meal_snack_n', {'n': '${index - categoryKeys.length + 1}'});

    showModalBottomSheet(
      context: context,
      backgroundColor: _ReportColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final meals = context.read<WeeklyMealPlanProvider>().mealsFor(today);
        return _SheetScaffold(
          title: context.tr('report_nutrition_report_title'),
          child: Column(
            children: [
              for (var i = 0; i < meals.length; i++)
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MealDetailScreen(meal: meals[i], categoryLabel: categoryLabel(i)),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryLabel(i),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _ReportColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                meals[i].name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'P ${meals[i].macros.proteinG.round()}g • C ${meals[i].macros.carbsG.round()}g • F ${meals[i].macros.fatG.round()}g',
                                style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context.tr('report_kcal_value', {'n': '${meals[i].calories}'}),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.deepGreen),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: _ReportColors.textSecondary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ==================== TAB 3: ACHIEVEMENTS VIEW ====================

  /// Every achievement, evaluated against the user's real workout sessions,
  /// active days and weight progress.
  List<_Achievement> _achievements(WorkoutProgressProvider workouts, WeightLogProvider weights) {
    final sessions = [...workouts.sessions]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    final count = sessions.length;
    DateTime? nth(int n) => count >= n ? sessions[n - 1].startedAt : null;

    // Most workouts in one Mon–Sun week, and when a week first reached 3.
    final perWeek = <String, int>{};
    DateTime? threeInWeekOn;
    for (final s in sessions) {
      final d = s.startedAt;
      final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
      final key = WorkoutProgressProvider.dateKey(monday);
      perWeek[key] = (perWeek[key] ?? 0) + 1;
      if (perWeek[key] == 3) threeInWeekOn ??= d;
    }
    final bestWeek = perWeek.values.fold<int>(0, math.max);

    // Longest run of consecutive active days, and when it first hit 10.
    final days = workouts.activeDates.map(DateTime.parse).toList()..sort();
    var run = 0;
    var longestRun = 0;
    DateTime? tenInARowOn;
    for (var i = 0; i < days.length; i++) {
      run = (i > 0 && days[i].difference(days[i - 1]).inDays == 1) ? run + 1 : 1;
      longestRun = math.max(longestRun, run);
      if (run == 10) tenInARowOn ??= days[i];
    }

    // Cumulative calories burned, and when they passed 5,000.
    final bodyWeight = _bodyWeight(weights);
    var totalKcal = 0;
    DateTime? calorieClubOn;
    for (final s in sessions) {
      totalKcal += WorkoutProgressProvider.kcalBurned(s.durationSeconds, bodyWeight);
      if (totalKcal >= 5000) calorieClubOn ??= s.startedAt;
    }

    final goal = _goalProgress(weights);
    final goalReached = goal.percent != null && goal.percent! >= 1 && weights.history.isNotEmpty;

    return [
      _Achievement('⭐', 'report_achievement_first_starter_title', 'report_achievement_first_starter_desc',
          math.min(count / 1, 1), '${math.min(count, 1)}/1', nth(1)),
      _Achievement('🔥', 'report_achievement_streak_starter_title', 'report_achievement_streak_starter_desc',
          math.min(bestWeek / 3, 1), '${math.min(bestWeek, 3)}/3', threeInWeekOn),
      _Achievement('🏋️', 'report_achievement_pace_crusher_title', 'report_achievement_pace_crusher_desc',
          goal.percent ?? 0, '${((goal.percent ?? 0) * 100).round()}%',
          goalReached ? DateTime.parse(weights.history.last.date) : null),
      _Achievement('👑', 'report_achievement_consistency_king_title', 'report_achievement_consistency_king_desc',
          math.min(longestRun / 10, 1), '${math.min(longestRun, 10)}/10', tenInARowOn),
      _Achievement('💥', 'report_achievement_calorie_club_title', 'report_achievement_calorie_club_desc',
          math.min(totalKcal / 5000, 1), '${_formatThousands(math.min(totalKcal, 5000))}/5,000', calorieClubOn),
      _Achievement('💪', 'report_achievement_iron_body_title', 'report_achievement_iron_body_desc',
          math.min(count / 30, 1), '${math.min(count, 30)}/30', nth(30)),
    ];
  }

  Widget _buildAchievementsView() {
    return Consumer2<WorkoutProgressProvider, WeightLogProvider>(
      builder: (context, workouts, weights, _) {
        final achievements = _achievements(workouts, weights);
        final earned = achievements.where((a) => a.completed).toList()
          ..sort((a, b) => a.achievedOn!.compareTo(b.achievedOn!));
        final pending = achievements.where((a) => !a.completed).toList();
        // The unfinished achievement the user is closest to.
        final next = pending.isEmpty ? null : pending.reduce((a, b) => b.progress > a.progress ? b : a);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAchievementsCard(achievements, earned.length),
            const SizedBox(height: 14),
            _buildJourneyTimeline(earned, next),
            const SizedBox(height: 14),
            _buildPhotosCard(earned.length, achievements.length, next),
          ],
        );
      },
    );
  }

  Widget _buildAchievementsCard(List<_Achievement> achievements, int earnedCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('report_tab_achievements'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
              ),
              Text(
                '$earnedCount/${achievements.length}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.activeGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < achievements.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildAchievementTile(achievements[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementTile(_Achievement a) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: a.completed ? _ReportColors.activeBgGreen : const Color(0xFFF1F1EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Opacity(
              opacity: a.completed || a.progress > 0 ? 1 : 0.45,
              child: Text(a.emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(a.titleKey),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(a.descKey),
                  style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (a.completed) ...[
            Text(
              _formatDate(a.achievedOn!),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ReportColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: _ReportColors.activeGreen, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
            ),
          ] else
            SizedBox(
              width: 76,
              child: Column(
                children: [
                  Text(
                    a.progressLabel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _ReportColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: a.progress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: Colors.white,
                      color: _ReportColors.activeGreen,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Earned achievements in the order they were unlocked, then the next one.
  Widget _buildJourneyTimeline(List<_Achievement> earned, _Achievement? next) {
    final entries = <({String title, String subtitle, bool done})>[
      for (final a in earned)
        (title: context.tr(a.titleKey), subtitle: _formatDateWithYear(a.achievedOn!), done: true),
      if (next != null) (title: context.tr(next.titleKey), subtitle: next.progressLabel, done: false),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('report_journey_timeline_title'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < entries.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dot with the connecting line down to the next entry.
                  SizedBox(
                    width: 20,
                    child: Column(
                      children: [
                        const SizedBox(height: 3),
                        Container(
                          width: entries[i].done ? 10 : 7,
                          height: entries[i].done ? 10 : 7,
                          decoration: BoxDecoration(
                            color: entries[i].done ? _ReportColors.activeGreen : _ReportColors.primaryDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < entries.length - 1)
                          Expanded(
                            child: Container(width: 1.5, color: const Color(0xFFE3E7EE)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < entries.length - 1 ? 18 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entries[i].title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            entries[i].subtitle,
                            style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotosCard(int earnedCount, int total, _Achievement? next) {
    final String motivation = next == null
        ? context.tr('report_all_achievements_done')
        : context.tr('report_next_achievement', {
            'earned': '$earnedCount',
            'total': '$total',
            'name': context.tr(next.titleKey),
            'percent': '${(next.progress * 100).round()}',
          });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(color: _ReportColors.activeBgGreen, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('📸', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('report_progress_photos_title'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('report_progress_photos_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.4, color: _ReportColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _ReportColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: Colors.black26,
            ),
            child: Text(context.tr('report_add_first_photos'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF1F4EA), borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  '👍 ${context.tr('report_keep_going_title')}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  motivation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, height: 1.4, color: _ReportColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SHARED SHEET LAYOUT ====================

/// Bottom-sheet body used by the "View All" lists.
class _SheetScaffold extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;

  const _SheetScaffold({required this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ==================== CUSTOM PAINTERS ====================

/// Area line chart of weigh-ins with a y-axis and a tooltip on the latest
/// point.
class _WeightChartPainter extends CustomPainter {
  static const axisWidth = 26.0;

  final List<double> weights;
  final String tooltip;

  _WeightChartPainter({required this.weights, required this.tooltip});

  static const _green = Color(0xFF8CC63F);
  static const _lineGreen = Color(0xFF6FA83A);

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;

    var minW = weights.reduce(math.min);
    var maxW = weights.reduce(math.max);
    if (maxW - minW < 2) {
      final mid = (maxW + minW) / 2;
      minW = mid - 1;
      maxW = mid + 1;
    }
    minW = minW.floorToDouble();
    maxW = maxW.ceilToDouble();
    final range = maxW - minW;

    const topPad = 26.0; // room for the tooltip
    final chart = Rect.fromLTRB(axisWidth, topPad, size.width - 6, size.height - 4);

    // Y-axis gridlines and labels (4 ticks).
    final gridPaint = Paint()
      ..color = const Color(0xFFEFF1EC)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final value = maxW - range * i / 3;
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: value.round().toString(), style: const TextStyle(fontSize: 8, color: Color(0xFF9E9E9E))),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    final points = List.generate(weights.length, (i) {
      final x = chart.left + chart.width * (i / (weights.length - 1));
      final y = chart.bottom - chart.height * ((weights[i] - minW) / range);
      return Offset(x, y);
    });

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }

    final area = Path.from(line)
      ..lineTo(points.last.dx, chart.bottom)
      ..lineTo(points.first.dx, chart.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_green.withValues(alpha: 0.30), _green.withValues(alpha: 0.02)],
        ).createShader(chart),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = _lineGreen
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final dot = Paint()..color = _lineGreen;
    for (final p in points) {
      canvas.drawCircle(p, 3, dot);
    }

    // Tooltip bubble above the latest weigh-in.
    final last = points.last;
    final label = TextPainter(
      text: TextSpan(text: tooltip, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    final bubbleW = label.width + 14;
    final bubbleH = label.height + 8;
    final left = (last.dx - bubbleW / 2).clamp(chart.left, size.width - bubbleW);
    final top = math.max(0.0, last.dy - bubbleH - 10);
    final bubble = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, bubbleW, bubbleH), const Radius.circular(6));
    final bubblePaint = Paint()..color = const Color(0xFF14261C);
    canvas.drawRRect(bubble, bubblePaint);
    final arrowX = last.dx.clamp(left + 6, left + bubbleW - 6);
    canvas.drawPath(
      Path()
        ..moveTo(arrowX - 4, top + bubbleH)
        ..lineTo(arrowX + 4, top + bubbleH)
        ..lineTo(arrowX, top + bubbleH + 4)
        ..close(),
      bubblePaint,
    );
    label.paint(canvas, Offset(left + 7, top + 4));
    canvas.drawCircle(last, 5, Paint()..color = Colors.white);
    canvas.drawCircle(last, 3.5, dot);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.weights != weights || oldDelegate.tooltip != tooltip;
}

/// Progress ring for the weekly activity streak.
class _RingPainter extends CustomPainter {
  final double fraction;

  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = const Color(0xFFE6E8EE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = const Color(0xFF5B8C2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.fraction != fraction;
}

/// Thick donut made of consecutive coloured segments (fractions sum to 1).
class _DonutChartPainter extends CustomPainter {
  final List<(double, Color)> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 24.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    var start = -math.pi / 2; // 12 o'clock
    for (final (fraction, color) in segments) {
      if (fraction <= 0) continue;
      final sweep = fraction * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Evenly spaced dashed horizontal gridlines behind the weekly bars.
class _GridPainter extends CustomPainter {
  final int lines;

  const _GridPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDEFF2)
      ..strokeWidth = 1;
    for (var i = 0; i < lines; i++) {
      final y = size.height * i / (lines - 1);
      for (var x = 0.0; x < size.width; x += 6) {
        canvas.drawLine(Offset(x, y), Offset(math.min(x + 3, size.width), y), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.lines != lines;
}
