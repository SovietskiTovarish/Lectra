import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/timetable/controller.dart';
import 'package:lectra/features/timetable/model.dart';

/// Displays the full weekly class timetable (read-only list with
/// delete). Classes are added/edited from the Subjects tab, where a
/// subject's entire weekly schedule is managed in one place.
class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timetableControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: entriesAsync.when(
        data: (entries) => _TimetableList(entries: entries),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _TimetableList extends ConsumerWidget {
  const _TimetableList({required this.entries});

  final List<TimetableEntryItem> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('No classes yet. Add one from the Subjects tab.'),
      );
    }
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          title: Text(entry.subjectName),
          subtitle: Text(
            '${entry.dayLabel} · ${entry.startLabel} - ${entry.endLabel}'
            '${entry.room.isNotEmpty ? ' · ${entry.room}' : ''}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref
                .read(timetableControllerProvider.notifier)
                .deleteLectureSlot(entry.id),
          ),
        );
      },
    );
  }
}