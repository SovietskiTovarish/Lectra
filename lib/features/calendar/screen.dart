import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/features/calendar/controller.dart';
import 'package:lectra/features/calendar/model.dart';

/// Calendar view for holidays, exams, and academic events.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(calendarControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: eventsAsync.when(
        data: (events) => _EventsList(events: events),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _AddEventDialog(),
        ),
        child: const Icon(Icons.add),
      ),
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