import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/core/utils/subject_lookup.dart';
import 'package:lectra/features/attendance/controller.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/widgets/attendance_calendar_view.dart';
import 'package:lectra/features/subjects/widgets/attendance_history_list.dart';
import 'package:lectra/features/timetable/controller.dart';

/// Detailed view for a single subject: subject info, faculty, its
/// live weekly schedule, attendance stats with a pie chart, a
/// history/calendar toggle, and simple analytics — plus a shortcut
/// to edit the subject. The weekly-schedule section reads straight
/// from [timetableControllerProvider], so any change made on the
/// Add/Edit Subject screen (day, time, room, added/removed slots)
/// appears here — and on the Dashboard and Weekly Timetable — with
/// no manual refresh.
class SubjectDetailScreen extends ConsumerStatefulWidget {
  const SubjectDetailScreen({required this.subjectId, super.key});

  final int subjectId;

  @override
  ConsumerState<SubjectDetailScreen> createState() =>
      _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  bool _showCalendar = false;
  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(subjectsControllerProvider).valueOrNull ?? [];
    final subject = findSubjectById(subjects, widget.subjectId);
    final statsAsync = ref.watch(subjectAttendanceStatsProvider(widget.subjectId));
    final recordsAsync =
        ref.watch(subjectAttendanceRecordsProvider(widget.subjectId));
    final scheduleAsync = ref.watch(timetableControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject?.displayName ?? 'Subject'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit subject',
            onPressed: () => context.pushNamed(
              RouteNames.editSubject,
              pathParameters: {'id': '${widget.subjectId}'},
            ),
          ),
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      body: subject == null
          ? const Center(child: CircularProgressIndicator())
          : statsAsync.when(
              data: (stats) => _showCalendar
                  ? AttendanceCalendarView(
                      subjectId: widget.subjectId,
                      subjectColor: subject.accentColor,
                      visibleMonth: _visibleMonth,
                      onMonthChanged: (m) => setState(() => _visibleMonth = m),
                      records: recordsAsync.valueOrNull ?? [],
                    )
                  : AttendanceHistoryList(
                      subject: subject,
                      stats: stats,
                      subjectColor: subject.accentColor,
                      records: recordsAsync.valueOrNull ?? [],
                      schedule: (scheduleAsync.valueOrNull ?? const [])
                          .where((e) => e.subjectId == widget.subjectId)
                          .toList()
                        ..sort((a, b) {
                          final day = a.dayOfWeek.compareTo(b.dayOfWeek);
                          return day != 0
                              ? day
                              : a.startMinutes.compareTo(b.startMinutes);
                        }),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text('Error: $error')),
            ),
    );
  }
}