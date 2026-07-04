import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/core/utils/subject_lookup.dart';
import 'package:lectra/features/attendance/controller.dart';
import 'package:lectra/features/attendance/model.dart';
import 'package:lectra/features/settings/controller.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/controller.dart';
import 'package:lectra/features/timetable/model.dart';
import 'package:lectra/shared/widgets/attendance_pie_chart.dart';

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
                  ? _CalendarView(
                      subjectId: widget.subjectId,
                      subjectColor: subject.accentColor,
                      visibleMonth: _visibleMonth,
                      onMonthChanged: (m) => setState(() => _visibleMonth = m),
                      records: recordsAsync.valueOrNull ?? [],
                    )
                  : _HistoryList(
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

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.subject,
    required this.stats,
    required this.subjectColor,
    required this.records,
    required this.schedule,
  });

  final SubjectItem subject;
  final SubjectAttendanceStats stats;
  final Color subjectColor;
  final List<AttendanceRecordItem> records;
  final List<TimetableEntryItem> schedule;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SubjectInfoCard(subject: subject),
        const SizedBox(height: 16),
        Center(
          child: AttendancePieChart(
            percentage: stats.percentage,
            size: 120,
            color: subjectColor,
          ),
        ),
        const SizedBox(height: 16),
        _StatRow(label: 'Total classes', value: stats.total),
        _StatRow(label: 'Present', value: stats.present),
        _StatRow(label: 'Absent', value: stats.absent),
        _StatRow(label: 'Cancelled', value: stats.cancelled),
        const SizedBox(height: 16),
        _AnalyticsCard(stats: stats, records: records),
        const SizedBox(height: 16),
        _WeeklyScheduleCard(schedule: schedule, subjectColor: subjectColor),
        const SizedBox(height: 16),
        if (records.isNotEmpty)
          const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        for (final record in records)
          ListTile(
            leading: Icon(_iconFor(record.status)),
            title: Text(_formatDate(record.date)),
            trailing: Text(record.status.name),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  IconData _iconFor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.cancelled:
        return Icons.event_busy_outlined;
    }
  }
}

/// Subject information: full name, code, and faculty — with a quick
/// edit shortcut so the user doesn't have to hunt for it.
class _SubjectInfoCard extends StatelessWidget {
  const _SubjectInfoCard({required this.subject});

  final SubjectItem subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: subject.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name, style: theme.textTheme.titleMedium),
                  if (subject.hasCode)
                    Text(
                      'Code: ${subject.code}',
                      style: theme.textTheme.bodySmall,
                    ),
                  if (subject.hasFaculty)
                    Text(
                      'Faculty: ${subject.facultyName}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only display of the subject's live weekly schedule. Editing
/// happens on the Add/Edit Subject screen (reachable via the app bar
/// edit action); once saved, this list — and the Dashboard and
/// Weekly Timetable — update immediately since they all read from
/// the same [timetableControllerProvider].
class _WeeklyScheduleCard extends StatelessWidget {
  const _WeeklyScheduleCard({required this.schedule, required this.subjectColor});

  final List<TimetableEntryItem> schedule;
  final Color subjectColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_repeat, color: subjectColor, size: 20),
                const SizedBox(width: 8),
                Text('Weekly schedule', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            if (schedule.isEmpty)
              const Text('No weekly classes set yet. Tap edit to add some.')
            else
              for (final slot in schedule)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          slot.dayLabel,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text('${slot.startLabel} – ${slot.endLabel}'),
                      ),
                      if (slot.room.isNotEmpty)
                        Text(
                          slot.room,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Attendance analytics: a progress bar toward the attendance target
/// set in Settings, a headline call-out for exactly how many classes
/// need to be attended (or can be missed) to hit that target, and
/// the current attend/miss streak from the most recent records.
class _AnalyticsCard extends ConsumerWidget {
  const _AnalyticsCard({required this.stats, required this.records});

  final SubjectAttendanceStats stats;
  final List<AttendanceRecordItem> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(attendanceTargetProvider);
    final theme = Theme.of(context);
    final onTrack = stats.percentage >= target;
    final insight = _bufferInsight(target);
    final streak = _currentStreak();
    final statusColor = onTrack ? Colors.green : theme.colorScheme.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Analytics', style: theme.textTheme.titleSmall),
                const Spacer(),
                Text(
                  'Target ${target.round()}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  LinearProgressIndicator(
                    value: (stats.percentage / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: statusColor,
                  ),
                  // A thin marker showing exactly where the target
                  // line sits on the progress bar.
                  Align(
                    alignment: Alignment(
                      (2 * (target / 100).clamp(0, 1)) - 1,
                      0,
                    ),
                    child: Container(
                      width: 2,
                      height: 8,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Headline call-out: the actual number of classes needed
            // (or the buffer available), front and center.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    onTrack ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (streak != null) ...[
              const SizedBox(height: 10),
              Text(streak, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  String _bufferInsight(double target) {
    final counted = stats.present + stats.absent;
    if (counted == 0) return 'No attendance recorded yet for this subject.';

    final targetLabel = target.round();

    if (stats.percentage >= target) {
      // How many classes in a row can be missed before dropping
      // below target: solve present / (counted + x) >= target/100.
      final maxSkips = ((stats.present * 100 / target) - counted).floor();
      return maxSkips > 0
          ? 'You can miss $maxSkips more class${maxSkips == 1 ? '' : 'es'} '
              'and stay at or above $targetLabel% attendance.'
          : "You're right at the $targetLabel% line — missing another class "
              'will drop you below it.';
    } else {
      // How many consecutive classes must be attended to reach
      // target: solve (present + x) / (counted + x) >= target/100.
      // When target is 100%, the denominator below is 0 — with any
      // past absence already on the books, no number of future
      // attended classes can undo it, so handle that explicitly
      // instead of dividing by zero.
      if (target >= 100) {
        return stats.absent > 0
            ? 'You already have ${stats.absent} absence'
                '${stats.absent == 1 ? '' : 's'} recorded, so 100% '
                "attendance isn't reachable for this subject anymore."
            : 'Attend every remaining class to keep 100% attendance.';
      }

      final numerator = (target / 100 * counted) - stats.present;
      final denominator = 1 - (target / 100);
      final needed = (numerator / denominator).ceil().clamp(1, 1000);
      return 'Attend the next $needed class${needed == 1 ? '' : 'es'} in a row '
          'to reach $targetLabel% attendance.';
    }
  }

  String? _currentStreak() {
    final counted = records
        .where((r) => r.status != AttendanceStatus.cancelled)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (counted.isEmpty) return null;

    final leadingStatus = counted.first.status;
    var streak = 0;
    for (final record in counted) {
      if (record.status != leadingStatus) break;
      streak++;
    }
    final label = leadingStatus == AttendanceStatus.present
        ? 'attended'
        : 'missed';
    return 'Current streak: $streak class${streak == 1 ? '' : 'es'} $label in a row.';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CalendarView extends ConsumerWidget {
  const _CalendarView({
    required this.subjectId,
    required this.subjectColor,
    required this.visibleMonth,
    required this.onMonthChanged,
    required this.records,
  });

  final int subjectId;
  final Color subjectColor;
  final DateTime visibleMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final List<AttendanceRecordItem> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstDay.weekday - 1;
    final recordsByDay = {
      for (final r in records) DateTime(r.date.year, r.date.month, r.date.day): r.status,
    };

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month - 1),
              ),
            ),
            Text(
              '${visibleMonth.year}-${visibleMonth.month.toString().padLeft(2, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onMonthChanged(
                DateTime(visibleMonth.year, visibleMonth.month + 1),
              ),
            ),
          ],
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = index - leadingBlanks + 1;
              final date = DateTime(visibleMonth.year, visibleMonth.month, day);
              final status = recordsByDay[date];
              return GestureDetector(
                onTap: () => _showMarkDialog(context, ref, date),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _colorFor(status, context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text('$day'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _colorFor(AttendanceStatus? status, BuildContext context) {
    switch (status) {
      case AttendanceStatus.present:
        return subjectColor.withValues(alpha: 0.35);
      case AttendanceStatus.absent:
        return Theme.of(context).colorScheme.errorContainer;
      case AttendanceStatus.cancelled:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
      case null:
        return Colors.transparent;
    }
  }

  Future<void> _showMarkDialog(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
  ) async {
    final status = await showDialog<AttendanceStatus?>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(
          '${date.year}-${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
        ),
        children: [
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(AttendanceStatus.present),
            child: const Text('Present'),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(AttendanceStatus.absent),
            child: const Text('Absent'),
          ),
          SimpleDialogOption(
            onPressed: () =>
                Navigator.of(dialogContext).pop(AttendanceStatus.cancelled),
            child: const Text('Cancelled'),
          ),
        ],
      ),
    );
    if (status == null) return;
    await ref.read(attendanceMarkingControllerProvider.notifier).markAttendance(
          subjectId: subjectId,
          date: date,
          status: status,
        );
  }
}