import 'package:drift/drift.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/features/calendar/model.dart';

/// Data access layer for calendar events, backed by [AppDatabase].
class CalendarRepository {
  CalendarRepository(this._db);

  final AppDatabase _db;

  /// Returns all calendar events ordered by date.
  Future<List<CalendarEventItem>> fetchAll() async {
    final rows = await (_db.select(_db.calendarEvents)
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
    return rows.map(_toItem).toList();
  }

  /// Inserts a new calendar event.
  Future<int> addEvent({
    required String title,
    required DateTime date,
    String description = '',
    bool isHoliday = false,
  }) {
    return _db.into(_db.calendarEvents).insert(
          CalendarEventsCompanion.insert(
            title: title,
            date: date,
            description: Value(description),
            isHoliday: Value(isHoliday),
          ),
        );
  }

  /// Deletes the calendar event with the given [id].
  Future<void> deleteEvent(int id) {
    return (_db.delete(_db.calendarEvents)..where((t) => t.id.equals(id))).go();
  }

  CalendarEventItem _toItem(CalendarEvent row) {
    return CalendarEventItem(
      id: row.id,
      title: row.title,
      date: row.date,
      description: row.description,
      isHoliday: row.isHoliday,
    );
  }
}