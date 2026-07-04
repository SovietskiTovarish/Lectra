import 'package:flutter/material.dart';
import 'package:lectra/features/subjects/models/lecture_slot_form.dart';
import 'package:lectra/features/timetable/model.dart';

/// Editor for a single weekly class occurrence: one day, a start/end
/// time, and a room. One row per class per week, matching the count
/// set by the "Weekly Classes" stepper above it.
class ClassSlotRow extends StatelessWidget {
  const ClassSlotRow({
    super.key,
    required this.index,
    required this.slot,
    required this.onChanged,
  });

  final int index;
  final LectureSlotForm slot;
  final ValueChanged<LectureSlotForm> onChanged;

  int get _day => slot.weekdays.isEmpty ? 1 : slot.weekdays.first;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _day,
              decoration: const InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                TimetableEntryItem.weekdayNames.length,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(TimetableEntryItem.weekdayNames[i]),
                ),
              ),
              onChanged: (value) {
                if (value == null) return;
                onChanged(slot.copyWith(weekdays: {value}));
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Start',
                    value: slot.startTime,
                    onChanged: (time) =>
                        onChanged(slot.copyWith(startTime: time)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TimeField(
                    label: 'End',
                    value: slot.endTime,
                    onChanged: (time) =>
                        onChanged(slot.copyWith(endTime: time)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: slot.room,
              decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'e.g. LH-204',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => onChanged(slot.copyWith(room: value)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked =
            await showTimePicker(context: context, initialTime: value);
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value.format(context)),
      ),
    );
  }
}