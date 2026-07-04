import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/features/attendance/controller.dart';
import 'package:lectra/features/attendance/model.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/shared/widgets/attendance_pie_chart.dart';

/// Scrollable list of every enrolled subject.
///
/// This is a management and analytics view rather than a schedule
/// view — Today's Schedule and the Weekly Timetable now live on the
/// Dashboard. Each card is a glanceable summary (attendance
/// percentage, total/attended/missed classes) and is fully tappable
/// to open that subject's detail page.
class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: subjectsAsync.when(
        data: (subjects) => _SubjectsList(subjects: subjects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.addSubject),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SubjectsList extends StatelessWidget {
  const _SubjectsList({required this.subjects});

  final List<SubjectItem> subjects;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return const Center(child: Text('No subjects yet. Tap + to add one.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: subjects.length,
      itemBuilder: (context, index) => _SubjectCard(subject: subjects[index]),
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({required this.subject});

  final SubjectItem subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(subjectAttendanceStatsProvider(subject.id));
    final stats = statsAsync.valueOrNull ??
        const SubjectAttendanceStats(present: 0, absent: 0, cancelled: 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          RouteNames.subjectDetail,
          pathParameters: {'id': '${subject.id}'},
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AttendancePieChart(
                percentage: stats.percentage,
                size: 56,
                color: subject.accentColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subject.hasCode)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subject.code!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatChip(
                          label: 'Total',
                          value: '${stats.total}',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Attended',
                          value: '${stats.present}',
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Missed',
                          value: '${stats.absent}',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_SubjectCardAction>(
                icon: const Icon(Icons.more_vert),
                onSelected: (action) {
                  switch (action) {
                    case _SubjectCardAction.edit:
                      context.pushNamed(
                        RouteNames.editSubject,
                        pathParameters: {'id': '${subject.id}'},
                      );
                    case _SubjectCardAction.delete:
                      ref
                          .read(subjectsControllerProvider.notifier)
                          .deleteSubject(subject.id);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _SubjectCardAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _SubjectCardAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SubjectCardAction { edit, delete }

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chipColor = color ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$value $label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
