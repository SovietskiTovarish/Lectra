import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/model.dart';

/// Vertical calendar-style timeline for a single day.
///
/// Shows a time axis running from the first scheduled class of the
/// day to the last, positions each class block at its true start/end
/// time, fills the gaps with visible "Free period" blocks, and
/// highlights whichever class is currently in progress (or, if none
/// is, the next upcoming one). Every class block is tappable and
/// opens that subject's detail page.
class DailyTimeline extends StatelessWidget {
  const DailyTimeline({
    super.key,
    required this.entries,
    required this.subjectsById,
    required this.now,
  });

  /// Today's entries, already filtered to the current weekday and
  /// sorted by start time.
  final List<TimetableEntryItem> entries;
  final Map<int, SubjectItem> subjectsById;
  final DateTime now;

  /// Vertical pixels per minute of the day.
  static const double _pxPerMinute = 2.0;
  static const double _hourLabelWidth = 56;
  static const double _bottomPadding = 40;

  int get _nowMinutes => now.hour * 60 + now.minute;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.free_breakfast_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                'No lectures scheduled for today.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    final dayStart = entries.first.startMinutes;
    final dayEnd = entries
        .map((e) => e.endMinutes)
        .reduce((a, b) => a > b ? a : b);

    // Build a flat list of segments: either a class or a free gap,
    // in chronological order, so free time between classes is always
    // visible on the timeline. Segments are contiguous by
    // construction (each starts exactly where the previous ends), so
    // as long as we never inflate a segment's rendered height beyond
    // its natural duration, blocks can never overlap.
    final segments = <_Segment>[];
    var cursor = dayStart;
    for (final entry in entries) {
      if (entry.startMinutes > cursor) {
        segments.add(_Segment.free(cursor, entry.startMinutes));
      }
      segments.add(_Segment.classEntry(entry));
      cursor = entry.endMinutes > cursor ? entry.endMinutes : cursor;
    }

    final totalHeight = (dayEnd - dayStart) * _pxPerMinute + _bottomPadding;

    // Hour marks for the left-hand time axis, from the hour at/just
    // before the first class to the hour at/just after the last.
    final firstHour = dayStart ~/ 60;
    final lastHour = (dayEnd + 59) ~/ 60;
    final hourMarks = [for (var h = firstHour; h <= lastHour; h++) h];

    // Determine the current-or-next class for highlighting.
    TimetableEntryItem? current;
    TimetableEntryItem? upcoming;
    for (final entry in entries) {
      if (_nowMinutes >= entry.startMinutes && _nowMinutes < entry.endMinutes) {
        current = entry;
        break;
      }
      if (upcoming == null && entry.startMinutes > _nowMinutes) {
        upcoming = entry;
      }
    }
    final highlightId = current?.id ?? upcoming?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Time axis + hour guide lines.
            for (final hour in hourMarks)
              Positioned(
                top: (hour * 60 - dayStart) * _pxPerMinute,
                left: 0,
                right: 0,
                child: _HourGuide(hour: hour, labelWidth: _hourLabelWidth),
              ),
            // Segments (classes + free periods), offset past the axis.
            Positioned(
              top: 0,
              left: _hourLabelWidth + 12,
              right: 0,
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final segment in segments)
                    Positioned(
                      top: (segment.start - dayStart) * _pxPerMinute,
                      left: 0,
                      right: 0,
                      // True duration-based height, floored only at a
                      // couple of pixels so nothing collapses to zero.
                      // Never inflated beyond the natural gap to the
                      // next segment, so blocks can't overlap.
                      height: ((segment.end - segment.start) * _pxPerMinute)
                          .clamp(2.0, double.infinity),
                      child: segment.isClass
                          ? _ClassBlock(
                              entry: segment.entry!,
                              subject: subjectsById[segment.entry!.subjectId],
                              isHighlighted:
                                  segment.entry!.id == highlightId,
                            )
                          : _FreePeriodBlock(
                              minutes: segment.end - segment.start,
                            ),
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

class _Segment {
  _Segment.free(this.start, this.end) : entry = null;
  _Segment.classEntry(TimetableEntryItem this.entry)
      : start = entry.startMinutes,
        end = entry.endMinutes;

  final int start;
  final int end;
  final TimetableEntryItem? entry;

  bool get isClass => entry != null;
}

class _HourGuide extends StatelessWidget {
  const _HourGuide({required this.hour, required this.labelWidth});

  final int hour;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final label = TimeOfDay(hour: hour % 24, minute: 0).format(context);
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Divider(height: 1, color: color),
          ),
        ),
      ],
    );
  }
}

class _ClassBlock extends StatelessWidget {
  const _ClassBlock({
    required this.entry,
    required this.subject,
    required this.isHighlighted,
  });

  final TimetableEntryItem entry;
  final SubjectItem? subject;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final color = subject?.accentColor ?? Theme.of(context).colorScheme.primary;
    final title = subject?.displayName ?? entry.subjectName;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: color.withValues(alpha: isHighlighted ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.pushNamed(
            RouteNames.subjectDetail,
            pathParameters: {'id': '${entry.subjectId}'},
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: color,
                  width: isHighlighted ? 5 : 3,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            alignment: Alignment.centerLeft,
            // FittedBox scales the whole block's content down to fit
            // whatever height it's actually given. Very short classes
            // (or a densely-packed day) can be shorter than this
            // content's natural size, which previously threw a
            // RenderFlex overflow — now it just shrinks instead.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isHighlighted)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Now',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '${entry.startLabel} – ${entry.endLabel}'
                    '${entry.room.isNotEmpty ? ' • ${entry.room}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _FreePeriodBlock extends StatelessWidget {
  const _FreePeriodBlock({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    if (minutes < 8) return const SizedBox.shrink();
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final label = hours > 0
        ? '${hours}h${mins > 0 ? ' ${mins}m' : ''} free'
        : '${mins}m free';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: DottedFreeBox(label: label),
    );
  }
}

/// Simple free-period indicator with a dashed outline.
class DottedFreeBox extends StatelessWidget {
  const DottedFreeBox({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}