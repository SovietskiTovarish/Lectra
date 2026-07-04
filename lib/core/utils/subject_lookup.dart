import 'package:lectra/features/subjects/model.dart';

/// Finds the subject with the given [id] in [subjects], or `null`
/// if no such subject exists. Centralized to avoid repeating this
/// lookup across dashboard and subject-detail screens.
SubjectItem? findSubjectById(List<SubjectItem> subjects, int id) {
  for (final subject in subjects) {
    if (subject.id == id) return subject;
  }
  return null;
}