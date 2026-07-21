/// Configuration for the OTA update checker.
///
/// Points at the GitHub Releases feed set up by the release
/// workflow (`.github/workflows/release.yml`), which attaches a
/// signed APK to every tagged release.
abstract final class UpdateConstants {
  static const String githubOwner = 'sovietskitovarish';
  static const String githubRepo = 'lectra';
  static const String lastCheckPrefKey = 'update_last_check_millis';
  static const Duration checkInterval = Duration(days: 1);
}