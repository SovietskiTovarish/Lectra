import 'package:flutter/material.dart';
import 'package:lectra/features/attendance/model.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/subjects/widgets/attendance_analytics_card.dart';
import 'package:lectra/features/subjects/widgets/subject_info_card.dart';
import 'package:lectra/features/subjects/widgets/weekly_schedule_card.dart';
import 'package:lectra/features/timetable/model.dart';
import 'package:lectra/shared/widgets/attendance_pie_chart.dart';

/// List-mode body of the Subject Detail screen: info card, pie
/// chart, stat rows, analytics, weekly schedule, and raw history.
class AttendanceHistoryList extends StatelessWidget {
  const AttendanceHistoryList({
    required this.subject,
    required this.stats,
    required this.subjectColor,
    required this.records,
    required this.schedule,
    super.key,
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
        SubjectInfoCard(subject: subject),
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
        AttendanceAnalyticsCard(stats: stats, records: records),
        const SizedBox(height: 16),
        WeeklyScheduleCard(schedule: schedule, subjectColor: subjectColor),
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