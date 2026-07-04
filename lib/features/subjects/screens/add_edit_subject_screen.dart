import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/utils/subject_lookup.dart';
import 'package:lectra/features/subjects/controller.dart';
import 'package:lectra/features/subjects/models/lecture_slot_form.dart';
import 'package:lectra/features/subjects/widgets/class_slot_row.dart';
import 'package:lectra/features/subjects/widgets/subject_color_picker.dart';
import 'package:lectra/features/subjects/widgets/subject_information_form.dart';
import 'package:lectra/features/subjects/widgets/weekly_classes_selector.dart';
import 'package:lectra/features/timetable/controller.dart';

/// Single screen used to both create a new subject and edit an
/// existing one, including its full weekly schedule (1-12 classes).
class AddEditSubjectScreen extends ConsumerStatefulWidget {
  const AddEditSubjectScreen({super.key, this.subjectId});

  /// Null when adding a new subject, non-null when editing.
  final int? subjectId;

  bool get isEditing => subjectId != null;

  @override
  ConsumerState<AddEditSubjectScreen> createState() =>
      _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends ConsumerState<AddEditSubjectScreen> {
  static const int _maxClasses = 12;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _facultyController = TextEditingController();

  int? _colorValue;
  List<LectureSlotForm> _slots = [LectureSlotForm()];
  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _initializeForEdit(widget.subjectId!);
    } else {
      _initialized = true;
    }
  }

  Future<void> _initializeForEdit(int subjectId) async {
    final subjects = ref.read(subjectsControllerProvider).valueOrNull ?? [];
    final subject = findSubjectById(subjects, subjectId);

    if (subject != null) {
      _nameController.text = subject.name;
      _codeController.text = subject.code ?? '';
      _nicknameController.text = subject.nickname ?? '';
      _facultyController.text = subject.facultyName ?? '';
      _colorValue = subject.accentColor.toARGB32();
    }

    final existing = await ref
        .read(timetableControllerProvider.notifier)
        .fetchSubjectSchedule(subjectId);

    if (!mounted) return;

    setState(() {
      _slots = existing.isEmpty
          ? [LectureSlotForm()]
          : existing
              .map(
                (e) => LectureSlotForm(
                  weekdays: {e.dayOfWeek},
                  startTime: TimeOfDay(
                    hour: e.startMinutes ~/ 60,
                    minute: e.startMinutes % 60,
                  ),
                  endTime: TimeOfDay(
                    hour: e.endMinutes ~/ 60,
                    minute: e.endMinutes % 60,
                  ),
                  room: e.room,
                ),
              )
              .toList();
      _initialized = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  void _setClassCount(int count) {
    setState(() {
      if (count > _slots.length) {
        final last = _slots.isNotEmpty ? _slots.last : LectureSlotForm();
        while (_slots.length < count) {
          final currentDay = last.weekdays.isEmpty ? 0 : last.weekdays.first;
          final nextDay = currentDay % 7 + 1;
          _slots.add(
            LectureSlotForm(
              weekdays: {nextDay},
              startTime: last.startTime,
              endTime: last.endTime,
            ),
          );
        }
      } else {
        _slots = _slots.sublist(0, count);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    for (final slot in _slots) {
      if (!slot.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Each class needs a valid time range'),
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final nickname = _nicknameController.text.trim();
    final faculty = _facultyController.text.trim();

    final subjectsNotifier = ref.read(subjectsControllerProvider.notifier);
    final timetableNotifier = ref.read(timetableControllerProvider.notifier);

    try {
      final int subjectId;

      if (widget.isEditing) {
        subjectId = widget.subjectId!;
        await subjectsNotifier.updateSubject(
          id: subjectId,
          name: name,
          code: code.isEmpty ? null : code,
          nickname: nickname.isEmpty ? null : nickname,
          facultyName: faculty.isEmpty ? null : faculty,
          accentColor: _colorValue,
        );
      } else {
        subjectId = await subjectsNotifier.addSubject(
          name: name,
          code: code.isEmpty ? null : code,
          nickname: nickname.isEmpty ? null : nickname,
          facultyName: faculty.isEmpty ? null : faculty,
          accentColor: _colorValue,
        );
      }

      await timetableNotifier.replaceLectureSlots(
        subjectId: subjectId,
        slots: _slots,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save subject: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Subject' : 'Add Subject'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Subject' : 'Add Subject'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SubjectInformationForm(
              nameController: _nameController,
              codeController: _codeController,
              nicknameController: _nicknameController,
              facultyController: _facultyController,
            ),
            const SizedBox(height: 16),
            SubjectColorPicker(
              selectedColor: _colorValue,
              onChanged: (value) => setState(() => _colorValue = value),
            ),
            const SizedBox(height: 16),
            WeeklyClassesSelector(
              current: _slots.length,
              maxClasses: _maxClasses,
              onChanged: _setClassCount,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _slots.length; i++) ...[
              ClassSlotRow(
                index: i,
                slot: _slots[i],
                onChanged: (updated) => setState(() => _slots[i] = updated),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}