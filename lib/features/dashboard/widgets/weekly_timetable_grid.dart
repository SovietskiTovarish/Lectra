import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/model.dart';

/// Traditional timetable grid: days of the week as columns, time of
/// day as rows, with every class placed at its true day/time.
class WeeklyTimetableGrid extends StatefulWidget {
  const WeeklyTimetableGrid({
    super.key,
    required this.entries,
    required this.subjectsById,
    required this.todayWeekday,
  });

  final List<TimetableEntryItem> entries;
  final Map<int, SubjectItem> subjectsById;
  final int todayWeekday;

  @override
  State<WeeklyTimetableGrid> createState() => _WeeklyTimetableGridState();
}

class _WeeklyTimetableGridState extends State<WeeklyTimetableGrid> {
  static const double _pxPerMinute = 1.2;
  static const double _hourLabelWidth = 52;
  static const double _dayColumnWidth = 128;
  static const double _headerHeight = 40;

  // Explicit controllers instead of implicit/primary ones — when this
  // widget sits inside a RefreshIndicator, an implicit vertical
  // SingleChildScrollView can end up fighting the RefreshIndicator's
  // own scroll notifications, causing jumpy/garbled rendering. Owning
  // the controllers ourselves avoids that.
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final subjectsById = widget.subjectsById;
    final todayWeekday = widget.todayWeekday;

    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_view_week_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No classes scheduled yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final dayStart =
        entries.map((e) => e.startMinutes).reduce((a, b) => a < b ? a : b);
    final dayEnd =
        entries.map((e) => e.endMinutes).reduce((a, b) => a > b ? a : b);

    final firstHour = dayStart ~/ 60;
    // Always at least one hour tall, and rounded up so a class ending
    // at, say, 14:05 still gets the full 14:00-15:00 hour row instead
    // of a fractional row that rounding error could clip.
    final lastHour = ((dayEnd + 59) ~/ 60).clamp(firstHour + 1, 48);
    final hourMarks = [for (var h = firstHour; h <= lastHour; h++) h];
    // Small buffer added on top of the exact pixel math so
    // floating-point rounding never places a chip's bottom edge a
    // fraction of a pixel past the Stack's bounds.
    final gridHeight = (lastHour - firstHour) * 60 * _pxPerMinute + 4;

    final entriesByDay = <int, List<TimetableEntryItem>>{
      for (var d = 1; d <= 7; d++) d: [],
    };
    for (final entry in entries) {
      entriesByDay[entry.dayOfWeek]?.add(entry);
    }
    for (final list in entriesByDay.values) {
      list.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    }

    return Scrollbar(
      controller: _verticalController,
      child: SingleChildScrollView(
        controller: _verticalController,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed time axis.
            SizedBox(
              width: _hourLabelWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _headerHeight),
                  SizedBox(
                    height: gridHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final hour in hourMarks)
                          Positioned(
                            top: (hour - firstHour) * 60 * _pxPerMinute - 6,
                            child: Text(
                              TimeOfDay(hour: hour % 24, minute: 0)
                                  .format(context),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Horizontally scrollable day columns.
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalController,
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var d = 1; d <= 7; d++)
                          SizedBox(
                            width: _dayColumnWidth,
                            height: _headerHeight,
                            child: _DayHeader(
                              label: TimetableEntryItem.weekdayNames[d - 1]
                                  .substring(0, 3),
                              isToday: d == todayWeekday,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: gridHeight,
                      child: Row(
                        children: [
                          for (var d = 1; d <= 7; d++)
                            SizedBox(
                              width: _dayColumnWidth,
                              height: gridHeight,
                              child: _DayColumn(
                                dayEntries: entriesByDay[d] ?? const [],
                                firstHour: firstHour,
                                lastHour: lastHour,
                                pxPerMinute: _pxPerMinute,
                                subjectsById: subjectsById,
                                isToday: d == todayWeekday,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.isToday});

  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isToday ? theme.colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? theme.colorScheme.onPrimaryContainer : null,
          ),
        ),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.dayEntries,
    required this.firstHour,
    required this.lastHour,
    required this.pxPerMinute,
    required this.subjectsById,
    required this.isToday,
  });

  final List<TimetableEntryItem> dayEntries;
  final int firstHour;
  final int lastHour;
  final double pxPerMinute;
  final Map<int, SubjectItem> subjectsById;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: outline)),
        color: isToday
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.08)
            : null,
      ),
      // Clip.none: the grid height already has a small rounding
      // buffer built in. If a slot ever did fall slightly outside
      // these bounds we want to see it rather than have it silently
      // disappear, which is what the previous hard-edge clip did.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var h = firstHour; h <= lastHour; h++)
            Positioned(
              top: (h - firstHour) * 60 * pxPerMinute,
              left: 0,
              right: 0,
              child: Divider(height: 1, color: outline.withValues(alpha: 0.5)),
            ),
          for (final entry in dayEntries)
            Positioned(
              top: (entry.startMinutes - firstHour * 60) * pxPerMinute,
              left: 2,
              right: 2,
              height: ((entry.endMinutes - entry.startMinutes) * pxPerMinute)
                  .clamp(4.0, double.infinity),
              child: _WeeklyClassChip(
                entry: entry,
                subject: subjectsById[entry.subjectId],
              ),
            ),
        ],
      ),
    );
  }
}

class _WeeklyClassChip extends StatelessWidget {
  const _WeeklyClassChip({required this.entry, required this.subject});

  final TimetableEntryItem entry;
  final SubjectItem? subject;

  @override
  Widget build(BuildContext context) {
    final color = subject?.accentColor ?? Theme.of(context).colorScheme.primary;
    final title = subject?.displayName ?? entry.subjectName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.pushNamed(
            RouteNames.subjectDetail,
            pathParameters: {'id': '${entry.subjectId}'},
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            alignment: Alignment.topLeft,
            // FittedBox scales the whole label block down to fit
            // whatever height this slot actually has. Very short
            // slots (a few minutes, or heavily zoomed grids) can be
            // shorter than two lines of labelSmall text at natural
            // size — without this, that overflows the Column by a
            // few pixels and throws a RenderFlex assertion. FittedBox
            // just shrinks the text instead of erroring.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    entry.startLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}