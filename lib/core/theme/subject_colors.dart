/// Preset accent-colour palette assigned automatically to subjects
/// that don't have a user-chosen colour.
abstract final class SubjectColors {
  static const List<int> palette = [
    0xFF3D5AFE,
    0xFFEF5350,
    0xFF66BB6A,
    0xFFFFA726,
    0xFFAB47BC,
    0xFF26C6DA,
    0xFFEC407A,
    0xFF8D6E63,
  ];

  /// Deterministically picks a palette colour based on how many
  /// subjects already exist, so colours cycle predictably.
  static int assign(int existingSubjectCount) {
    return palette[existingSubjectCount % palette.length];
  }
}