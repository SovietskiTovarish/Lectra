import 'package:flutter/material.dart';
import 'package:lectra/features/timetable/model.dart';

/// Read-only display of a subject's live weekly schedule. Editing
/// happens on the Add/Edit Subject screen; once saved, this list —
/// and the Dashboard and Weekly Timetable — update immediately
/// since they all read from the same [timetableControllerProvider].
class WeeklyScheduleCard extends StatelessWidget {
  const WeeklyScheduleCard({
    required this.schedule,
    required this.subjectColor,
    super.key,
  });

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
                        Text(slot.room, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}