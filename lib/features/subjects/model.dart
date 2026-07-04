import 'package:flutter/material.dart';

/// Immutable domain model representing a subject.
///
/// This model is intentionally decoupled from Drift-generated classes so the
/// presentation layer never depends directly on the database schema.
class SubjectItem {
  const SubjectItem({
    required this.id,
    required this.name,
    required this.accentColor,
    this.code,
    this.nickname,
    this.facultyName,
  });

  /// Database primary key.
  final int id;

  /// Official subject name.
  final String name;

  /// Optional course code.
  final String? code;

  /// Optional short name shown in compact UI.
  final String? nickname;

  /// Optional faculty/professor name.
  final String? facultyName;

  /// Accent colour used consistently throughout the app.
  final Color accentColor;

  /// Returns the nickname if available, otherwise the full subject name.
  String get displayName {
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return nickname!.trim();
    }
    return name;
  }

  /// Returns the course code if one exists.
  bool get hasCode =>
      code != null && code!.trim().isNotEmpty;

  /// Returns whether a faculty name has been provided.
  bool get hasFaculty =>
      facultyName != null && facultyName!.trim().isNotEmpty;

  /// Creates a modified copy.
  SubjectItem copyWith({
    int? id,
    String? name,
    String? code,
    String? nickname,
    String? facultyName,
    Color? accentColor,
  }) {
    return SubjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      nickname: nickname ?? this.nickname,
      facultyName: facultyName ?? this.facultyName,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  String toString() {
    return 'SubjectItem('
        'id: $id, '
        'name: $name, '
        'code: $code, '
        'nickname: $nickname, '
        'facultyName: $facultyName'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SubjectItem &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            code == other.code &&
            nickname == other.nickname &&
            facultyName == other.facultyName &&
            accentColor == other.accentColor;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        code,
        nickname,
        facultyName,
        accentColor,
      );
}