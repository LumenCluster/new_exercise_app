import 'package:flutter/material.dart';

class UpgradePremiumScreen extends StatefulWidget {
  const UpgradePremiumScreen({super.key});

  @override
  State<UpgradePremiumScreen> createState() => _UpgradePremiumScreenState();
}

class _UpgradePremiumScreenState extends State<UpgradePremiumScreen> {
  int _selectedPlanIndex = 1; // 0: Monthly, 1: Yearly
  int _selectedBottomNavIndex = 4; // 4: Profile Tab

  // Color Palette
  static const backgroundColor = Color(0xFFF9F8F3);
  static const primaryDark = Color(0xFF13221E);
  static const activeGreen = Color(0xFF8CC63F);
  static const cardWhite = Colors.white;
  static const textPrimary = Color(0xFF13221E);
  static const textSecondary = Color(0xFF757575);
  static const goldAccent = Color(0xFFE08A00);
  static const goldBg = Color(0xFFFFF3E0);
  static const borderGold = Color(0xFFF5A623);

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
                  _buildGoPremiumHeroCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle("WHAT YOU UNLOCK"),
                  const SizedBox(height: 12),
                  _buildBenefitsCard(),
                  const SizedBox(height: 20),
                  _buildPlanSelectionRow(),
                  const SizedBox(height: 16),
                  _buildRestorePurchaseButton(),
                  const SizedBox(height: 8),
                  _buildTermsFooter(),
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

  // Top Bar Navigation
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
            child: const Icon(Icons.close_rounded, size: 18, color: textPrimary),
          ),
        ),
        const Expanded(
          child: Text(
            "UPGRADE PREMIUM",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }

  // Go Premium Main Header Card
  Widget _buildGoPremiumHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: goldBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium_rounded, size: 30, color: goldAccent),
          ),
          const SizedBox(height: 14),
          const Text(
            "Go Premium",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Unlock your body's full potential with personalized plans, smart insights, and deep analytics.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
        color: textSecondary,
      ),
    );
  }

  // Feature Highlights List
  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildBenefitTile(
            icon: Icons.star_border_purple500_rounded,
            iconBg: goldBg,
            iconColor: goldAccent,
            title: "Ad-Free Experience",
            subtitle: "Focus on your wellness with zero interruptions or banner ads.",
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildBenefitTile(
            icon: Icons.notifications_none_rounded,
            iconBg: const Color(0xFFEBF5E8),
            iconColor: activeGreen,
            title: "Advanced Smart Reminders",
            subtitle: "Intelligent nudge notifications custom tailored to your routines.",
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildBenefitTile(
            icon: Icons.insert_chart_outlined_rounded,
            iconBg: const Color(0xFFE0F2F1),
            iconColor: const Color(0xFF26A69A),
            title: "Detailed Analytics Reports",
            subtitle: "Weekly and monthly breakdowns of hydration, weight, and workouts.",
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF2F2EC)),
          _buildBenefitTile(
            icon: Icons.favorite_border_rounded,
            iconBg: const Color(0xFFE1F5FE),
            iconColor: const Color(0xFF29B6F6),
            title: "Unlimited Wearable Sync",
            subtitle: "Realtime, constant synchronization with your smartwatches & bands.",
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Subscription Pricing Option Cards
  Widget _buildPlanSelectionRow() {
    return Row(
      children: [
        // Monthly Card
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedPlanIndex == 0 ? primaryDark : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "MONTHLY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        "\$9.99",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        " /mo",
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Cancel anytime, renews\nmonthly",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 8, color: textSecondary, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => setState(() => _selectedPlanIndex = 0),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: const BorderSide(color: textPrimary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      "Try Monthly",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Yearly Card (Highlighted)
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPlanIndex = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: goldBg.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderGold,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: borderGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "SAVE 50%",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "YEARLY",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: goldAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text(
                        "\$4.99",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        " /mo",
                        style: TextStyle(fontSize: 10, color: textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "\$59.88 billed annually",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => setState(() => _selectedPlanIndex = 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    child: const Text(
                      "Go Premium",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestorePurchaseButton() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          "Restore Purchase",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: goldAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        "Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period. See our Terms of Service & Privacy Policy.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 8,
          color: textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  // Floating Bottom Bar Navigation
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