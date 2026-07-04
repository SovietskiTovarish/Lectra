import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/attendance/model.dart';
import 'package:lectra/features/attendance/repository.dart';
import 'package:lectra/features/notifications/notification_service.dart';
import 'package:lectra/features/timetable/controller.dart';

/// Exposes the [AttendanceRepository] for the attendance feature.
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(appDatabaseProvider));
});

/// Aggregated attendance stats for a single subject, keyed by
/// subject id.
final subjectAttendanceStatsProvider =
    FutureProvider.family<SubjectAttendanceStats, int>((ref, subjectId) {
  return ref.watch(attendanceRepositoryProvider).statsForSubject(subjectId);
});

/// Full attendance history for a single subject, keyed by subject id.
final subjectAttendanceRecordsProvider =
    FutureProvider.family<List<AttendanceRecordItem>, int>((ref, subjectId) {
  return ref.watch(attendanceRepositoryProvider).fetchForSubject(subjectId);
});

/// Handles marking attendance and refreshing dependent providers.
class AttendanceMarkingController extends Notifier<void> {
  @override
  void build() {}

  /// Marks attendance for [subjectId] on [date] and invalidates the
  /// stats/history providers for that subject so the UI refreshes.
  Future<void> markAttendance({
    required int subjectId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    await ref.read(attendanceRepositoryProvider).markAttendance(
          subjectId: subjectId,
          date: date,
          status: status,
        );
    ref.invalidate(subjectAttendanceStatsProvider(subjectId));
    ref.invalidate(subjectAttendanceRecordsProvider(subjectId));

    // Whatever the status — present, absent, or cancelled — the user
    // has now explicitly handled this occurrence, so the "you still
    // haven't marked attendance" follow-up nudge for it is no longer
    // needed. This only cancels *this* date's follow-up; the
    // reminder stays scheduled for every other occurrence.
    final entries = ref.read(timetableControllerProvider).valueOrNull;
    if (entries != null) {
      await NotificationService.instance.cancelFollowUpsFor(
        subjectId: subjectId,
        date: date,
        entries: entries,
      );
    }
  }
}

/// Provider for [AttendanceMarkingController].
final attendanceMarkingControllerProvider =
    NotifierProvider<AttendanceMarkingController, void>(
  AttendanceMarkingController.new,
);