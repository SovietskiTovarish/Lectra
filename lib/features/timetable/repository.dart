import 'package:drift/drift.dart';
import 'package:lectra/core/database/app_database.dart';
import 'package:lectra/features/subjects/models/lecture_slot_form.dart';
import 'package:lectra/features/timetable/model.dart';

/// Repository responsible for all timetable operations.
///
/// A subject can have multiple recurring weekly lecture slots.
class TimetableRepository {
  TimetableRepository(this._db);

  final AppDatabase _db;

  // ===========================================================================
  // READ
  // ===========================================================================

  Future<List<TimetableEntryItem>> fetchAll() async {
    final query = _db.select(_db.weeklyLectureSlots).join([
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(
          _db.weeklyLectureSlots.subjectId,
        ),
      ),
    ])
      ..orderBy([
        OrderingTerm(
          expression: _db.weeklyLectureSlots.dayOfWeek,
        ),
        OrderingTerm(
          expression: _db.weeklyLectureSlots.startMinutes,
        ),
      ]);

    final rows = await query.get();

    return rows.map(_mapRow).toList();
  }

  Future<List<TimetableEntryItem>> fetchForSubject(
    int subjectId,
  ) async {
    final query = _db.select(_db.weeklyLectureSlots).join([
      innerJoin(
        _db.subjects,
        _db.subjects.id.equalsExp(
          _db.weeklyLectureSlots.subjectId,
        ),
      ),
    ])
      ..where(
        _db.weeklyLectureSlots.subjectId.equals(subjectId),
      )
      ..orderBy([
        OrderingTerm(
          expression: _db.weeklyLectureSlots.dayOfWeek,
        ),
        OrderingTerm(
          expression: _db.weeklyLectureSlots.startMinutes,
        ),
      ]);

    final rows = await query.get();

    return rows.map(_mapRow).toList();
  }

  // ===========================================================================
  // WRITE
  // ===========================================================================

  Future<void> replaceLectureSlots({
    required int subjectId,
    required List<LectureSlotForm> slots,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(_db.weeklyLectureSlots)
            ..where(
              (tbl) => tbl.subjectId.equals(subjectId),
            ))
          .go();

      for (final slot in slots) {
        for (final weekday in slot.weekdays) {
          await _db.into(_db.weeklyLectureSlots).insert(
                WeeklyLectureSlotsCompanion.insert(
                  subjectId: subjectId,
                  dayOfWeek: weekday,
                  startMinutes: slot.startMinutes,
                  endMinutes: slot.endMinutes,
                  room: Value(slot.room),
                ),
              );
        }
      }
    });
  }

  Future<void> deleteLectureSlot(
    int slotId,
  ) async {
    await (_db.delete(_db.weeklyLectureSlots)
          ..where(
            (tbl) => tbl.id.equals(slotId),
          ))
        .go();
  }

  // ===========================================================================
  // Mapping
  // ===========================================================================

  TimetableEntryItem _mapRow(
    TypedResult row,
  ) {
    final slot = row.readTable(
      _db.weeklyLectureSlots,
    );

    final subject = row.readTable(
      _db.subjects,
    );

    return TimetableEntryItem(
      id: slot.id,
      subjectId: slot.subjectId,
      subjectName: subject.name,
      dayOfWeek: slot.dayOfWeek,
      startMinutes: slot.startMinutes,
      endMinutes: slot.endMinutes,
      room: slot.room,
    );
  }
}