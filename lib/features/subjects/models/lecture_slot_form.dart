import 'package:flutter/material.dart';

/// Temporary form model used while creating or editing a subject.
///
/// This is **not** a database model.
///
/// It only stores the state of one lecture slot in the editor.
/// When the user presses Save, the repository converts these objects
/// into WeeklyLectureSlots rows.
class LectureSlotForm {
  LectureSlotForm({
    Set<int>? weekdays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    this.room = '',
  })  : weekdays = weekdays ?? <int>{1},
        startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 10, minute: 0);

  /// Monday = 1 ... Sunday = 7
  Set<int> weekdays;

  TimeOfDay startTime;

  TimeOfDay endTime;

  String room;

  int get startMinutes =>
      startTime.hour * 60 + startTime.minute;

  int get endMinutes =>
      endTime.hour * 60 + endTime.minute;

  bool get isValid =>
      weekdays.isNotEmpty &&
      endMinutes > startMinutes;

  LectureSlotForm copyWith({
    Set<int>? weekdays,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? room,
  }) {
    return LectureSlotForm(
      weekdays: weekdays ?? Set<int>.from(this.weekdays),
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}