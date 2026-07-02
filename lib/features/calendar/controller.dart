import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/calendar/model.dart';
import 'package:lectra/features/calendar/repository.dart';

/// Exposes the [CalendarRepository] for the calendar feature.
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.watch(appDatabaseProvider));
});

/// Holds the current list of calendar events and exposes mutation
/// methods.
class CalendarController extends AsyncNotifier<List<CalendarEventItem>> {
  @override
  Future<List<CalendarEventItem>> build() {
    return ref.watch(calendarRepositoryProvider).fetchAll();
  }

  /// Adds a new calendar event and refreshes the list.
  Future<void> addEvent({
    required String title,
    required DateTime date,
    String description = '',
    bool isHoliday = false,
  }) async {
    final repository = ref.read(calendarRepositoryProvider);
    await repository.addEvent(
      title: title,
      date: date,
      description: description,
      isHoliday: isHoliday,
    );
    state = await AsyncValue.guard(repository.fetchAll);
  }

  /// Removes a calendar event and refreshes the list.
  Future<void> deleteEvent(int id) async {
    final repository = ref.read(calendarRepositoryProvider);
    await repository.deleteEvent(id);
    state = await AsyncValue.guard(repository.fetchAll);
  }
}

/// Provider for [CalendarController].
final calendarControllerProvider =
    AsyncNotifierProvider<CalendarController, List<CalendarEventItem>>(
  CalendarController.new,
);