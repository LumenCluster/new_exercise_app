# Implementation Plan - Navigate to Dashboard after Onboarding

Update the onboarding flow to navigate to the `DashboardScreen` instead of `FitnessScreen` upon completion.

## Proposed Changes

### Presentation Layer

#### [MODIFY] [ProfileInputScreen.dart](file:///E:/untitled/lib/features/profile/presentation/pages/profile_input_screen.dart)
- Import `DashboardScreen.dart`.
- Update `_submit()` method to use `Navigator.of(context).pushReplacement` to navigate to `DashboardScreen()`.

## Verification Plan

### Manual Verification
- Complete the full 26-step onboarding flow.
- Verify that clicking "Next" on the final `TargetBodyShapeStep` correctly navigates to the `DashboardScreen`.
- Ensure the `DashboardScreen` renders correctly after navigation.
