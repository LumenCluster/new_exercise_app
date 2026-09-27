import 'package:flutter/material.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _enableNotifications = true;
  int _selectedBottomNavIndex = 4; // Profile tab selected

  // Color Palette
  static const backgroundColor = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF1E4620);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);

  // Custom Section Colors
  static const greenIconBg = Color(0xFFEBF5E8);
  static const greenIconColor = Color(0xFF558B2F);
  static const greenTimeBg = Color(0xFFEFF7E6);
  static const greenTimeText = Color(0xFF43A047);

  static const orangeIconBg = Color(0xFFFBE9E7);
  static const orangeIconColor = Color(0xFFE65100);
  static const orangeTimeBg = Color(0xFFFCE4EC);
  static const orangeTimeText = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  _buildEnableNotificationsTile(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("WORKOUT REMINDERS"),
                  const SizedBox(height: 10),
                  _buildWorkoutRemindersCard(),
                  const SizedBox(height: 8),
                  _buildFooterNote("Staying consistent with workouts builds a sustainable healthy habit."),
                  const SizedBox(height: 20),
                  _buildSectionTitle("MEAL & HYDRATION REMINDERS"),
                  const SizedBox(height: 10),
                  _buildMealRemindersCard(),
                  const SizedBox(height: 8),
                  _buildFooterNote("Paced, mindful meal cycles keep your overall energy levels stable throughout the day."),
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

  // Header Bar
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textPrimary),
        ),
        const SizedBox(width: 12),
        const Text(
          "Reminders",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  // Enable Notifications Card
  Widget _buildEnableNotificationsTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: greenIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 20, color: greenIconColor),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enable Notifications",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Allow fitness & diet nudges",
                  style: TextStyle(fontSize: 11, color: textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _enableNotifications,
            activeThumbColor: Colors.white,
            activeTrackColor: primaryDark,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black12,
            onChanged: (val) {
              setState(() => _enableNotifications = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }

  // Workout Section Card
  Widget _buildWorkoutRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildReminderItem(
            icon: Icons.wb_sunny_outlined,
            iconBg: greenIconBg,
            iconColor: greenIconColor,
            title: "Morning Workout",
            subtitle: "Nudge to start your day strong",
            time: "07:30 AM",
            timeBg: greenTimeBg,
            timeTextColor: greenTimeText,
            activeDays: const [true, true, true, true, true, false, false],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildReminderItem(
            icon: Icons.nightlight_round_outlined,
            iconBg: greenIconBg,
            iconColor: greenIconColor,
            title: "Evening Stretch & Yoga",
            subtitle: "Relaxing prompt before bedtime",
            time: "08:30 PM",
            timeBg: greenTimeBg,
            timeTextColor: greenTimeText,
            activeDays: const [false, false, true, false, false, true, true],
          ),
        ],
      ),
    );
  }

  // Meal & Hydration Section Card
  Widget _buildMealRemindersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildReminderItem(
            icon: Icons.free_breakfast_outlined,
            iconBg: orangeIconBg,
            iconColor: orangeIconColor,
            title: "Breakfast Nudge",
            subtitle: "Refuel with a balanced breakfast",
            time: "08:00 AM",
            timeBg: orangeTimeBg,
            timeTextColor: orangeTimeText,
            activeDays: const [true, true, true, true, true, true, true],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildReminderItem(
            icon: Icons.restaurant_outlined,
            iconBg: orangeIconBg,
            iconColor: orangeIconColor,
            title: "Lunch Reminder",
            subtitle: "Keep metabolism active & nourished",
            time: "01:15 PM",
            timeBg: orangeTimeBg,
            timeTextColor: orangeTimeText,
            activeDays: const [true, true, true, true, true, false, false],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildReminderItem(
            icon: Icons.soup_kitchen_outlined,
            iconBg: orangeIconBg,
            iconColor: orangeIconColor,
            title: "Light Dinner",
            subtitle: "Avoid heavy meals close to bed",
            time: "07:00 PM",
            timeBg: orangeTimeBg,
            timeTextColor: orangeTimeText,
            activeDays: const [true, true, true, true, true, true, true],
          ),
        ],
      ),
    );
  }

  // Single Item Widget
  Widget _buildReminderItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required Color timeBg,
    required Color timeTextColor,
    required List<bool> activeDays,
  }) {
    const days = ["M", "T", "W", "T", "F", "S", "S"];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: timeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: timeTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(7, (index) {
            final isActive = activeDays[index];
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? activeGreen : Colors.transparent,
                  border: Border.all(
                    color: isActive ? activeGreen : Colors.black12,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFooterNote(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          color: textSecondary,
          height: 1.3,
        ),
      ),
    );
  }

  // Floating Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
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
          color: isSelected ? primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : textSecondary),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
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