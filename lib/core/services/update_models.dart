import 'package:flutter/foundation.dart';

/// Describes how significant an available update is, based on
/// semantic-version comparison against the currently installed
/// version.
enum UpdateSeverity { patch, minor, major }

/// Immutable description of an available update fetched from
/// GitHub Releases.
@immutable
class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.severity,
  });

  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final UpdateSeverity severity;

  bool get isMajor => severity == UpdateSeverity.major;
}