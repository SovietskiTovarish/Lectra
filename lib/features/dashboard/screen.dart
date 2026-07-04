import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/dashboard/widgets/daily_timeline.dart';
import 'package:lectra/features/dashboard/widgets/weekly_timetable_grid.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/controller.dart';
import 'package:lectra/features/timetable/model.dart';

/// The Dashboard is the app's primary home screen and central
/// navigation hub.
///
/// It replaces the old standalone Timetable tab: Today's Schedule
/// (a vertical calendar timeline) is the default view, and users can
/// switch to a traditional Weekly Timetable grid without leaving the
/// screen. Switching back to "Today" always restores today's
/// schedule. Both views read from [timetableControllerProvider], so
/// any schedule edit made from a Subject Detail page is reflected
/// here immediately with no manual refresh required.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showWeekly = false;
  DateTime _now = DateTime.now();
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    // Keep "current / upcoming class" highlighting accurate while the
    // dashboard is left open across a class boundary.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(timetableControllerProvider);
    final subjectsAsync = ref.watch(subjectsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_showWeekly ? 'Weekly Timetable' : "Today's Schedule"),
      ),
      body: Column(
        children: [
          // Kept out of the AppBar so it never has to compete with the
          // title for space — a SegmentedButton next to a title
          // overflowed on narrower phones.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Today'),
                  icon: Icon(Icons.today_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Weekly'),
                  icon: Icon(Icons.calendar_view_week_outlined),
                ),
              ],
              selected: {_showWeekly},
              onSelectionChanged: (selection) {
                // Selecting "Today" always restores the current day's
                // schedule rather than remembering weekly-view state.
                setState(() => _showWeekly = selection.first);
              },
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Could not load your schedule.\n$error'),
              ),
              data: (entries) {
                final subjects =
                    subjectsAsync.asData?.value ?? const <SubjectItem>[];
                final subjectsById = {for (final s in subjects) s.id: s};

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(timetableControllerProvider.notifier)
                        .refresh();
                    await ref
                        .read(subjectsControllerProvider.notifier)
                        .refresh();
                  },
                  child: _showWeekly
                      ? WeeklyTimetableGrid(
                          entries: entries,
                          subjectsById: subjectsById,
                          todayWeekday: _now.weekday,
                        )
                      : DailyTimeline(
                          entries: _todaysEntries(entries, _now.weekday),
                          subjectsById: subjectsById,
                          now: _now,
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TimetableEntryItem> _todaysEntries(
    List<TimetableEntryItem> all,
    int weekday,
  ) {
    final today = all.where((e) => e.dayOfWeek == weekday).toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return today;
  }
}