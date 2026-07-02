import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/timetable/model.dart';
import 'package:lectra/features/timetable/repository.dart';

/// Exposes the [TimetableRepository] for the timetable feature.
final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepository(ref.watch(appDatabaseProvider));
});

/// Holds the current list of timetable entries and exposes mutation
/// methods.
class TimetableController extends AsyncNotifier<List<TimetableEntryItem>> {
  @override
  Future<List<TimetableEntryItem>> build() {
    return ref.watch(timetableRepositoryProvider).fetchAll();
  }

  /// Adds a new timetable entry and refreshes the list.
  Future<void> addEntry({
    required int subjectId,
    required int dayOfWeek,
    required int startMinutes,
    required int endMinutes,
    String room = '',
  }) async {
    final repository = ref.read(timetableRepositoryProvider);
    await repository.addEntry(
      subjectId: subjectId,
      dayOfWeek: dayOfWeek,
      startMinutes: startMinutes,
      endMinutes: endMinutes,
      room: room,
    );
    state = await AsyncValue.guard(repository.fetchAll);
  }

  /// Removes a timetable entry and refreshes the list.
  Future<void> deleteEntry(int id) async {
    final repository = ref.read(timetableRepositoryProvider);
    await repository.deleteEntry(id);
    state = await AsyncValue.guard(repository.fetchAll);
  }
}

/// Provider for [TimetableController].
final timetableControllerProvider =
    AsyncNotifierProvider<TimetableController, List<TimetableEntryItem>>(
  TimetableController.new,
);