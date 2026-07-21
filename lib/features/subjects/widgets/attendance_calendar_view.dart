import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/attendance/controller.dart';
import 'package:lectra/features/attendance/model.dart';

/// Calendar-mode body of the Subject Detail screen: a month grid
/// where each day is tappable to mark attendance for that date.
class AttendanceCalendarView extends ConsumerWidget {
  const AttendanceCalendarView({
    required this.subjectId,
    required this.subjectColor,
    required this.visibleMonth,
    required this.onMonthChanged,
    required this.records,
    super.key,
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
      for (final r in records)
        DateTime(r.date.year, r.date.month, r.date.day): r.status,
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