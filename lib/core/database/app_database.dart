import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// ============================================================================
/// Subjects
/// ============================================================================
///
/// Stores one enrolled subject.
class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Official subject name.
  TextColumn get name =>
      text().unique().withLength(min: 1, max: 100)();

  /// Optional course code.
  TextColumn get code =>
      text().nullable().withLength(min: 1, max: 20)();

  /// Optional nickname used in compact UI.
  TextColumn get nickname =>
      text().nullable().withLength(min: 1, max: 30)();

  /// Faculty / professor name.
  TextColumn get facultyName =>
      text().nullable().withLength(min: 1, max: 100)();

  /// Material color used throughout the application.
  IntColumn get accentColor => integer()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// ============================================================================
/// Weekly Lecture Slots
/// ============================================================================
///
/// Recurring lecture schedule.
class WeeklyLectureSlots extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get subjectId => integer().references(
        Subjects,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Monday = 1 ... Sunday = 7
  IntColumn get dayOfWeek => integer()();

  /// Minutes since midnight.
  IntColumn get startMinutes => integer()();

  /// Minutes since midnight.
  IntColumn get endMinutes => integer()();

  TextColumn get room =>
      text().withDefault(const Constant(''))();

  @override
  List<String> get customConstraints => [
        'CHECK(day_of_week BETWEEN 1 AND 7)',
        'CHECK(start_minutes < end_minutes)',
      ];
}

/// ============================================================================
/// Attendance Records
/// ============================================================================
///
/// One attendance entry for one lecture occurrence.
class AttendanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get subjectId => integer().references(
        Subjects,
        #id,
        onDelete: KeyAction.cascade,
      )();

  DateTimeColumn get date => dateTime()();

  TextColumn get status => text().withDefault(
        const Constant('present'),
      )();

  @override
  List<String> get customConstraints => [
        "CHECK(status IN ('present','absent','cancelled','holiday','rescheduled'))",
      ];
}

/// ============================================================================
/// Database
/// ============================================================================
@DriftDatabase(
  tables: [
    Subjects,
    WeeklyLectureSlots,
    AttendanceRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (kDebugMode) {
            // Development only: freely reset schema while the app is
            // under active development, since debug installs have no
            // user data worth preserving.
            await m.deleteTable('attendance_records');
            await m.deleteTable('weekly_lecture_slots');
            await m.deleteTable('subjects');

            await m.createAll();
            return;
          }

          // Release builds must never silently destroy user data.
          // Add real, additive `StepByStep`/`m.addColumn` style
          // migrations here as the schema evolves, one case per
          // (from, to) version pair. Until those migrations exist,
          // fail loudly rather than deleting the user's subjects,
          // timetable, and attendance history.
          throw UnimplementedError(
            'No release migration defined from schema $from to $to. '
            'Add a non-destructive migration step before shipping '
            'this schema change.',
          );
        },
      );

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationDocumentsDirectory();

      final file = File(
        p.join(directory.path, 'lectra.sqlite'),
      );

      return NativeDatabase.createInBackground(file);
    });
  }
}