import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Immutable domain model for a subject, decoupled from the Drift
/// row type so the UI layer never depends on generated code.
@immutable
class SubjectItem {
  const SubjectItem({
    required this.id,
    required this.name,
    required this.code,
    this.color,
  });

  final int id;
  final String name;
  final String code;
  final Color? color;
}