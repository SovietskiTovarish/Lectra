import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/notifications/notification_service.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/controller.dart';

/// Keeps scheduled class-reminder notifications in sync with the
/// live subjects list and timetable.
///
/// This is a plain [Provider] rather than something explicitly
/// "called" — watching it anywhere in the widget tree (see
/// [lib/app.dart]) activates it for the app's lifetime, and it
/// re-runs [NotificationService.syncSchedule] automatically whenever
/// either dependency changes: adding/editing/deleting a subject,
/// or adding/editing/removing a weekly class. There's nothing extra
/// to wire up at each of those call sites — they already refresh
/// [subjectsControllerProvider] / [timetableControllerProvider], and
/// this provider reacts to that.
final notificationSchedulerProvider = Provider<void>((ref) {
  final subjectsAsync = ref.watch(subjectsControllerProvider);
  final entriesAsync = ref.watch(timetableControllerProvider);

  final subjects = subjectsAsync.valueOrNull;
  final entries = entriesAsync.valueOrNull;
  if (subjects == null || entries == null) return;

  final subjectsById = <int, SubjectItem>{
    for (final s in subjects) s.id: s,
  };

  // Fire-and-forget: a sync failure shouldn't block app startup or
  // navigation, so this intentionally isn't awaited here.
  NotificationService.instance
      .syncSchedule(entries: entries, subjectsById: subjectsById)
      .catchError(logNotificationError);
});