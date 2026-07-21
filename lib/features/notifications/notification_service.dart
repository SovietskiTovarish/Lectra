import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/model.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Which of the four reminders a scheduled notification represents,
/// relative to a single class occurrence.
enum ClassReminderType {
  /// 5 minutes before the class starts.
  before,

  /// 5 minutes after the class starts.
  duringStart,

  /// 5 minutes after the class ends — first "mark attendance" nudge.
  afterEnd,

  /// A follow-up nudge a few hours after the class ended, only
  /// meaningful if attendance still hasn't been marked. This is
  /// scheduled unconditionally along with the others, but is
  /// proactively cancelled by [NotificationService.cancelFollowUpsFor]
  /// as soon as the user marks attendance for that occurrence — see
  /// that method's doc comment for why it works this way instead of
  /// checking a condition at fire-time.
  followUp,
}

extension on ClassReminderType {
  int get typeIndex => switch (this) {
        ClassReminderType.before => 0,
        ClassReminderType.duringStart => 1,
        ClassReminderType.afterEnd => 2,
        ClassReminderType.followUp => 3,
      };
}

/// Wraps `flutter_local_notifications` to schedule the four
/// class-reminder notifications the app sends around every lecture
/// occurrence:
///
///  1. 5 minutes before the class starts.
///  2. 5 minutes after the class starts.
///  3. 5 minutes after the class ends (first attendance nudge).
///  4. [followUpDelay] after the class ends, if attendance is still
///     unmarked by then.
///
/// Local notifications can't run app logic at fire-time to check "is
/// attendance marked yet?" — there's no hook for that without a
/// background isolate. Instead, all four are scheduled up front for
/// every upcoming occurrence in the next [lookaheadDays] days, using
/// notification IDs that are deterministic functions of
/// (lecture slot id, occurrence date, reminder type). As soon as the
/// user marks attendance for a given subject/date,
/// [cancelFollowUpsFor] cancels *only* that occurrence's follow-up
/// notification by recomputing the same ID — leaving the reminder
/// scheduled for every other (still-unmarked) occurrence untouched.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'class_reminders';
  static const String _channelName = 'Class reminders';
  static const String _channelDescription =
      'Reminders before, during, and after your scheduled classes.';

  /// How far ahead to keep notifications scheduled. Re-synced every
  /// time the schedule changes or the app starts, so this is really
  /// just "how much buffer to keep queued" rather than a hard limit.
  static const int lookaheadDays = 14;

  /// How long after a class ends to send the "did you forget to mark
  /// attendance?" follow-up, if it's still unmarked by then.
  static const Duration followUpDelay = Duration(hours: 3);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Called with a subject id when the user taps a class-reminder
  /// notification. Deliberately a plain callback rather than this
  /// service importing `AppRouter` directly and navigating itself:
  /// `AppRouter` pulls in `SubjectDetailScreen`, which pulls in the
  /// attendance controller, which needs to call into this very
  /// service to cancel follow-up reminders — importing the router
  /// from here would close that into an import cycle. Set from
  /// [lib/app.dart], which already sits above both.
  void Function(int subjectId)? onTapSubject;

  /// Fixed reference date used to derive compact, stable per-day
  /// integers for notification IDs. Any fixed date works; this one
  /// just keeps the resulting numbers small.
  static final DateTime _idEpoch = DateTime(2024, 1, 1);

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Without setting the device's actual local location, `tz.local`
    // defaults to UTC, which would silently schedule every
    // notification at the wrong wall-clock time for anyone not in
    // UTC. `flutter_timezone` (or `flutter_native_timezone`) reads
    // the OS timezone name at runtime — wire it up here:
    //
    //   final locationName = await FlutterTimezone.getLocalTimezone();
    //   tz.setLocalLocation(tz.getLocation(locationName));
    //
    // Left as UTC for now; see the notification-setup notes for the
    // package addition and this one-line change.

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    // Exact-time scheduling on Android 12+ needs this separate
    // permission; without it, reminders can silently arrive late.
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final subjectId = int.tryParse(response.payload ?? '');
    if (subjectId == null) return;
    instance.onTapSubject?.call(subjectId);
  }

  /// Recomputes every upcoming occurrence for [entries] over the next
  /// [lookaheadDays] and (re)schedules all four reminders for each
  /// one. Cancels everything first, so this is safe to call any time
  /// the schedule, a subject, or a subject's color/name changes — it
  /// never leaves stale reminders behind for removed classes.
  Future<void> syncSchedule({
    required List<TimetableEntryItem> entries,
    required Map<int, SubjectItem> subjectsById,
  }) async {
    if (!_initialized) return;

    await _plugin.cancelAll();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final entry in entries) {
      for (var offset = 0; offset < lookaheadDays; offset++) {
        final occurrenceDay = today.add(Duration(days: offset));
        if (occurrenceDay.weekday != entry.dayOfWeek) continue;

        final subject = subjectsById[entry.subjectId];
        final subjectName = subject?.displayName ?? entry.subjectName;

        final startTime = _atMinutes(occurrenceDay, entry.startMinutes);
        final endTime = _atMinutes(occurrenceDay, entry.endMinutes);

        await _scheduleIfFuture(
          type: ClassReminderType.before,
          entry: entry,
          occurrenceDay: occurrenceDay,
          fireAt: startTime.subtract(const Duration(minutes: 5)),
          now: now,
          title: 'Upcoming class',
          body: '$subjectName starts in 5 minutes'
              '${entry.room.isNotEmpty ? ' • ${entry.room}' : ''}.',
        );

        await _scheduleIfFuture(
          type: ClassReminderType.duringStart,
          entry: entry,
          occurrenceDay: occurrenceDay,
          fireAt: startTime.add(const Duration(minutes: 5)),
          now: now,
          title: '$subjectName has started',
          body: "Hope it's going well — don't forget to mark "
              'attendance once it wraps up.',
        );

        await _scheduleIfFuture(
          type: ClassReminderType.afterEnd,
          entry: entry,
          occurrenceDay: occurrenceDay,
          fireAt: endTime.add(const Duration(minutes: 5)),
          now: now,
          title: 'Mark your attendance',
          body: '$subjectName just ended — tap to mark whether you '
              'attended.',
        );

        await _scheduleIfFuture(
          type: ClassReminderType.followUp,
          entry: entry,
          occurrenceDay: occurrenceDay,
          fireAt: endTime.add(followUpDelay),
          now: now,
          title: "Still haven't marked attendance?",
          body: "You haven't marked attendance for $subjectName today "
              'yet — tap to do it now.',
        );
      }
    }
  }

  Future<void> _scheduleIfFuture({
    required ClassReminderType type,
    required TimetableEntryItem entry,
    required DateTime occurrenceDay,
    required DateTime fireAt,
    required DateTime now,
    required String title,
    required String body,
  }) async {
    if (!fireAt.isAfter(now)) return;

    final id = _notificationId(
      slotId: entry.id,
      occurrenceDay: occurrenceDay,
      type: type,
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${entry.subjectId}',
    );
  }
  /// Cancels only the [ClassReminderType.followUp] reminder for the
  /// given subject's occurrence(s) on [date] — called right after the
  /// user marks attendance so they don't get nagged about a class
  /// they've already checked in for. Any other occurrence (past or
  /// future, marked or not) is untouched.
  Future<void> cancelFollowUpsFor({
    required int subjectId,
    required DateTime date,
    required List<TimetableEntryItem> entries,
  }) async {
    if (!_initialized) return;

    final occurrenceDay = DateTime(date.year, date.month, date.day);
    final matchingSlots = entries.where(
      (e) => e.subjectId == subjectId && e.dayOfWeek == occurrenceDay.weekday,
    );

    for (final entry in matchingSlots) {
      final id = _notificationId(
        slotId: entry.id,
        occurrenceDay: occurrenceDay,
        type: ClassReminderType.followUp,
      );
      await _plugin.cancel(id: id);
    }
  }

  DateTime _atMinutes(DateTime day, int minutes) {
    return DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);
  }

  /// Deterministic notification ID for one (lecture slot, occurrence
  /// date, reminder type) triple. Kept well within the platform's
  /// 32-bit notification ID range for any realistic slot count.
  int _notificationId({
    required int slotId,
    required DateTime occurrenceDay,
    required ClassReminderType type,
  }) {
    final epochDay = occurrenceDay.difference(_idEpoch).inDays;
    return slotId * 1000000 + epochDay * 10 + type.typeIndex;
  }
}

/// Convenience for logging scheduling failures without crashing the
/// app — a missed reminder shouldn't take down the UI.
void logNotificationError(Object error, StackTrace stackTrace) {
  if (kDebugMode) {
    debugPrint('NotificationService error: $error\n$stackTrace');
  }
}