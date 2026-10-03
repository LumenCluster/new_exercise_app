# Implementation Plan - Fix Images Not Showing

The user reports that the exercise GIF images are not showing. This could be due to missing internet permissions in the Android manifest, unstable GIF URLs, or CORS issues (if on Web).

## Proposed Changes

### Android Configuration
#### [MODIFY] [AndroidManifest.xml](file:///E:/untitled/android/app/src/main/AndroidManifest.xml)
- Add `<uses-permission android:name="android.permission.INTERNET"/>` to the main manifest to ensure the app can access network resources in all build modes.

### Data Layer
#### [MODIFY] [stretching_exercises.json](file:///E:/untitled/lib/data/stretching_exercises.json)
- Update GIF URLs to more stable, direct hotlink versions (e.g., using `i.giphy.com` instead of the complex `media.giphy.com` URLs). This improves reliability for mobile apps.

### UI Layer
#### [MODIFY] [exercise_library_screen.dart](file:///E:/untitled/lib/exercise_library_screen.dart)
- Add a timeout or improved error feedback in `_ExerciseMedia` to better handle slow or failing network requests.
- Ensure the `Image.network` widget specifies a `width` and `height` where possible to prevent layout issues during loading.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no regressions.

### Manual Verification
- The user will need to hot restart the app to clear the `ExerciseRepository` cache and reload the JSON data with the new URLs.
- Verify if the `Icons.image_not_supported_outlined` appears, which would indicate a persistent network or URL issue.
