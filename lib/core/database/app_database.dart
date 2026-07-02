import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Stores a single enrolled subject.
class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get code =>
      text().withLength(min: 0, max: 20).withDefault(const Constant(''))();
  IntColumn get colorValue => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Stores a single recurring timetable entry for a subject.
class TimetableEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId =>
      integer().references(Subjects, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek => integer()(); // 1 = Monday .. 7 = Sunday
  IntColumn get startMinutes => integer()(); // minutes since midnight
  IntColumn get endMinutes => integer()();
  TextColumn get room => text().withDefault(const Constant(''))();
}

/// Stores a single calendar event, holiday, or exam date.
class CalendarEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 150)();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text().withDefault(const Constant(''))();
  BoolColumn get isHoliday => boolean().withDefault(const Constant(false))();
}

/// The application's single offline Drift database.
///
/// Holds subjects, timetable entries, and calendar events. Opened
/// once via [appDatabaseProvider] and shared across all features.
@DriftDatabase(tables: [Subjects, TimetableEntries, CalendarEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used only by tests to inject an in-memory executor.
  AppDatabase.forTesting(super .executor);

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'lectra.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}