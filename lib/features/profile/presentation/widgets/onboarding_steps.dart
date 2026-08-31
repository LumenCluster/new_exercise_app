import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import 'onboarding_components.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'onboarding_components.dart';
class IntroStep extends StatelessWidget {
  final VoidCallback onNext;

  const IntroStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const StepHeader(
                title: "Let's build\na plan that fits you",
                subtitle:
                "We'll ask a few simple questions to understand your goals and lifestyle.",
              ),
              const Spacer(),
              Center(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(160),
                    topRight: Radius.circular(160),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.asset(
                    'assets/plan.png', // Replace with your exact asset path
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              OnboardingButton(text: "Let's begin", onPressed: onNext),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Your information is safe and secure with us.",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AboutYouIntroStep extends StatelessWidget {
  final VoidCallback onNext;

  const AboutYouIntroStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const StepHeader(
                partText: "PART 1",
                title: "About You",
                subtitle:
                "Let's start with a few details to personalize your experience.",
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/about.png', // Replace with your exact asset path
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              OnboardingButton(text: "Continue", onPressed: onNext),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "About 2 minutes",
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class NameGenderStep extends StatefulWidget {
  final Function(String name, Gender gender) onNext;

  const NameGenderStep({super.key, required this.onNext});

  @override
  State<NameGenderStep> createState() => _NameGenderStepState();
}

class _NameGenderStepState extends State<NameGenderStep> {
  final _nameController = TextEditingController();
  Gender? _gender;

  @override
  Widget build(BuildContext context) {
    bool isEnabled = _nameController.text.trim().isNotEmpty && _gender != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StepHeader(
                title: "Let's get to know you",
                subtitle: "This helps us personalize your experience.",
              ),
              const SizedBox(height: 28),
              const Text(
                "What Should We Call You?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Select Your Gender",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SelectableCard(
                      title: "Female",
                      subtitle: "Identify as a woman",
                      isSelected: _gender == Gender.female,
                      onTap: () => setState(() => _gender = Gender.female),
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/female.png', // Replace with your female asset path
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_gender == Gender.female)
                            const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.accentGreen,
                                child: Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SelectableCard(
                      title: "Male",
                      subtitle: "Identify as a man",
                      isSelected: _gender == Gender.male,
                      onTap: () => setState(() => _gender = Gender.male),
                      icon: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/male.png', // Replace with your male asset path
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_gender == Gender.male)
                            const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColors.accentGreen,
                                child: Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              OnboardingButton(
                text: "Next",
                onPressed: isEnabled ? () => widget.onNext(_nameController.text, _gender!) : null,
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Your information is safe with us and will never be shared.",
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AgeStep extends StatefulWidget {
  final Function(int age) onNext;

  const AgeStep({super.key, required this.onNext});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  int _selectedAge = 26;
  final FixedExtentScrollController _scrollController =
  FixedExtentScrollController(initialItem: 16); // Defaults to 26 (10 + 16)

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "What's your age?",
                subtitle: "We'll use this to make sure your plan fits you perfectly.",
              ),
              const Spacer(),

              // Divider Header
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "Select Your Age",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                ],
              ),
              const SizedBox(height: 16),

              // Scroll Wheel
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Active Item White Card
                    Container(
                      height: 48,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 44,
                      perspective: 0.003,
                      diameterRatio: 1.5,
                      onSelectedItemChanged: (index) =>
                          setState(() => _selectedAge = 10 + index),
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) {
                          final age = 10 + index;
                          final isSelected = age == _selectedAge;
                          return Center(
                            child: Text(
                              isSelected ? "$age years" : "$age yrs",
                              style: TextStyle(
                                fontSize: isSelected ? 22 : 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withOpacity(0.35),
                              ),
                            ),
                          );
                        },
                        childCount: 90,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Privacy Notice Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF262E2B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your privacy matters",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Your information is safe with us and will never be shared.",
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Optional Skip Button
              GestureDetector(
                onTap: () => widget.onNext(_selectedAge),
                child: const Text(
                  "I don't want to answer",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              OnboardingButton(
                text: "Next",
                onPressed: () => widget.onNext(_selectedAge),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class HeightStep extends StatefulWidget {
  final Function(double height) onNext;

  const HeightStep({super.key, required this.onNext});

  @override
  State<HeightStep> createState() => _HeightStepState();
}

class _HeightStepState extends State<HeightStep> {
  bool _isCm = false;
  double _heightInInches = 78.0; // 6 ft 6 in default (78 inches)

  int get _feet => (_heightInInches / 12).floor();
  int get _inches => (_heightInInches % 12).round();
  int get _cm => (_heightInInches * 2.54).round();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "How tall are you?",
                subtitle: "Your height helps us create a plan that's tailored just for you.",
              ),
              const SizedBox(height: 16),

              // Unit Toggle (cm / ft/in)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitTab("cm", _isCm, () => setState(() => _isCm = true)),
                    _buildUnitTab("ft/in", !_isCm, () => setState(() => _isCm = false)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Height Display Card
              Container(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isCm
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "$_cm",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "cm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$_feet",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "ft",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(width: 1, height: 28, color: Colors.black12),
                    const SizedBox(width: 16),
                    Text(
                      "$_inches",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "in",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                "Looks about right? You can adjust using the ruler.",
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Interactive Ruler + Image Area
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Model Asset Image
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/girl.png', // Register in pubspec.yaml
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        // Movable Interactive Vertical Ruler
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) {
                              setState(() {
                                // Drag up increases height, drag down decreases height
                                _heightInInches -= details.delta.dy * 0.15;
                                _heightInInches = _heightInInches.clamp(42.0, 90.0); // 3.5 ft to 7.5 ft
                              });
                            },
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: RulerPainter(
                                heightInInches: _heightInInches,
                                isCm: _isCm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Tips for Accuracy Floating Card
                    Positioned(
                      right: 0,
                      bottom: 12,
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF7CB342),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Tips for accuracy",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Stand straight against a wall without shoes for the most accurate measurement.",
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              OnboardingButton(
                text: "Next",
                onPressed: () => widget.onNext(_cm.toDouble()),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2825) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Custom Ruler Painter for drawing measurement ticks and horizontal indicator line
class RulerPainter extends CustomPainter {
  final double heightInInches;
  final bool isCm;

  RulerPainter({required this.heightInInches, required this.isCm});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4D38)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = const Color(0xFF2E4D38)
      ..strokeWidth = 2;

    const double minInches = 42.0; // 3.5 ft
    const double maxInches = 90.0; // 7.5 ft

    // Height ratio mapping
    double norm = (heightInInches - minInches) / (maxInches - minInches);
    double indicatorY = size.height * (1 - norm);

    // Draw horizontal dashed pointer line from image to ruler
    double dashWidth = 5, dashSpace = 4, startX = -100;
    while (startX < 30) {
      canvas.drawLine(
        Offset(startX, indicatorY),
        Offset(startX + dashWidth, indicatorY),
        dashedPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Indicator Dot & Line Start
    canvas.drawCircle(Offset(-20, indicatorY), 4, paint);
    canvas.drawLine(Offset(0, indicatorY), Offset(35, indicatorY), paint);

    // Draw Vertical Ruler Scale Marks
    int totalTicks = 40;
    for (int i = 0; i <= totalTicks; i++) {
      double y = size.height * (1 - (i / totalTicks));
      double tickLength = (i % 10 == 0) ? 28 : (i % 5 == 0 ? 18 : 10);

      canvas.drawLine(Offset(0, y), Offset(tickLength, y), paint);

      // Major Unit Labels (e.g., 4, 5, 6, 7 feet)
      if (i % 10 == 0) {
        int feetValue = 4 + (i ~/ 10);
        final textPainter = TextPainter(
          text: TextSpan(
            text: "$feetValue",
            style: const TextStyle(
              color: Color(0xFF2E4D38),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, Offset( tickLength + 8, y - 10));
      }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.heightInInches != heightInInches || oldDelegate.isCm != isCm;
  }
}




class WeightStep extends StatefulWidget {
  final double userHeightCm; // Pass user height to calculate BMI accurately
  final Function(double weight) onNext;

  const WeightStep({
    super.key,
    this.userHeightCm = 170.0, // Default fallback height
    required this.onNext,
  });

  @override
  State<WeightStep> createState() => _WeightStepState();
}

class _WeightStepState extends State<WeightStep> {
  bool _isKg = true;
  double _weightKg = 65.5;

  double get _weightLbs => _weightKg * 2.20462;

  // Calculate BMI: weight (kg) / (height (m))^2
  double get _bmi {
    final heightInMeters = widget.userHeightCm / 100;
    if (heightInMeters <= 0) return 22.0;
    return _weightKg / (heightInMeters * heightInMeters);
  }

  // Determine BMI Status & Color
  Map<String, dynamic> get _bmiCategory {
    final bmi = _bmi;
    if (bmi < 18.5) {
      return {'label': 'Underweight', 'color': Colors.orange};
    } else if (bmi < 25.0) {
      return {'label': 'Normal Weight', 'color': const Color(0xFF4CAF50)};
    } else if (bmi < 30.0) {
      return {'label': 'Overweight', 'color': Colors.amber.shade700};
    } else {
      return {'label': 'Obese', 'color': Colors.redAccent};
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _bmiCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "What's your weight?",
                subtitle: "This helps us personalize your plan for your goals.",
              ),
              const SizedBox(height: 16),

              // Unit Toggle (kg / lbs)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildUnitTab("kg", _isKg, () => setState(() => _isKg = true)),
                    _buildUnitTab("lbs", !_isKg, () => setState(() => _isKg = false)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dynamic Weight Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _isKg
                        ? _weightKg.toStringAsFixed(1)
                        : _weightLbs.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isKg ? "kg" : "lbs",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Interactive Horizontal Weight Ruler
              SizedBox(
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center Pointer Line
                    Container(
                      width: 3,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E4D38),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Drag Gesture Detector for Horizontal Scroll
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          // Drag left increases weight, right decreases
                          _weightKg -= details.delta.dx * 0.1;
                          _weightKg = _weightKg.clamp(30.0, 200.0);
                        });
                      },
                      child: CustomPaint(
                        size: const Size(double.infinity, 80),
                        painter: HorizontalRulerPainter(
                          value: _isKg ? _weightKg : _weightLbs,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Real-time BMI Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.monitor_weight_outlined,
                        color: category['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Estimated BMI: ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _bmi.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: category['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Tips Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF7CB342),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Weigh yourself in the morning before eating for the most accurate results.",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              OnboardingButton(
                text: "Next",
                onPressed: () => widget.onNext(_weightKg),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitTab(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2825) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Horizontal Ruler Scale
class HorizontalRulerPainter extends CustomPainter {
  final double value;

  HorizontalRulerPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4D38).withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    const double spacing = 12.0;

    // Draw ticks left and right from center
    for (int i = -20; i <= 20; i++) {
      double x = centerX + (i * spacing) - ((value % 1) * spacing);
      double tickHeight = (i % 10 == 0) ? 32 : (i % 5 == 0 ? 22 : 12);

      canvas.drawLine(
        Offset(x, size.height / 2 - tickHeight / 2),
        Offset(x, size.height / 2 + tickHeight / 2),
        paint,
      );

      // Unit values below main ticks
      if (i % 10 == 0) {
        int displayVal = (value.floor() + i);
        if (displayVal > 0) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: "$displayVal",
              style: const TextStyle(
                color: Color(0xFF2E4D38),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          textPainter.paint(
            canvas,
            Offset(x - (textPainter.width / 2), size.height / 2 + 20),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalRulerPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}


class BodyShapeData {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;
  final String fatLevel; // "Lower", "Moderate", "Higher"
  final String fatRange;
  final String feedbackText;

  BodyShapeData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.fatLevel,
    required this.fatRange,
    required this.feedbackText,
  });
}

class BodyShapeStep extends StatefulWidget {
  final Function(String shape, String fatRange) onNext;

  const BodyShapeStep({super.key, required this.onNext});

  @override
  State<BodyShapeStep> createState() => _BodyShapeStepState();
}

class _BodyShapeStepState extends State<BodyShapeStep> {
  int _selectedIndex = 1; // Default selected: Heavy
  late PageController _pageController;

  final List<BodyShapeData> _shapes = [
    BodyShapeData(
      id: 'curvy',
      title: 'Curvy',
      subtitle: 'Noticeable Body Fat, Curves More Pronounced',
      imagePath: 'assets/about.png',
      fatLevel: 'Lower',
      fatRange: '20% - 27%',
      feedbackText: 'Great base! Lean muscle focus will shape your curves.',
    ),
    BodyShapeData(
      id: 'heavy',
      title: 'Heavy',
      subtitle: 'High Body Fat, Fuller Figure',
      imagePath: 'assets/about.png',
      fatLevel: 'Moderate',
      fatRange: '28% - 35%',
      feedbackText: "You're right on track! Small changes can lead to big results.",
    ),
    BodyShapeData(
      id: 'obese',
      title: 'Obese',
      subtitle: 'Very High Body Fat, Significant Overweight',
      imagePath: 'assets/about.png',
      fatLevel: 'Higher',
      fatRange: '36%+',
      feedbackText: 'Starting your journey now will yield incredible health benefits.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedIndex,
      viewportFraction: 0.48, // Displays peek previews of side items
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentShape = _shapes[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: StepHeader(
                    title: "What's your current body shape?",
                    subtitle: "This helps us personalize your plan for your goals.",
                  ),
                ),
                const SizedBox(height: 20),

                // Body Shape Carousel
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _shapes.length,
                    onPageChanged: (index) {
                      setState(() => _selectedIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final item = _shapes[index];
                      final isSelected = index == _selectedIndex;

                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEBF5E8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF8CC63F)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Top Right Selected Indicator Badge
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8CC63F),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                              // Card Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      item.imagePath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "How Would You Describe Your Body Fat?",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Gradient Body Fat Level Indicator Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Bar Base Gradient
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE2F3E4),
                                  Color(0xFFFCDD91),
                                  Color(0xFFF9C0C0),
                                ],
                              ),
                            ),
                          ),

                          // Position Pointer Ring
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            alignment: currentShape.fatLevel == 'Lower'
                                ? Alignment.centerLeft
                                : currentShape.fatLevel == 'Moderate'
                                ? Alignment.center
                                : Alignment.centerRight,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF262E2B),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Level Labels
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Lower",
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                          Text("Moderate",
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                          Text("Higher",
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Estimated Body Fat Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Target Circle Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B2A26),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Range & Feedback Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Estimated Body Fat",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentShape.fatRange,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentShape.feedbackText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: OnboardingButton(
                    text: "Next",
                    onPressed: () => widget.onNext(
                      currentShape.title,
                      currentShape.fatRange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityLevelStep extends StatefulWidget {
  final Function(ActivityLevel level) onNext;

  const ActivityLevelStep({super.key, required this.onNext});

  @override
  State<ActivityLevelStep> createState() => _ActivityLevelStepState();
}

class _ActivityLevelStepState extends State<ActivityLevelStep> {
  ActivityLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "What's your activity level like?",
                subtitle: "This helps us personalize your plan for your lifestyle.",
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLevelCard(
                      level: ActivityLevel.sedentary,
                      title: "Mostly Sedentary",
                      subtitle: "Little to no exercise. Desk job or spending most time at home.",
                      icon: Icons.chair_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.light, // Updated from lightlyActive
                      title: "Lightly Active",
                      subtitle: "Light exercise or walking 1-3 days per week.",
                      icon: Icons.desktop_windows_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.moderate, // Updated from moderatelyActive
                      title: "Moderately Active",
                      subtitle: "Moderate exercise or walking 3-5 days per week.",
                      icon: Icons.directions_walk_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.active, // Updated to match domain entity
                      title: "Very Active",
                      subtitle: "Hard exercise 6-7 days per week. Physically demanding job or training.",
                      icon: Icons.fitness_center_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.veryActive, // Updated from extremelyActive
                      title: "Extremely Active",
                      subtitle: "Very hard exercise, physical training or sports 2x per day.",
                      icon: Icons.directions_run_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OnboardingButton(
                text: "Next",
                onPressed: _selectedLevel != null ? () => widget.onNext(_selectedLevel!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required ActivityLevel level,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedLevel == level;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLevel = level),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEBF5E8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF8CC63F) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? const Color(0xFF8CC63F)
                    : AppColors.textSecondary.withOpacity(0.6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CC63F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black26,
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// SleepStep class removed

class FrequencyStep extends StatefulWidget {
  final Function(int days) onNext;

  const FrequencyStep({super.key, required this.onNext});

  @override
  State<FrequencyStep> createState() => _FrequencyStepState();
}

class _FrequencyStepState extends State<FrequencyStep> {
  // Store selected day indices: 0: SUN, 1: MON, 2: TUE, 3: WED, 4: THU, 5: FRI, 6: SAT
  final Set<int> _selectedDays = {0, 2, 4, 6};

  final List<String> _daysOfWeek = [
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
  ];

  void _toggleDay(int index) {
    setState(() {
      if (_selectedDays.contains(index)) {
        // Prevent deselecting down to 0 days if needed
        if (_selectedDays.length > 1) {
          _selectedDays.remove(index);
        }
      } else {
        _selectedDays.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "How many days would you like to work out?",
                subtitle: "Choose the days you prefer to stay active each week.",
              ),
              const SizedBox(height: 20),

              // Dynamic Selected Days Count Card
              Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "You selected",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_selectedDays.length}",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "days per week",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Weekdays Grid Layout (4 on Top Row, 3 on Bottom Row)
              Column(
                children: [
                  // Row 1: SUN, MON, TUE, WED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => _buildDayItem(index)),
                  ),
                  const SizedBox(height: 16),

                  // Row 2: THU, FRI, SAT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDayItem(4),
                      const SizedBox(width: 24),
                      _buildDayItem(5),
                      const SizedBox(width: 24),
                      _buildDayItem(6),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Consistency Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8CC63F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Consistency is key",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Regular workouts help build healthy habits and bring better results over time.",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Button
              OnboardingButton(
                text: "Next",
                onPressed: () => widget.onNext(_selectedDays.length),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(int index) {
    final isSelected = _selectedDays.contains(index);

    return GestureDetector(
      onTap: () => _toggleDay(index),
      child: Column(
        children: [
          Text(
            _daysOfWeek[index],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF8CC63F) : Colors.white,
              border: isSelected
                  ? null
                  : Border.all(
                color: Colors.black26,
                width: 1.5,
              ),
            ),
            child: isSelected
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
                : null,
          ),
        ],
      ),
    );
  }
}

class FitnessLevelStep extends StatefulWidget {
  final Function(String level) onNext;

  const FitnessLevelStep({super.key, required this.onNext});

  @override
  State<FitnessLevelStep> createState() => _FitnessLevelStepState();
}

class _FitnessLevelStepState extends State<FitnessLevelStep> {
  String? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "What's your fitness level?",
                subtitle: "This helps us personalize workouts that match your current level.",
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLevelCard(
                      title: "Beginner",
                      subtitle: "New to exercise or just getting started.",
                      imagePath: "assets/begnner.png",
                    ),
                    _buildLevelCard(
                      title: "Middle",
                      subtitle: "Some experience and exercise occasionally.",
                      imagePath: "assets/middle.png",
                    ),
                    _buildLevelCard(
                      title: "Advanced",
                      subtitle: "Experienced and work out regularly with intensity.",
                      imagePath: "assets/advance.png",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "No pressure, you can always update this\nlater as your fitness improves.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              OnboardingButton(
                text: "Next",
                onPressed: _selectedLevel != null ? () => widget.onNext(_selectedLevel!) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    final isSelected = _selectedLevel == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLevel = title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 96,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEBF5E8) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF8CC63F) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left Image Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Image.asset(
                  imagePath,
                  width: 110,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 110,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle Text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Right Selection Circle Indicator
              Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: isSelected
                    ? Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CC63F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                )
                    : Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black26,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsiderationOption {
  final String id;
  final String title;
  final String subtitle;
  final String imagePath;

  ConsiderationOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

class ConsiderationsStep extends StatefulWidget {
  final Function(List<String> considerations) onNext;

  const ConsiderationsStep({super.key, required this.onNext});

  @override
  State<ConsiderationsStep> createState() => _ConsiderationsStepState();
}

class _ConsiderationsStepState extends State<ConsiderationsStep> {
  final List<String> _selectedIds = [];

  final List<ConsiderationOption> _options = [
    ConsiderationOption(
      id: 'no_equipment',
      title: 'No Equipment',
      subtitle: 'Workouts you can do anywhere.',
      imagePath: 'assets/noequip.png',
    ),
    ConsiderationOption(
      id: 'low_impact',
      title: 'Low Impact',
      subtitle: 'Gentle on your joints, no jumping.',
      imagePath: 'assets/low.png',
    ),
    ConsiderationOption(
      id: 'no_floor',
      title: 'No Floor Exercises',
      subtitle: 'Mostly standing and upright movements.',
      imagePath: 'assets/nofloor.png',
    ),
    ConsiderationOption(
      id: 'more_floor',
      title: 'More Floor Exercises',
      subtitle: 'More seated, lying, and mat-based movements.',
      imagePath: 'assets/morefloor.png',
    ),
    ConsiderationOption(
      id: 'limit_pushups',
      title: 'Limit Push-Ups',
      subtitle: 'Fewer or modified upper-body movements.',
      imagePath: 'assets/limit_pushup.png',
    ),
    ConsiderationOption(
      id: 'none',
      title: 'None',
      subtitle: 'I do not have any preferences.',
      imagePath: 'assets/none.png',
    ),
  ];

  void _toggleOption(String id) {
    setState(() {
      if (id == 'none') {
        _selectedIds.clear();
        _selectedIds.add('none');
      } else {
        _selectedIds.remove('none');
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
          if (_selectedIds.isEmpty) {
            _selectedIds.add('none');
          }
        } else {
          _selectedIds.add(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const StepHeader(
                title: "What should we keep in mind?",
                subtitle: "Tell us what you'd like your workouts to include or avoid.",
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final item = _options[index];
                    final isSelected = _selectedIds.contains(item.id);

                    return GestureDetector(
                      onTap: () => _toggleOption(item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEBF5E8) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF8CC63F) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.asset(
                                item.imagePath,
                                height: 85,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 85,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                              ),
                            ),

                            // Text Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          item.title,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.textSecondary,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Bottom Radio / Check Badge
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8CC63F),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.black26,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You can always update this later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              OnboardingButton(
                text: "Next",
                onPressed: _selectedIds.isNotEmpty ? () => widget.onNext(_selectedIds) : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}