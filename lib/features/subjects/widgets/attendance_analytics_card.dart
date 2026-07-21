import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/attendance/model.dart';
import 'package:lectra/features/settings/controller.dart';

/// Attendance analytics: a progress bar toward the attendance target
/// set in Settings, a headline call-out for exactly how many classes
/// need to be attended (or can be missed) to hit that target, and
/// the current attend/miss streak from the most recent records.
class AttendanceAnalyticsCard extends ConsumerWidget {
  const AttendanceAnalyticsCard({
    required this.stats,
    required this.records,
    super.key,
  });

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
    final label =
        leadingStatus == AttendanceStatus.present ? 'attended' : 'missed';
    return 'Current streak: $streak class${streak == 1 ? '' : 'es'} $label in a row.';
  }
}