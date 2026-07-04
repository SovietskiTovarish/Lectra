import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app's theme mode (system / light / dark).
///
/// In-memory only for now — it resets to [ThemeMode.system] on a
/// fresh app launch. To persist this across restarts, add the
/// `shared_preferences` package to pubspec.yaml and read/write the
/// value in [build]/[setThemeMode] instead of just holding it in
/// memory. See the comment on [SettingsController] for the same
/// note re: the attendance target.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Controls user-adjustable app preferences that affect behaviour
/// elsewhere in the app — currently just the attendance target used
/// by the Analytics section on the Subject Detail page.
///
/// Like [ThemeModeController], this is in-memory only. Persisting it
/// needs a storage layer; the simplest options are:
///   1. Add `shared_preferences: ^2.x` to pubspec.yaml and store a
///      double under a key like 'attendance_target', or
///      a string under 'theme_mode' for the controller above.
///   2. Add a small key-value settings table to the existing Drift
///      database (`AppDatabase`) alongside `weeklyLectureSlots` and
///      `subjects`, if you'd rather avoid a new dependency.
class SettingsController extends Notifier<double> {
  static const double defaultTarget = 75;

  @override
  double build() => defaultTarget;

  void setAttendanceTarget(double target) {
    state = target.clamp(1, 100);
  }
}

final attendanceTargetProvider =
    NotifierProvider<SettingsController, double>(SettingsController.new);
