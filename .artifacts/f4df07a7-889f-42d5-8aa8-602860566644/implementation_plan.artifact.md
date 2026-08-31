# Implementation Plan - Fix Sync Error & Display User Profile on Dashboard

This plan addresses the `DevFS synchronization failed` error and implements the profile display on the Dashboard.

## User Review Required

> [!IMPORTANT]
> **To fix the "DevFS synchronization failed" error:**
> 1. Stop the currently running app.
> 2. Run `flutter pub get` in your terminal.
> 3. Perform a cold boot/full rebuild by running the app again. Adding `sqflite` (a native plugin) requires a fresh build as hot reload cannot sync native binary changes.

## Proposed Changes

### Dashboard Feature

#### [MODIFY] [DashboardScreen.dart](file:///E:/untitled/lib/features/dashboard/presentation/DashboardScreen.dart)
* Import `DatabaseHelper` and `UserProfile`.
* Add state variables to store the loaded profile.
* Implement `_loadProfile()` in `initState` to fetch data from SQLite.
* Update the header to show the user's name dynamically.
* Add a new section `_buildProfileSummarySection()` to display onboarding inputs like Age, Weight, Goal, and Preferences.

## Verification Plan

### Manual Verification
* The user should verify that the app builds and runs successfully after the full rebuild.
* Confirm that the dashboard greeting shows their name.
* Confirm that a new "Your Profile Summary" section appears at the bottom of the dashboard.
