import 'package:flutter/foundation.dart';

/// The recorded outcome of a single class occurrence.
enum AttendanceStatus { present, absent, cancelled }

/// Storage helpers for [AttendanceStatus].
extension AttendanceStatusStorage on AttendanceStatus {
  String get storageValue => name;

  static AttendanceStatus fromStorage(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}

/// Immutable domain model for a single attendance record.
@immutable
class AttendanceRecordItem {
  const AttendanceRecordItem({
    required this.id,
    required this.subjectId,
    required this.date,
    required this.status,
  });

  final int id;
  final int subjectId;
  final DateTime date;
  final AttendanceStatus status;
}

/// Aggregated attendance counts for a subject.
@immutable
class SubjectAttendanceStats {
  const SubjectAttendanceStats({
    required this.present,
    required this.absent,
    required this.cancelled,
  });

  final int present;
  final int absent;
  final int cancelled;

  int get total => present + absent + cancelled;

  /// Percentage of counted classes (present + absent) attended.
  /// Cancelled classes are excluded from the denominator.
  double get percentage {
    final denominator = present + absent;
    if (denominator == 0) return 0;
    return present / denominator * 100;
  }
}