# Implementation Plan - Move to Fitness Screen after Onboarding

Create a new `FitnessScreen` to serve as the primary landing page after the onboarding process is completed. This screen will provide a dashboard-like experience focusing on the user's fitness goals and recommended exercises.

## Proposed Changes

### [Core UI & Navigation]

#### [NEW] [fitness_screen.dart](file:///E:/untitled/lib/features/profile/presentation/pages/fitness_screen.dart)
- Create a new `FitnessScreen` widget.
- It will receive the `UserProfile` (or fetch it from a provider if available).
- **Features**:
    - **Header**: User greeting ("Hello, [Name]") and current date.
    - **Summary Card**: Mini version of the BMI/Status card from the summary step.
    - **Today's Exercises**: A section showing a few recommended exercises fetched from `ExerciseRepository.recommendedSession`.
    - **Quick Actions**: Navigation buttons to "Meal Plan" and "Full Exercise Library".
- Use `FutureBuilder` to load exercises.

#### [MODIFY] [profile_input_screen.dart](file:///E:/untitled/lib/features/profile/presentation/pages/profile_input_screen.dart)
- Update the `_submit()` method:
    - Instead of navigating to `MealPlanScreen`, navigate to `FitnessScreen`.
    - Pass the generated `UserProfile` to the `FitnessScreen`.

### [Domain Mapping]
- Implement a helper to map `UserProfile.Goal` to `FitnessGoal` to ensure recommended exercises match the user's intent.

## Verification Plan

### Manual Verification
- Complete the onboarding flow.
- Ensure that after clicking "Continue to Part 2" on the summary screen, the app navigates to the new `FitnessScreen`.
- Verify the `FitnessScreen` displays the correct user name and BMI.
- Verify that recommended exercises are loaded and displayed.
- Test the navigation from `FitnessScreen` to `MealPlanScreen` and `ExerciseLibraryScreen`.
