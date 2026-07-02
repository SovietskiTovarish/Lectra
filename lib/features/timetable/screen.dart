import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/controller.dart';
import 'package:lectra/features/timetable/model.dart';

/// Displays the weekly class timetable and allows adding entries.
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEntryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddEntryDialog(BuildContext context, WidgetRef ref) async {
    final subjects = ref.read(subjectsControllerProvider).valueOrNull ?? [];
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a subject first')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _AddTimetableEntryDialog(subjects: subjects),
    );
  }
}

class _TimetableList extends ConsumerWidget {
  const _TimetableList({required this.entries});

  final List<TimetableEntryItem> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return const Center(child: Text('No classes yet. Tap + to add one.'));
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
                .deleteEntry(entry.id),
          ),
        );
      },
    );
  }
}

class _AddTimetableEntryDialog extends ConsumerStatefulWidget {
  const _AddTimetableEntryDialog({required this.subjects});

  final List<SubjectItem> subjects;

  @override
  ConsumerState<_AddTimetableEntryDialog> createState() =>
      _AddTimetableEntryDialogState();
}

class _AddTimetableEntryDialogState
    extends ConsumerState<_AddTimetableEntryDialog> {
  late int _subjectId = widget.subjects.first.id;
  int _dayOfWeek = 1;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  final _roomController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Class'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _subjectId,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: widget.subjects
                  .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _subjectId = value!),
            ),
            DropdownButtonFormField<int>(
              initialValue: _dayOfWeek,
              decoration: const InputDecoration(labelText: 'Day'),
              items: List.generate(
                TimetableEntryItem.weekdayNames.length,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(TimetableEntryItem.weekdayNames[i]),
                ),
              ),
              onChanged: (value) => setState(() => _dayOfWeek = value!),
            ),
            ListTile(
              title: const Text('Start time'),
              trailing: Text(_start.format(context)),
              onTap: () => _pickTime(isStart: true),
            ),
            ListTile(
              title: const Text('End time'),
              trailing: Text(_end.format(context)),
              onTap: () => _pickTime(isStart: false),
            ),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Room (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() => isStart ? _start = picked : _end = picked);
  }

  void _submit() {
    final startMinutes = _start.hour * 60 + _start.minute;
    final endMinutes = _end.hour * 60 + _end.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    ref.read(timetableControllerProvider.notifier).addEntry(
          subjectId: _subjectId,
          dayOfWeek: _dayOfWeek,
          startMinutes: startMinutes,
          endMinutes: endMinutes,
          room: _roomController.text.trim(),
        );
    Navigator.of(context).pop();
  }
}