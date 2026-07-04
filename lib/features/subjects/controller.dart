import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/attendance/controller.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/subjects/repository.dart';
import 'package:lectra/features/timetable/controller.dart';

/// Repository provider.
final subjectsRepositoryProvider = Provider<SubjectsRepository>((ref) {
  return SubjectsRepository(ref.watch(appDatabaseProvider));
});

/// Controls the list of subjects and all CRUD operations.
class SubjectsController extends AsyncNotifier<List<SubjectItem>> {
  SubjectsRepository get _repository =>
      ref.read(subjectsRepositoryProvider);

  @override
  Future<List<SubjectItem>> build() {
    return _repository.fetchAll();
  }

  /// Reloads all subjects.
  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      _repository.fetchAll,
    );
  }

  /// Creates a new subject.
  Future<int> addSubject({
    required String name,
    String? code,
    String? nickname,
    String? facultyName,
    int? accentColor,
  }) async {
    final id = await _repository.addSubject(
      name: name,
      code: code,
      nickname: nickname,
      facultyName: facultyName,
      accentColor: accentColor,
    );

    await refresh();

    return id;
  }

  /// Deletes a subject.
  ///
  /// The database cascades this delete to that subject's weekly
  /// lecture slots and attendance records (see the `onDelete:
  /// KeyAction.cascade` foreign keys in `AppDatabase`), so the rows
  /// themselves are gone immediately. But [timetableControllerProvider]
  /// and the per-subject attendance providers cache their own
  /// in-memory state and don't know that happened — without
  /// explicitly refreshing/invalidating them here, the Dashboard and
  /// Weekly Timetable kept showing the deleted subject's classes
  /// until something else happened to trigger a refetch.
  Future<void> deleteSubject(int id) async {
    await _repository.deleteSubject(id);

    await refresh();

    // The subject's own weekly schedule no longer exists, so drop it
    // from the shared timetable state immediately.
    await ref.read(timetableControllerProvider.notifier).refresh();

    // Also drop any cached attendance stats/history for this subject,
    // in case a still-open screen (e.g. its detail page mid-close) is
    // watching them.
    ref.invalidate(subjectAttendanceStatsProvider(id));
    ref.invalidate(subjectAttendanceRecordsProvider(id));
  }

  /// Updates an existing subject.
  ///
  /// (Implementation will be added when the repository supports it.)
  Future<void> updateSubject({
    required int id,
    required String name,
    String? code,
    String? nickname,
    String? facultyName,
    int? accentColor,
  }) async {
    await _repository.updateSubject(
      id: id,
      name: name,
      code: code,
      nickname: nickname,
      facultyName: facultyName,
      accentColor: accentColor,
    );

    await refresh();
  }
}

final subjectsControllerProvider =
    AsyncNotifierProvider<SubjectsController, List<SubjectItem>>(
  SubjectsController.new,
);