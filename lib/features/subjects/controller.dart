import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/database_provider.dart';
import 'package:lectra/features/subjects/model.dart';
import 'package:lectra/features/subjects/repository.dart';

/// Exposes the [SubjectsRepository] for the subjects feature.
final subjectsRepositoryProvider = Provider<SubjectsRepository>((ref) {
  return SubjectsRepository(ref.watch(appDatabaseProvider));
});

/// Holds the current list of subjects and exposes mutation methods.
class SubjectsController extends AsyncNotifier<List<SubjectItem>> {
  @override
  Future<List<SubjectItem>> build() {
    return ref.watch(subjectsRepositoryProvider).fetchAll();
  }

  /// Adds a new subject and refreshes the list.
  Future<void> addSubject({
    required String name,
    String code = '',
    int? colorValue,
  }) async {
    final repository = ref.read(subjectsRepositoryProvider);
    await repository.addSubject(name: name, code: code, colorValue: colorValue);
    state = await AsyncValue.guard(repository.fetchAll);
  }

  /// Removes a subject and refreshes the list.
  Future<void> deleteSubject(int id) async {
    final repository = ref.read(subjectsRepositoryProvider);
    await repository.deleteSubject(id);
    state = await AsyncValue.guard(repository.fetchAll);
  }
}

/// Provider for [SubjectsController].
final subjectsControllerProvider =
    AsyncNotifierProvider<SubjectsController, List<SubjectItem>>(
  SubjectsController.new,
);