import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/user_profile.dart';
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
              StepHeader(
                title: context.tr('onboarding_intro_title'),
                subtitle: context.tr('onboarding_intro_subtitle'),
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
                    'assets/onee.png', // Replace with your exact asset path
                    height: 320,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
              OnboardingButton(text: context.tr('onboarding_lets_begin'), onPressed: onNext),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  context.tr('onboarding_info_safe_secure'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
              StepHeader(
                partText: context.tr('onboarding_part_1'),
                title: context.tr('onboarding_about_you_title'),
                subtitle: context.tr('onboarding_about_you_subtitle'),
              ),
              const Spacer(),
              Center(
                child: Image.asset(
                  'assets/twoo.png', // Replace with your exact asset path
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              OnboardingButton(text: context.tr('common_continue'), onPressed: onNext),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  context.tr('onboarding_about_2_minutes'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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

  void _submit() {
    final name = _nameController.text.trim();
    final String? errorKey = name.isEmpty
        ? 'onboarding_name_required'
        : _gender == null
            ? 'onboarding_gender_required'
            : null;

    if (errorKey != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.tr(errorKey)), behavior: SnackBarBehavior.floating),
        );
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onNext(name, _gender!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepHeader(
                      title: context.tr('onboarding_name_gender_title'),
                      subtitle: context.tr('onboarding_name_gender_subtitle'),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      context.tr('onboarding_what_should_we_call_you'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: context.tr('onboarding_enter_name_hint'),
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
                    Text(
                      context.tr('onboarding_select_gender'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SelectableCard(
                            title: context.tr('onboarding_female_title'),
                            subtitle: context.tr('onboarding_female_subtitle'),
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
                            title: context.tr('onboarding_male_title'),
                            subtitle: context.tr('onboarding_male_subtitle'),
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
                      text: context.tr('common_next'),
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        context.tr('onboarding_info_safe_never_shared'),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
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
              StepHeader(
                title: context.tr('onboarding_age_title'),
                subtitle: context.tr('onboarding_age_subtitle'),
              ),
              const Spacer(),

              // Divider Header
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.black12, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      context.tr('onboarding_select_your_age'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
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
                            color: Colors.black.withValues(alpha: 0.03),
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
                              isSelected
                                  ? context.tr('onboarding_age_years', {'age': '$age'})
                                  : context.tr('onboarding_age_yrs', {'age': '$age'}),
                              style: TextStyle(
                                fontSize: isSelected ? 22 : 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withValues(alpha: 0.35),
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
                      color: Colors.black.withValues(alpha: 0.02),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('onboarding_privacy_matters'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('onboarding_info_safe_never_shared'),
                            style: const TextStyle(
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
                child: Text(
                  context.tr('onboarding_i_dont_want_to_answer'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              OnboardingButton(
                text: context.tr('common_next'),
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

  final Gender gender;

  const HeightStep({super.key, required this.onNext, required this.gender});

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
              StepHeader(
                title: context.tr('onboarding_height_title'),
                subtitle: context.tr('onboarding_height_subtitle'),
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
                      color: Colors.black.withValues(alpha: 0.02),
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

              Text(
                context.tr('onboarding_height_looks_right'),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),

              // Interactive Ruler + Image Area
              Expanded(
                child: Row(
                  children: [
                    // Model Asset Image
                    Expanded(
                      flex: 5,
                      child: Padding(
                        // Gap between the image and the (left-shifted) ruler
                        padding: const EdgeInsets.only(right: 36),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            widget.gender == Gender.male ? 'assets/boy.png' : 'assets/girl.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Movable Interactive Vertical Ruler + Tips card beside it
                    Expanded(
                      flex: 4,
                      child: Stack(
                        clipBehavior: Clip.none, // pointer line extends into the image area
                        children: [
                          // Ruler keeps full height, shifted left to leave room for the card
                          Positioned.fill(
                            child: Transform.translate(
                              offset: const Offset(-20, 0),
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
                          ),

                          // Tips for Accuracy Card
                          Positioned(
                            right: 0,
                            bottom: 12,
                            child: Container(
                              width: 84,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF7CB342),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.tr('onboarding_tips_for_accuracy'),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('onboarding_height_tip_body'),
                                    style: const TextStyle(
                                      fontSize: 8.5,
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
                  ],
                ),
              ),

              const SizedBox(height: 12),
              OnboardingButton(
                text: context.tr('common_next'),
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

  static const double minInches = 42.0; // 3.5 ft
  static const double maxInches = 90.0; // 7.5 ft

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E4D38)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final dashedPaint = Paint()
      ..color = const Color(0xFF2E4D38)
      ..strokeWidth = 2;

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

    // Scale definition in the selected unit:
    // ft/in -> tick every inch, medium every 6 in, labelled every foot
    // cm    -> tick every 2 cm, medium every 10 cm, labelled every 20 cm
    final double unitsPerInch = isCm ? 2.54 : 1.0;
    final int step = isCm ? 2 : 1;
    final int mediumEvery = isCm ? 10 : 6;
    final int majorEvery = isCm ? 20 : 12;

    final double minValue = minInches * unitsPerInch;
    final double maxValue = maxInches * unitsPerInch;

    // Draw Vertical Ruler Scale Marks
    for (int v = (minValue / step).ceil() * step; v <= maxValue; v += step) {
      double y = size.height * (1 - (v - minValue) / (maxValue - minValue));
      bool isMajor = v % majorEvery == 0;
      double tickLength = isMajor ? 28 : (v % mediumEvery == 0 ? 18 : 10);

      canvas.drawLine(Offset(0, y), Offset(tickLength, y), paint);

      // Major Unit Labels (e.g., 4, 5, 6, 7 feet or 120, 140 ... cm)
      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: isCm ? "$v" : "${v ~/ 12}",
            style: const TextStyle(
              color: Color(0xFF2E4D38),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, Offset(tickLength + 8, y - textPainter.height / 2));
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
  static const double _kgPerLb = 0.45359237;
  static const double _minKg = 30.0;
  static const double _maxKg = 200.0;

  // Pixels per displayed unit (1 kg or 1 lb) on the horizontal ruler
  static const double _rulerSpacing = 10.0;

  // BMI category colors
  static const Color _underColor = Color(0xFF3B82F6);
  static const Color _normalColor = Color(0xFF0E9F8A);
  static const Color _overColor = Color(0xFFF59E0B);
  static const Color _obeseColor = Color(0xFFEF4444);

  bool _isKg = true;
  double _weightKg = 65.5;

  double get _displayValue => _isKg ? _weightKg : _weightKg / _kgPerLb;

  // Changes the weight by [delta] in the currently displayed unit
  void _changeBy(double delta) {
    setState(() {
      final deltaKg = _isKg ? delta : delta * _kgPerLb;
      _weightKg = (_weightKg + deltaKg).clamp(_minKg, _maxKg);
    });
  }

  // Calculate BMI: weight (kg) / (height (m))^2
  double get _bmi {
    final heightInMeters = widget.userHeightCm / 100;
    if (heightInMeters <= 0) return 22.0;
    return _weightKg / (heightInMeters * heightInMeters);
  }

  // Determine BMI Status & Color
  ({String label, Color color}) _bmiCategory(BuildContext context) {
    final bmi = _bmi;
    if (bmi < 18.5) {
      return (label: context.tr('onboarding_bmi_underweight'), color: _underColor);
    } else if (bmi < 25.0) {
      return (label: context.tr('onboarding_bmi_normal'), color: _normalColor);
    } else if (bmi < 30.0) {
      return (label: context.tr('onboarding_bmi_overweight'), color: _overColor);
    } else {
      return (label: context.tr('onboarding_bmi_obese'), color: _obeseColor);
    }
  }

  // Position (0..1) of the BMI marker on the 4 equal-width category segments
  double get _bmiBarPosition {
    const bounds = [15.0, 18.5, 25.0, 30.0, 40.0];
    final bmi = _bmi.clamp(bounds.first, bounds.last);
    for (int i = 0; i < 4; i++) {
      if (bmi <= bounds[i + 1]) {
        final t = (bmi - bounds[i]) / (bounds[i + 1] - bounds[i]);
        return (i + t) / 4;
      }
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F3),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    StepHeader(
                      title: context.tr('onboarding_weight_title'),
                      subtitle: context.tr('onboarding_weight_subtitle'),
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

                    _buildWeightCard(),
                    const SizedBox(height: 16),
                    _buildBmiCard(context),

                    const Spacer(),
                    const SizedBox(height: 16),
                    OnboardingButton(
                      text: context.tr('common_next'),
                      onPressed: () => widget.onNext(double.parse(_weightKg.toStringAsFixed(1))),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Weight value, +/- buttons and the draggable ruler
  Widget _buildWeightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _displayValue.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isKg ? "kg" : "lbs",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.black12),
              const SizedBox(width: 16),
              _buildStepButton(Icons.add, () => _changeBy(0.1)),
              const SizedBox(width: 10),
              _buildStepButton(Icons.remove, () => _changeBy(-0.1)),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Horizontal Weight Ruler (ticks scroll under a fixed center thumb)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              // Drag left increases weight, right decreases
              _changeBy(-details.delta.dx / _rulerSpacing);
            },
            child: CustomPaint(
              size: const Size(double.infinity, 90),
              painter: HorizontalRulerPainter(
                value: _displayValue,
                spacing: _rulerSpacing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(BuildContext context) {
    final category = _bmiCategory(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('onboarding_your_bmi'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.selection,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.accessibility_new, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      category.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: category.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('onboarding_bmi_disclaimer'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBmiScale(context, category.color),
        ],
      ),
    );
  }

  // 4-segment BMI scale with a marker at the current BMI
  Widget _buildBmiScale(BuildContext context, Color markerColor) {
    final segments = [
      (label: context.tr('onboarding_bmi_underweight'), range: '<18.5', color: _underColor),
      (label: context.tr('onboarding_bmi_normal_short'), range: '18.5 - 24.9', color: _normalColor),
      (label: context.tr('onboarding_bmi_overweight'), range: '25 - 29.9', color: _overColor),
      (label: context.tr('onboarding_bmi_obese'), range: '≥30', color: _obeseColor),
    ];

    // Note: no LayoutBuilder here — this screen sits in SliverFillRemaining,
    // which needs intrinsic sizes, and LayoutBuilder can't provide them.
    final markerFraction = _bmiBarPosition.clamp(0.03, 0.97);
    const labelWidth = 40.0;

    return SizedBox(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Category labels
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                for (final s in segments)
                  Expanded(
                    child: Text(
                      s.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: s.color),
                    ),
                  ),
              ],
            ),
          ),
          // Colored bar
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              children: [
                for (int i = 0; i < segments.length; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < segments.length - 1 ? 2 : 0),
                      decoration: BoxDecoration(
                        color: segments[i].color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Range labels
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Row(
              children: [
                for (final s in segments)
                  Expanded(
                    child: Text(
                      s.range,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: s.color),
                    ),
                  ),
              ],
            ),
          ),
          // Marker: dot on the bar, line down, and BMI value.
          // The box spans 0..markerFraction of the width; the marker is centered on its right edge.
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            height: 54,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: markerFraction,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    right: -labelWidth / 2,
                    width: labelWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: markerColor, width: 3),
                          ),
                        ),
                        Container(width: 2, height: 22, color: markerColor),
                        const SizedBox(height: 2),
                        Text(
                          _bmi.toStringAsFixed(1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: markerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.accentGreen,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
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

// Custom Painter for Horizontal Ruler Scale: ticks scroll under a fixed center
// thumb with a value bubble above it.
class HorizontalRulerPainter extends CustomPainter {
  final double value;
  final double spacing;

  HorizontalRulerPainter({required this.value, this.spacing = 10.0});

  static const Color _dark = Color(0xFF1E3A2B);

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = _dark.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    const double baseY = 58; // bottom line of the ticks
    const double labelY = 66;

    // Base line
    canvas.drawLine(Offset(0, baseY), Offset(size.width, baseY), tickPaint);

    // Ticks at every whole unit, positioned by their real value
    final int halfCount = (centerX / spacing).ceil() + 1;
    final int first = value.floor() - halfCount;
    final int last = value.ceil() + halfCount;

    for (int v = first; v <= last; v++) {
      if (v <= 0) continue;
      final double x = centerX + (v - value) * spacing;
      if (x < 0 || x > size.width) continue;

      final bool isMajor = v % 10 == 0;
      final double tickHeight = isMajor ? 20 : (v % 5 == 0 ? 14 : 8);
      canvas.drawLine(Offset(x, baseY - tickHeight), Offset(x, baseY), tickPaint);

      if (isMajor) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: "$v",
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, labelY));
      }
    }

    // Center thumb: stem + dot
    final thumbPaint = Paint()..color = _dark;
    canvas.drawRect(Rect.fromLTWH(centerX - 1.5, 26, 3, baseY - 26), thumbPaint);
    canvas.drawCircle(Offset(centerX, baseY), 6, thumbPaint);
    canvas.drawCircle(Offset(centerX, baseY), 2.5, Paint()..color = AppColors.accentGreen);

    // Value bubble above the thumb
    final bubbleText = TextPainter(
      text: TextSpan(
        text: value.toStringAsFixed(1),
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, 12),
        width: bubbleText.width + 16,
        height: 22,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bubbleRect, thumbPaint);
    final arrow = Path()
      ..moveTo(centerX - 5, 23)
      ..lineTo(centerX + 5, 23)
      ..lineTo(centerX, 28)
      ..close();
    canvas.drawPath(arrow, thumbPaint);
    bubbleText.paint(
      canvas,
      Offset(centerX - bubbleText.width / 2, 12 - bubbleText.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant HorizontalRulerPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.spacing != spacing;
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
  final Gender gender;

  // Lets the same screen serve both "current" and "target" body shape
  final String titleKey;

  const BodyShapeStep({
    super.key,
    required this.onNext,
    required this.gender,
    this.titleKey = 'onboarding_body_shape_title',
  });

  @override
  State<BodyShapeStep> createState() => _BodyShapeStepState();
}

class _BodyShapeStepState extends State<BodyShapeStep> {
  int _selectedIndex = 2; // Default selected: Average
  late PageController _pageController;

  // Shape ids in order from leanest to heaviest. Images are
  // assets/{girl|boy}_{id}.png and texts use onboarding_body_shape_{id}_*.
  static const List<String> _shapeIds = [
    'lean', 'fit', 'avg', 'soft', 'curvy', 'heavy', 'obese',
  ];

  static const Map<String, String> _englishTitles = {
    'lean': 'Lean', 'fit': 'Fit', 'avg': 'Average', 'soft': 'Soft',
    'curvy': 'Curvy', 'heavy': 'Heavy', 'obese': 'Obese',
  };

  // Estimated body fat ranges differ between women and men
  static const Map<String, String> _femaleFatRanges = {
    'lean': '14% - 17%', 'fit': '18% - 21%', 'avg': '22% - 25%', 'soft': '26% - 29%',
    'curvy': '30% - 33%', 'heavy': '34% - 39%', 'obese': '40%+',
  };

  static const Map<String, String> _maleFatRanges = {
    'lean': '6% - 10%', 'fit': '11% - 14%', 'avg': '15% - 19%', 'soft': '20% - 24%',
    'curvy': '25% - 29%', 'heavy': '30% - 34%', 'obese': '35%+',
  };

  // Rebuilt from the current gender so going back and changing it updates the images
  List<BodyShapeData> get _shapes => _buildShapes();

  List<BodyShapeData> _buildShapes() {
    final isMale = widget.gender == Gender.male;
    final prefix = isMale ? 'boy' : 'girl';
    final ranges = isMale ? _maleFatRanges : _femaleFatRanges;

    return [
      for (int i = 0; i < _shapeIds.length; i++)
        BodyShapeData(
          id: _shapeIds[i],
          title: _englishTitles[_shapeIds[i]]!,
          subtitle: '',
          imagePath: 'assets/${prefix}_${_shapeIds[i]}.png',
          fatLevel: i <= 1 ? 'Lower' : (i <= 4 ? 'Moderate' : 'Higher'),
          fatRange: ranges[_shapeIds[i]]!,
          feedbackText: '',
        ),
    ];
  }

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

  String _shapeTitle(BuildContext context, String id) =>
      context.tr('onboarding_body_shape_${id}_title');

  String _shapeSubtitle(BuildContext context, String id) =>
      context.tr('onboarding_body_shape_${id}_subtitle');

  String _shapeFeedback(BuildContext context, String id) =>
      context.tr('onboarding_body_shape_${id}_feedback');

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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: StepHeader(
                    title: context.tr(widget.titleKey),
                    subtitle: context.tr('onboarding_body_shape_subtitle'),
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
                                color: Colors.black.withValues(alpha: 0.03),
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
                                    _shapeTitle(context, item.id),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _shapeSubtitle(context, item.id),
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
                Text(
                  context.tr('onboarding_body_fat_question'),
                  style: const TextStyle(
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
                            // Leanest shape at the far left, heaviest at the far right
                            alignment: Alignment(
                              -1 + 2 * _selectedIndex / (_shapes.length - 1),
                              0,
                            ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(context.tr('onboarding_fat_level_lower'),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                          Text(context.tr('onboarding_fat_level_moderate'),
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.textSecondary)),
                          Text(context.tr('onboarding_fat_level_higher'),
                              style: const TextStyle(
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
                          color: Colors.black.withValues(alpha: 0.02),
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
                              Text(
                                context.tr('onboarding_estimated_body_fat_label'),
                                style: const TextStyle(
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
                                _shapeFeedback(context, currentShape.id),
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
                    text: context.tr('common_next'),
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

  void _submit() {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr('onboarding_activity_required')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    widget.onNext(_selectedLevel!);
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
              StepHeader(
                title: context.tr('onboarding_activity_title'),
                subtitle: context.tr('onboarding_activity_subtitle'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLevelCard(
                      level: ActivityLevel.sedentary,
                      title: context.tr('onboarding_activity_sedentary_title'),
                      subtitle: context.tr('onboarding_activity_sedentary_subtitle'),
                      icon: Icons.chair_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.light, // Updated from lightlyActive
                      title: context.tr('onboarding_activity_light_title'),
                      subtitle: context.tr('onboarding_activity_light_subtitle'),
                      icon: Icons.desktop_windows_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.moderate, // Updated from moderatelyActive
                      title: context.tr('onboarding_activity_moderate_title'),
                      subtitle: context.tr('onboarding_activity_moderate_subtitle'),
                      icon: Icons.directions_walk_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.active, // Updated to match domain entity
                      title: context.tr('onboarding_activity_active_title'),
                      subtitle: context.tr('onboarding_activity_active_subtitle'),
                      icon: Icons.fitness_center_outlined,
                    ),
                    _buildLevelCard(
                      level: ActivityLevel.veryActive, // Updated from extremelyActive
                      title: context.tr('onboarding_activity_very_active_title'),
                      subtitle: context.tr('onboarding_activity_very_active_subtitle'),
                      icon: Icons.directions_run_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OnboardingButton(
                text: context.tr('common_next'),
                onPressed: _submit,
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
                color: Colors.black.withValues(alpha: 0.02),
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
                    : AppColors.textSecondary.withValues(alpha: 0.6),
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

  static const List<String> _dayKeys = [
    'onboarding_weekday_sun',
    'onboarding_weekday_mon',
    'onboarding_weekday_tue',
    'onboarding_weekday_wed',
    'onboarding_weekday_thu',
    'onboarding_weekday_fri',
    'onboarding_weekday_sat',
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
              StepHeader(
                title: context.tr('onboarding_frequency_title'),
                subtitle: context.tr('onboarding_frequency_subtitle'),
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
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      context.tr('onboarding_you_selected'),
                      style: const TextStyle(
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
                    Text(
                      context.tr('onboarding_days_per_week'),
                      style: const TextStyle(
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
                      color: Colors.black.withValues(alpha: 0.02),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('onboarding_consistency_key_title'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('onboarding_consistency_key_body'),
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

              const SizedBox(height: 20),

              // Action Button
              OnboardingButton(
                text: context.tr('common_next'),
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
            context.tr(_dayKeys[index]),
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
              StepHeader(
                title: context.tr('onboarding_fitness_level_title'),
                subtitle: context.tr('onboarding_fitness_level_subtitle'),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildLevelCard(
                      title: "Beginner",
                      subtitle: "New to exercise or just getting started.",
                      displayTitle: context.tr('onboarding_fitness_level_beginner_title'),
                      displaySubtitle: context.tr('onboarding_fitness_level_beginner_subtitle'),
                      imagePath: "assets/begnner.png",
                    ),
                    _buildLevelCard(
                      title: "Middle",
                      subtitle: "Some experience and exercise occasionally.",
                      displayTitle: context.tr('onboarding_fitness_level_middle_title'),
                      displaySubtitle: context.tr('onboarding_fitness_level_middle_subtitle'),
                      imagePath: "assets/middle.png",
                    ),
                    _buildLevelCard(
                      title: "Advanced",
                      subtitle: "Experienced and work out regularly with intensity.",
                      displayTitle: context.tr('onboarding_fitness_level_advanced_title'),
                      displaySubtitle: context.tr('onboarding_fitness_level_advanced_subtitle'),
                      imagePath: "assets/advance.png",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('onboarding_fitness_level_footer_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),
              OnboardingButton(
                text: context.tr('common_next'),
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
    String? displayTitle,
    String? displaySubtitle,
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
                color: Colors.black.withValues(alpha: 0.02),
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
                        displayTitle ?? title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displaySubtitle ?? subtitle,
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
                              color: Colors.black.withValues(alpha: 0.02),
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