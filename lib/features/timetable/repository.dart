import 'package:drift/drift.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/features/timetable/model.dart';

/// Data access layer for timetable entries, backed by [AppDatabase].
class TimetableRepository {
  TimetableRepository(this._db);

  final AppDatabase _db;

  /// Returns all entries joined with their subject name, ordered by
  /// day of week then start time.
  Future<List<TimetableEntryItem>> fetchAll() async {
    final query = _db.select(_db.timetableEntries).join([
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(_db.timetableEntries.subjectId),
      ),
    ])
      ..orderBy([
        OrderingTerm(expression: _db.timetableEntries.dayOfWeek),
        OrderingTerm(expression: _db.timetableEntries.startMinutes),
      ]);

    final rows = await query.get();
    return rows.map(_toItem).toList();
  }

  /// Inserts a new timetable entry.
  Future<int> addEntry({
    required int subjectId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
    String room = '',
  }) {
    return _db.into(_db.timetableEntries).insert(
          TimetableEntriesCompanion.insert(
            subjectId: subjectId,
            dayOfWeek: dayOfWeek,
            startMinutes: startMinutes,
            endMinutes: endMinutes,
            room: Value(room),
          ),
        );
  }

  /// Deletes the timetable entry with the given [id].
  Future<void> deleteEntry(int id) {
    return (_db.delete(_db.timetableEntries)..where((t) => t.id.equals(id))).go();
  }

  TimetableEntryItem _toItem(TypedResult row) {
    final entry = row.readTable(_db.timetableEntries);
    final subject = row.readTable(_db.subjects);
    return TimetableEntryItem(
      id: entry.id,
      subjectId: entry.subjectId,
      subjectName: subject.name,
      dayOfWeek: entry.dayOfWeek,
      startMinutes: entry.startMinutes,
      endMinutes: entry.endMinutes,
      room: entry.room,
    );
  }
}