import 'package:flutter/foundation.dart';

/// Immutable domain model for a calendar event.
@immutable
class CalendarEventItem {
  const CalendarEventItem({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.isHoliday,
  });

  final int id;
  final String title;
  final DateTime date;
  final String description;
  final bool isHoliday;
}