import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../meal_plan/presentation/providers/meal_plan_provider.dart' show LoadState;
import '../../../meal_plan/presentation/providers/weekly_meal_plan_provider.dart';
import '../../../tracking/presentation/providers/water_intake_provider.dart';
import '../../../tracking/presentation/providers/weight_log_provider.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/localization/app_localizations.dart';

class _ReportColors {
  static const background = Color(0xFFF8F7F2);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
  static const chipBg = Color(0xFFEFEFE9);
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

  late final List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekDays = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final weightProvider = context.read<WeightLogProvider>();
      final waterProvider = context.read<WaterIntakeProvider>();
      await Future.wait([weightProvider.load(), waterProvider.load()]);
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

  String _formatDate(DateTime date) => '${context.tr(_monthKeys[date.month - 1])} ${date.day}';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ReportColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 18, right: 18, top: 12, bottom: 90),
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
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _ReportColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              context.tr('report_header_title'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 26.0),
          child: Text(
            context.tr('report_header_subtitle'),
            style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // --- Top Progress Banner — real weight history vs. profile goal ---
  Widget _buildOverallProgressCard() {
    final profile = widget.profile;

    return Consumer<WeightLogProvider>(
      builder: (context, weightProvider, _) {
        final history = weightProvider.history;
        final start = history.isNotEmpty ? history.first.weight : profile?.currentWeightKg;
        final current = history.isNotEmpty ? history.last.weight : profile?.currentWeightKg;
        final target = profile?.targetWeightKg;

        double? percent;
        String goalLabel = context.tr('report_weight_goal');
        if (start != null && current != null && target != null) {
          if (profile!.goal == Goal.lose && start > target) {
            percent = ((start - current) / (start - target)).clamp(0.0, 1.0);
            goalLabel = context.tr('report_weight_loss_goal');
          } else if (profile.goal == Goal.gain && target > start) {
            percent = ((current - start) / (target - start)).clamp(0.0, 1.0);
            goalLabel = context.tr('report_weight_gain_goal');
          } else {
            goalLabel = context.tr('report_maintain_weight');
            final maxDeviation = (start - target).abs().clamp(0.5, double.infinity);
            percent = (1 - ((current - target).abs() / maxDeviation)).clamp(0.0, 1.0);
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _ReportColors.primaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('report_overall_progress_label'), style: const TextStyle(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(goalLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  if (percent != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text("${(percent * 100).round()} %", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _ReportColors.activeGreen)),
                        const SizedBox(width: 4),
                        Text(context.tr('report_percent_complete'), style: const TextStyle(fontSize: 9, color: Colors.white70)),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent ?? 0,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  color: _ReportColors.activeGreen,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(start != null ? context.tr('report_stat_start', {'value': start.toStringAsFixed(1)}) : context.tr('report_stat_start_empty'), style: const TextStyle(fontSize: 9, color: Colors.white70)),
                  Text(current != null ? context.tr('report_stat_current', {'value': current.toStringAsFixed(1)}) : context.tr('report_stat_current_empty'), style: const TextStyle(fontSize: 9, color: Colors.white70)),
                  Text(
                    target != null ? context.tr('report_stat_goal', {'value': target.toStringAsFixed(1)}) : context.tr('report_stat_goal_empty'),
                    style: const TextStyle(fontSize: 9, color: _ReportColors.activeGreen, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Tab Toggle Chips ---
  Widget _buildTabToggle() {
    final tabs = [context.tr('report_tab_weight'), context.tr('report_tab_nutrition'), context.tr('report_tab_achievements')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _ReportColors.chipBg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _ReportColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3 Stat Pills
        Row(
          children: [
            Expanded(child: _buildMiniStatTile(Icons.fitness_center, "3", context.tr('report_stat_workouts'), const Color(0xFFEBF5E8), _ReportColors.activeGreen)),
            const SizedBox(width: 8),
            Expanded(child: _buildMiniStatTile(Icons.local_fire_department, "927", context.tr('report_stat_kcal'), const Color(0xFFFFF3E0), const Color(0xFFE08A00))),
            const SizedBox(width: 8),
            Expanded(child: _buildMiniStatTile(Icons.timer_outlined, "45", context.tr('report_stat_min'), const Color(0xFFE1F5FE), const Color(0xFF29B6F6))),
          ],
        ),
        const SizedBox(height: 16),

        // Weight Progress Chart Card — real logged history
        Consumer<WeightLogProvider>(
          builder: (context, weightProvider, _) {
            final history = weightProvider.history;
            final current = weightProvider.latestWeight ?? widget.profile?.currentWeightKg;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('report_weight_progress_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                      GestureDetector(
                        onTap: () => _showWeightCheckInDialog(weightProvider),
                        child: Row(
                          children: [
                            Text(context.tr('report_log_weight'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _ReportColors.activeGreen)),
                            const SizedBox(width: 2),
                            const Icon(Icons.edit_outlined, size: 14, color: _ReportColors.activeGreen),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current != null ? context.tr('report_current_weight_kg', {'value': current.toStringAsFixed(1)}) : context.tr('report_no_weighins'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  if (history.length < 2)
                    SizedBox(
                      height: 100,
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
                      height: 100,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _WeightChartPainter(history.map((e) => e.weight).toList()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _sampleDatesForLabels(history)
                          .map((e) => Text(_formatDate(DateTime.parse(e.date)), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)))
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Activity Heatmap Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.tr('report_activity_heatmap_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                  Row(
                    children: [
                      Text(context.tr('report_heatmap_month_year'), style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary)),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: _ReportColors.textSecondary),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHeatmapGrid(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: _ReportColors.activeBgGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(context.tr('report_more_active'), style: const TextStyle(fontSize: 8, color: _ReportColors.textSecondary)),
                  const SizedBox(width: 12),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: _ReportColors.primaryDark, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(context.tr('report_less_active'), style: const TextStyle(fontSize: 8, color: _ReportColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Workout History List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('report_workout_history_title'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
            Text(context.tr('report_view_all'), style: const TextStyle(fontSize: 11, color: _ReportColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        _buildWorkoutHistoryItem(context.tr('report_workout_full_body_strength'), "May 14, 2025", "40 min", "340 kcal"),
        const SizedBox(height: 8),
        _buildWorkoutHistoryItem(context.tr('report_workout_lower_body_power'), "May 13, 2025", "45 min", "375 kcal"),
        const SizedBox(height: 8),
        _buildWorkoutHistoryItem(context.tr('report_workout_yoga_flow'), "May 12, 2025", "25 min", "120 kcal"),
      ],
    );
  }

  /// Picks up to 5 evenly-spaced entries from the weight history to label
  /// under the chart, so a long history doesn't overcrowd the axis.
  List<WeightLogEntry> _sampleDatesForLabels(List<WeightLogEntry> history) {
    if (history.length <= 5) return history;
    final step = (history.length - 1) / 4;
    return List.generate(5, (i) => history[(i * step).round()]);
  }

  Widget _buildMiniStatTile(IconData icon, String value, String unit, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
              Text(unit, style: const TextStyle(fontSize: 8, color: _ReportColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    final activeDays = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31};
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 31,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final dayNum = index + 1;
        final isActive = activeDays.contains(dayNum);
        return Container(
          decoration: BoxDecoration(
            color: dayNum == 1
                ? _ReportColors.activeBgGreen
                : isActive
                ? _ReportColors.primaryDark
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            "$dayNum",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : _ReportColors.textPrimary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutHistoryItem(String title, String date, String duration, String calories) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: _ReportColors.background, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, size: 18, color: _ReportColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
              const SizedBox(height: 2),
              Text(calories, style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: NUTRITION VIEW ====================
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

    return Consumer3<WeeklyMealPlanProvider, WaterIntakeProvider, WeightLogProvider>(
      builder: (context, mealsProvider, water, weightProvider, _) {
        final today = _weekDays.first;
        final todaysMeals = mealsProvider.mealsFor(today);
        final todayState = mealsProvider.stateFor(today);

        var proteinG = 0.0;
        var carbsG = 0.0;
        var fatG = 0.0;
        var totalKcal = 0;
        for (final meal in todaysMeals) {
          proteinG += meal.macros.proteinG;
          carbsG += meal.macros.carbsG;
          fatG += meal.macros.fatG;
          totalKcal += meal.calories;
        }
        final proteinCals = proteinG * 4;
        final carbsCals = carbsG * 4;
        final fatCals = fatG * 9;
        final macroCalTotal = proteinCals + carbsCals + fatCals;
        final proteinFrac = macroCalTotal > 0 ? proteinCals / macroCalTotal : 0.0;
        final carbsFrac = macroCalTotal > 0 ? carbsCals / macroCalTotal : 0.0;
        final fatFrac = macroCalTotal > 0 ? fatCals / macroCalTotal : 0.0;

        final currentWeight = weightProvider.latestWeight ?? profile.currentWeightKg;
        final targetWeight = profile.targetWeightKg;

        final weekTotals = _weekDays.map((day) {
          return mealsProvider.mealsFor(day).fold<int>(0, (sum, m) => sum + m.calories);
        }).toList();
        final loadedTotals = weekTotals.where((t) => t > 0).toList();
        final avgKcal = loadedTotals.isEmpty ? 0 : (loadedTotals.reduce((a, b) => a + b) / loadedTotals.length).round();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutrition Report Donut Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.tr('report_nutrition_report_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                      Text(context.tr('report_today'), style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (todayState == LoadState.loading)
                    const SizedBox(height: 110, child: Center(child: CircularProgressIndicator(color: _ReportColors.primaryDark)))
                  else if (todaysMeals.isEmpty)
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
                          width: 110,
                          height: 110,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(110, 110),
                                painter: _DonutChartPainter(proteinFrac: proteinFrac, carbsFrac: carbsFrac, fatFrac: fatFrac),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$totalKcal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                                  Text(context.tr('report_stat_kcal'), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMacroLegendItem(_ReportColors.activeGreen, context.tr('report_protein'), "${proteinG.round()}g (${(proteinFrac * 100).round()}%)"),
                              const SizedBox(height: 8),
                              _buildMacroLegendItem(const Color(0xFFFFB74D), context.tr('report_carbs'), "${carbsG.round()}g (${(carbsFrac * 100).round()}%)"),
                              const SizedBox(height: 8),
                              _buildMacroLegendItem(const Color(0xFFEF5350), context.tr('report_fats'), "${fatG.round()}g (${(fatFrac * 100).round()}%)"),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weight Goal & Water Intake Cards Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.eco_outlined, size: 14, color: _ReportColors.activeGreen),
                            const SizedBox(width: 4),
                            Text(context.tr('report_weight_goal'), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          targetWeight != null
                              ? "${currentWeight.toStringAsFixed(1)} / ${targetWeight.toStringAsFixed(1)} kg"
                              : "${currentWeight.toStringAsFixed(1)} kg",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: targetWeight == null || targetWeight == 0
                                ? 0
                                : (currentWeight / targetWeight).clamp(0.0, 1.0),
                            minHeight: 4,
                            backgroundColor: Colors.black12,
                            color: _ReportColors.activeGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop_outlined, size: 14, color: Color(0xFF29B6F6)),
                            const SizedBox(width: 4),
                            Text(context.tr('report_water_intake_title'), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('dashboard_glasses_count', {'glasses': '${water.glasses}', 'target': '${water.targetGlasses}'}),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: water.targetGlasses == 0 ? 0 : water.glasses / water.targetGlasses,
                            minHeight: 4,
                            backgroundColor: Colors.black12,
                            color: const Color(0xFF29B6F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekly Calories Bar Chart Card — real totals from generated recipes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('report_weekly_calories_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 110,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(_weekDays.length, (index) {
                        final day = _weekDays[index];
                        final total = weekTotals[index];
                        final state = mealsProvider.stateFor(day);
                        final heightFactor = dailyTarget.calories == 0
                            ? 0.0
                            : (total / dailyTarget.calories).clamp(0.0, 1.0);
                        final metGoal = dailyTarget.calories > 0 && total >= dailyTarget.calories * 0.9;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (state == LoadState.loading)
                              const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 1.5))
                            else
                              Container(
                                width: 14,
                                height: 6 + 74 * heightFactor,
                                decoration: BoxDecoration(
                                  color: metGoal ? _ReportColors.activeGreen : const Color(0xFFE8ECE8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(context.tr(_weekdayKeys[day.weekday - 1]), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loadedTotals.isEmpty ? context.tr('report_avg_dash') : context.tr('report_avg_kcal', {'avg': '$avgKcal'}),
                        style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary),
                      ),
                      Text(context.tr('report_goal_kcal', {'goal': '${dailyTarget.calories}'}), style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, color: _ReportColors.textSecondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
      ],
    );
  }

  // ==================== TAB 3: ACHIEVEMENTS VIEW ====================
  Widget _buildAchievementsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.tr('report_tab_achievements'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
            const Text("3/6", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ReportColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        _buildAchievementTile(context.tr('report_achievement_first_starter_title'), context.tr('report_achievement_first_starter_desc'), "Jul 1", true, 1.0),
        const SizedBox(height: 8),
        _buildAchievementTile(context.tr('report_achievement_streak_starter_title'), context.tr('report_achievement_streak_starter_desc'), "Jul 12", true, 1.0),
        const SizedBox(height: 8),
        _buildAchievementTile(context.tr('report_achievement_pace_crusher_title'), context.tr('report_achievement_pace_crusher_desc'), "Aug 02", true, 1.0),
        const SizedBox(height: 8),
        _buildAchievementTile(context.tr('report_achievement_consistency_king_title'), context.tr('report_achievement_consistency_king_desc'), context.tr('report_status_in_progress'), false, 0.6),
        const SizedBox(height: 8),
        _buildAchievementTile(context.tr('report_achievement_calorie_club_title'), context.tr('report_achievement_calorie_club_desc'), context.tr('report_status_in_progress'), false, 0.4),
        const SizedBox(height: 8),
        _buildAchievementTile(context.tr('report_achievement_iron_body_title'), context.tr('report_achievement_iron_body_desc'), context.tr('report_status_locked'), false, 0.1),
        const SizedBox(height: 20),

        // Progress Photos Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _ReportColors.cardWhite, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: _ReportColors.chipBg, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_outlined, color: _ReportColors.primaryDark, size: 20),
              ),
              const SizedBox(height: 8),
              Text(context.tr('report_progress_photos_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                context.tr('report_progress_photos_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: _ReportColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _ReportColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(context.tr('report_add_first_photos'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Motivational Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _ReportColors.activeBgGreen, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_outlined, color: _ReportColors.activeGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('report_motivational_banner'),
                  style: const TextStyle(fontSize: 9, color: _ReportColors.textPrimary, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementTile(String title, String desc, String status, bool completed, double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed ? _ReportColors.activeBgGreen.withOpacity(0.5) : _ReportColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: completed ? const Color(0xFFFFC107) : Colors.black26, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _ReportColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 8, color: _ReportColors.textSecondary)),
                if (!completed) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, minHeight: 3, backgroundColor: Colors.black12, color: _ReportColors.activeGreen),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _ReportColors.activeGreen, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Text(status, style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 2),
                  const Icon(Icons.check, size: 10, color: Colors.white),
                ],
              ),
            )
          else
            Text(status, style: const TextStyle(fontSize: 8, color: _ReportColors.textSecondary)),
        ],
      ),
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNavigationBar() {
    return AppBottomNavBar(currentTab: AppTab.report, profile: widget.profile);
  }
}

// ==================== CUSTOM PAINTERS ====================

class _WeightChartPainter extends CustomPainter {
  final List<double> weights;

  _WeightChartPainter(this.weights);

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.length < 2) return;

    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxWeight - minWeight).abs() < 0.5 ? 1.0 : (maxWeight - minWeight);

    final points = List.generate(weights.length, (i) {
      final x = weights.length == 1 ? 0.0 : size.width * (i / (weights.length - 1));
      final normalized = (weights[i] - minWeight) / range;
      final y = size.height * (1 - normalized * 0.8) - size.height * 0.1;
      return Offset(x, y);
    });

    final paintLine = Paint()
      ..color = const Color(0xFF8CC63F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintDot = Paint()
      ..color = const Color(0xFF8CC63F)
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paintLine);

    for (final p in points) {
      canvas.drawCircle(p, 3.5, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => oldDelegate.weights != weights;
}

class _DonutChartPainter extends CustomPainter {
  final double proteinFrac;
  final double carbsFrac;
  final double fatFrac;

  _DonutChartPainter({required this.proteinFrac, required this.carbsFrac, required this.fatFrac});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    const twoPi = 6.28318530718;
    const startAngle = -1.5708; // -90 degrees, 12 o'clock

    final paintProtein = Paint()
      ..color = const Color(0xFF8CC63F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final paintCarbs = Paint()
      ..color = const Color(0xFFFFB74D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final paintFat = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final proteinSweep = proteinFrac * twoPi;
    final carbsSweep = carbsFrac * twoPi;
    final fatSweep = fatFrac * twoPi;

    canvas.drawArc(rect, startAngle, proteinSweep, false, paintProtein);
    canvas.drawArc(rect, startAngle + proteinSweep, carbsSweep, false, paintCarbs);
    canvas.drawArc(rect, startAngle + proteinSweep + carbsSweep, fatSweep, false, paintFat);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.proteinFrac != proteinFrac || oldDelegate.carbsFrac != carbsFrac || oldDelegate.fatFrac != fatFrac;
}
