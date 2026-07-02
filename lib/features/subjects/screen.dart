import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/calendar/controller.dart';
import 'package:lectra/features/calendar/model.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/timetable/controller.dart';
import 'package:lectra/features/timetable/model.dart';

/// Combined screen for subjects, the weekly timetable, and calendar
/// events, presented as three tabs under one destination.
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Subjects'),
            Tab(text: 'Timetable'),
            Tab(text: 'Calendar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SubjectsTab(),
          _TimetableTab(),
          _CalendarTab(),
        ],
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  Widget _buildFab(BuildContext context) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _showAddSubjectDialog(context),
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => _showAddTimetableEntryDialog(context),
          child: const Icon(Icons.add),
        );
      default:
        return FloatingActionButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const _AddEventDialog(),
          ),
          child: const Icon(Icons.add),
        );
    }
  }

  Future<void> _showAddSubjectDialog(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                autofocus: true,
              ),
              TextField(
                controller: codeController,
                decoration:
                    const InputDecoration(labelText: 'Code (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                container.read(subjectsControllerProvider.notifier).addSubject(
                      name: name,
                      code: codeController.text.trim(),
                    );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddTimetableEntryDialog(BuildContext context) async {
    final container = ProviderScope.containerOf(context);
    final subjects = container.read(subjectsControllerProvider).valueOrNull ?? [];
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

class _SubjectsTab extends ConsumerWidget {
  const _SubjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsControllerProvider);
    return subjectsAsync.when(
      data: (subjects) => _SubjectsList(subjects: subjects),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

class _SubjectsList extends ConsumerWidget {
  const _SubjectsList({required this.subjects});

  final List<SubjectItem> subjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subjects.isEmpty) {
      return const Center(child: Text('No subjects yet. Tap + to add one.'));
    }
    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor:
                subject.color ?? Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
            ),
          ),
          title: Text(subject.name),
          subtitle: subject.code.isNotEmpty ? Text(subject.code) : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => ref
                .read(subjectsControllerProvider.notifier)
                .deleteSubject(subject.id),
          ),
        );
      },
    );
  }
}

class _TimetableTab extends ConsumerWidget {
  const _TimetableTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(timetableControllerProvider);
    return entriesAsync.when(
      data: (entries) => _TimetableList(entries: entries),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
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

class _CalendarTab extends ConsumerWidget {
  const _CalendarTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarControllerProvider);
    return eventsAsync.when(
      data: (events) => _EventsList(events: events),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

class _EventsList extends ConsumerWidget {
  const _EventsList({required this.events});

  final List<CalendarEventItem> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const Center(child: Text('No events yet. Tap + to add one.'));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          leading: Icon(event.isHoliday ? Icons.beach_access : Icons.event),
          title: Text(event.title),
          subtitle: Text(
            '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-'
            '${event.date.day.toString().padLeft(2, '0')}'
            '${event.description.isNotEmpty ? ' · ${event.description}' : ''}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () =>
                ref.read(calendarControllerProvider.notifier).deleteEvent(event.id),
          ),
        );
      },
    );
  }
}

class _AddEventDialog extends ConsumerStatefulWidget {
  const _AddEventDialog();

  @override
  ConsumerState<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends ConsumerState<_AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isHoliday = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
            ),
            ListTile(
              title: const Text('Date'),
              trailing: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-'
                '${_date.day.toString().padLeft(2, '0')}',
              ),
              onTap: _pickDate,
            ),
            SwitchListTile(
              title: const Text('Holiday'),
              value: _isHoliday,
              onChanged: (value) => setState(() => _isHoliday = value),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    ref.read(calendarControllerProvider.notifier).addEvent(
          title: title,
          date: _date,
          description: _descriptionController.text.trim(),
          isHoliday: _isHoliday,
        );
    Navigator.of(context).pop();
  }
}