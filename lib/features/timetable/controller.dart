import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/subjects/models/lecture_slot_form.dart';
import 'package:lectra/features/timetable/model.dart';
import 'package:lectra/features/timetable/repository.dart';

/// Repository provider.
final timetableRepositoryProvider =
    Provider<TimetableRepository>((ref) {
  return TimetableRepository(
    ref.watch(appDatabaseProvider),
  );
});

/// Controls all recurring lecture slots.
///
/// This controller intentionally works with entire schedules instead
/// of individual entries. A subject owns its complete weekly schedule.
class TimetableController
    extends AsyncNotifier<List<TimetableEntryItem>> {
  TimetableRepository get _repository =>
      ref.read(timetableRepositoryProvider);

  @override
  Future<List<TimetableEntryItem>> build() {
    return _repository.fetchAll();
  }

  /// Reloads every lecture slot.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.fetchAll,
    );
  }

  /// Replaces the entire weekly schedule for one subject.
  Future<void> replaceLectureSlots({
    required int subjectId,
    required List<LectureSlotForm> slots,
  }) async {
    await _repository.replaceLectureSlots(
      subjectId: subjectId,
      slots: slots,
    );

    await refresh();
  }

  /// Returns all lecture slots belonging to one subject.
  Future<List<TimetableEntryItem>> fetchSubjectSchedule(
    int subjectId,
  ) {
    return _repository.fetchForSubject(subjectId);
  }

  /// Deletes a single lecture slot.
  Future<void> deleteLectureSlot(
    int slotId,
  ) async {
    await _repository.deleteLectureSlot(
      slotId,
    );

    await refresh();
  }
}

/// Provider.
final timetableControllerProvider =
    AsyncNotifierProvider<
        TimetableController,
        List<TimetableEntryItem>>(
  TimetableController.new,
);