import 'package:flutter/foundation.dart';

/// Immutable domain model for a single timetable entry, including
/// its resolved subject name for display.
@immutable
class TimetableEntryItem {
  const TimetableEntryItem({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.dayOfWeek,
    required this.startMinutes,
    required this.endMinutes,
    required this.room,
  });

  final int id;
  final int subjectId;
  final String subjectName;
  final int dayOfWeek;
  final int startMinutes;
  final int endMinutes;
  final String room;

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get dayLabel => weekdayNames[dayOfWeek - 1];
  String get startLabel => _formatMinutes(startMinutes);
  String get endLabel => _formatMinutes(endMinutes);

  static String _formatMinutes(int minutes) {
    final hour = (minutes ~/ 60).toString().padLeft(2, '0');
    final minute = (minutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}