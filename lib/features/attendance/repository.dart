import 'package:drift/drift.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/features/attendance/model.dart';

/// Data access layer for attendance records, backed by [AppDatabase].
class AttendanceRepository {
  AttendanceRepository(this._db);

  final AppDatabase _db;

  /// Returns all attendance records for a subject, most recent first.
  Future<List<AttendanceRecordItem>> fetchForSubject(int subjectId) async {
    final rows = await (_db.select(_db.attendanceRecords)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_toItem).toList();
  }

  /// Computes aggregated attendance stats for a subject.
  Future<SubjectAttendanceStats> statsForSubject(int subjectId) async {
    final records = await fetchForSubject(subjectId);
    var present = 0;
    var absent = 0;
    var cancelled = 0;
    for (final record in records) {
      switch (record.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.cancelled:
          cancelled++;
      }
    }
    return SubjectAttendanceStats(
      present: present,
      absent: absent,
      cancelled: cancelled,
    );
  }

  /// Sets (or overwrites) the attendance status for a subject on a
  /// given date.
  Future<void> markAttendance({
    required int subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final existing = await (_db.select(_db.attendanceRecords)
          ..where((t) => t.subjectId.equals(subjectId) & t.date.equals(day)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.attendanceRecords).insert(
            AttendanceRecordsCompanion.insert(
              subjectId: subjectId,
              date: day,
              status: Value(status.storageValue),
            ),
          );
    } else {
      await (_db.update(_db.attendanceRecords)
            ..where((t) => t.id.equals(existing.id)))
          .write(AttendanceRecordsCompanion(status: Value(status.storageValue)));
    }
  }

  AttendanceRecordItem _toItem(AttendanceRecord row) {
    return AttendanceRecordItem(
      id: row.id,
      subjectId: row.subjectId,
      date: row.date,
      status: AttendanceStatusStorage.fromStorage(row.status),
    );
  }
}