import 'package:flutter/material.dart';

// --- Shared Theme Colors ---
class DashboardColors {
  static const background = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF1B2A26);
  static const activeGreen = Color(0xFF8CC63F);
  static const activeBgGreen = Color(0xFFEBF5E8);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF1B2A26);
  static const textSecondary = Color(0xFF757575);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedBottomNavIndex = 0;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              _buildHeader(),
              const SizedBox(height: 16),

              // --- Current Streak Banner ---
              _buildStreakCard(),
              const SizedBox(height: 16),

              // --- Active Program Banner ---
              _buildActiveProgramCard(),
              const SizedBox(height: 20),

              // --- 30-Day Workout Plan Section ---
              _buildWorkoutPlanSection(),
              const SizedBox(height: 20),

              // --- Today's Workout Section ---
              _buildTodayWorkoutSection(),
              const SizedBox(height: 24),

              // --- Today's Meals Section ---
              _buildTodayMealsSection(),
              const SizedBox(height: 24),

              // --- Weekly Activity Section ---
              _buildWeeklyActivitySection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Header Widget
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Good morning,",
              style: TextStyle(
                fontSize: 12,
                color: DashboardColors.textSecondary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              "Sarah",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DashboardColors.textPrimary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined, size: 20),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/user_avatar.png'),
            ),
          ],
        ),
      ],
    );
  }

  // Streak Banner Widget
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: DashboardColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "CURRENT STREAK",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: DashboardColors.textSecondary),
                ),
                SizedBox(height: 2),
                Text(
                  "Day 12 / 30",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                ),
                SizedBox(height: 2),
                Text(
                  "18 days left to set a new record",
                  style: TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEDC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              "Keep it up!",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: DashboardColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  // Active Program Widget
  Widget _buildActiveProgramCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "DAY 12 OF 30",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const Text(
                "Active Program",
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Full Body Strength",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Row(
            children: const [
              Icon(Icons.access_time, size: 14, color: Colors.white70),
              SizedBox(width: 4),
              Text("25 mins", style: TextStyle(fontSize: 11, color: Colors.white70)),
              SizedBox(width: 12),
              Icon(Icons.local_fire_department_outlined, size: 14, color: Colors.white70),
              SizedBox(width: 4),
              Text("732 kcal", style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Program Progress", style: TextStyle(fontSize: 10, color: Colors.white70)),
              Text("40%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.40,
              minHeight: 5,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.activeGreen),
            ),
          ),
        ],
      ),
    );
  }

  // 30-Day Workout Plan Section
  Widget _buildWorkoutPlanSection() {
    final days = [
      {'day': 'Day 11', 'label': 'Chest', 'completed': true},
      {'day': 'Day 12', 'label': 'Full Body', 'completed': false, 'active': true},
      {'day': 'Day 13', 'label': 'Abs', 'completed': false},
      {'day': 'Day 14', 'label': 'Upper', 'completed': false},
      {'day': 'Day 15', 'label': 'HIIT', 'completed': false},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "30-Day Workout Plan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "View All",
                style: TextStyle(fontSize: 12, color: DashboardColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            final item = days[index];
            final isCompleted = item['completed'] == true;
            final isActive = index == _selectedDayIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDayIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? DashboardColors.primaryDark
                        : isActive
                        ? DashboardColors.activeBgGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? DashboardColors.activeGreen : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        item['day'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isCompleted ? Colors.white70 : DashboardColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? DashboardColors.activeGreen : Colors.transparent,
                          border: isCompleted ? null : Border.all(color: Colors.black26, width: 1.5),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['label'].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.white : DashboardColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Today's Workout Section
  Widget _buildTodayWorkoutSection() {
    final exercises = [
      {'title': 'Barbell Squats', 'reps': '4 / 12', 'done': true, 'image': 'assets/ex_squat.png'},
      {'title': 'Dumbbell Lunges', 'reps': '3 / 10', 'done': true, 'image': 'assets/ex_lunge.png'},
      {'title': 'Leg Press', 'reps': '4 / 12', 'done': false, 'image': 'assets/ex_press.png'},
      {'title': 'Calf Raises', 'reps': '3 / 15', 'done': false, 'image': 'assets/ex_calf.png'},
      {'title': 'Romanian Deadlift', 'reps': '3 / 10', 'done': false, 'image': 'assets/ex_deadlift.png'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Today's Workout",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
              ),
              Text(
                "Adjust Plan",
                style: TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Fullbody Strength - 5 exercises",
            style: TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = exercises[index];
              final isDone = item['done'] == true;

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDone ? DashboardColors.activeBgGreen : DashboardColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        item['image'].toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.white,
                          child: const Icon(Icons.fitness_center, size: 20, color: DashboardColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'].toString(),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['reps'].toString(),
                            style: const TextStyle(fontSize: 11, color: DashboardColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? DashboardColors.activeGreen : Colors.white,
                        border: isDone ? null : Border.all(color: Colors.black26, width: 1.5),
                      ),
                      child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DashboardColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              onPressed: () {},
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text("Start today's session", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Today's Meals Section
  Widget _buildTodayMealsSection() {
    final meals = [
      {
        'category': 'BREAKFAST',
        'title': 'Berry Oatmeal Bowl',
        'calories': '312 kcal',
        'image': 'assets/meal_oatmeal.png',
      },
      {
        'category': 'LUNCH',
        'title': 'Avocado Chicken Salad',
        'calories': '540 kcal',
        'image': 'assets/meal_salad.png',
      },
      {
        'category': 'DINNER',
        'title': 'Roasted Salmon & Quinoa',
        'calories': '465 kcal',
        'image': 'assets/meal_salmon.png',
      },
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Today's Meals",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                "Track Meal",
                style: TextStyle(fontSize: 12, color: DashboardColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final meal = meals[index];
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DashboardColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      meal['image'].toString(),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        color: DashboardColors.background,
                        child: const Icon(Icons.restaurant, size: 22, color: DashboardColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['category'].toString(),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: DashboardColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal['title'].toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal['calories'].toString(),
                          style: const TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: DashboardColors.primaryDark, size: 22),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Weekly Activity Section
  Widget _buildWeeklyActivitySection() {
    final activityData = [
      {'day': 'Mon', 'height': 35.0, 'highlight': false},
      {'day': 'Tue', 'height': 50.0, 'highlight': false},
      {'day': 'Wed', 'height': 25.0, 'highlight': false},
      {'day': 'Thu', 'height': 45.0, 'highlight': false},
      {'day': 'Fri', 'height': 60.0, 'highlight': true},
      {'day': 'Sat', 'height': 15.0, 'highlight': false},
      {'day': 'Sun', 'height': 20.0, 'highlight': false},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Activity",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DashboardColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            "Avg. 745 kcal burn active daily",
            style: TextStyle(fontSize: 10, color: DashboardColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activityData.map((item) {
                final isHighlight = item['highlight'] == true;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: (item['height'] as double),
                      decoration: BoxDecoration(
                        color: isHighlight ? DashboardColors.activeGreen : const Color(0xFFE2E6E2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['day'].toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                        color: isHighlight ? DashboardColors.textPrimary : DashboardColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Navigation Bar Widget
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_filled, "Home"),
          _buildNavItem(1, Icons.explore_outlined, "Discover"),
          _buildNavItem(2, Icons.fitness_center_outlined, "Plan"),
          _buildNavItem(3, Icons.bar_chart_rounded, "Report"),
          _buildNavItem(4, Icons.person_outline, "Profile"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedBottomNavIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedBottomNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? DashboardColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : DashboardColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}