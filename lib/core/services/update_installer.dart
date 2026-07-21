import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Result of an [UpdateInstaller.downloadAndInstall] attempt.
enum InstallResult {
  /// The installer intent was launched successfully.
  launched,

  /// The download failed (network error, bad status code, or the
  /// connection was interrupted mid-stream).
  downloadFailed,

  /// The download completed but the system could not open/install
  /// the file (e.g. "install unknown apps" not granted, or no
  /// suitable app to handle the intent).
  installFailed,
}

/// Downloads an update APK and hands it to the Android package
/// installer via [OpenFilex], which resolves to an
/// `ACTION_VIEW`/`ACTION_INSTALL_PACKAGE` intent for `.apk` MIME
/// types. This is the standard sideload-install mechanism used by
/// F-Droid and similar non-Play-Store apps.
///
/// Requires a `FileProvider` declared in the Android manifest (see
/// `android/app/src/main/res/xml/file_paths.xml`) so the file can be
/// exposed to the installer via a `content://` URI on Android 7+.
class UpdateInstaller {
  UpdateInstaller({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _fileName = 'lectra-update.apk';

  /// Downloads the APK at [downloadUrl] and launches the system
  /// installer.
  ///
  /// [onProgress] is called with a value in `[0.0, 1.0]` as bytes
  /// arrive. If the server doesn't report `Content-Length`, progress
  /// stays at `0.0` until the download completes.
  ///
  /// The user must still tap "Install" in the system dialog — Android
  /// does not permit a normal app to install packages without that
  /// confirmation unless it holds device-owner privileges.
  Future<InstallResult> downloadAndInstall(
    String downloadUrl, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _fileName));

    // Remove any stale/partial download left over from a previous
    // attempt so we never install or serve an outdated file.
    if (await file.exists()) {
      await file.delete();
    }

    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        return InstallResult.downloadFailed;
      }

      final total = response.contentLength;
      var received = 0;
      final sink = file.openWrite();

      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total != null && total > 0) {
            onProgress?.call(received / total);
          }
        }
      } finally {
        await sink.close();
      }

      // Sanity check: if the server told us how big the file should
      // be, make sure we actually got that many bytes before handing
      // a possibly-truncated APK to the installer.
      if (total != null && received != total) {
        await _safeDelete(file);
        return InstallResult.downloadFailed;
      }
    } on Exception {
      await _safeDelete(file);
      return InstallResult.downloadFailed;
    }

    final result = await OpenFilex.open(file.path);
    return result.type == ResultType.done
        ? InstallResult.launched
        : InstallResult.installFailed;
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } on Exception {
      // Best-effort cleanup; ignore failures here.
    }
  }

  void dispose() => _client.close();
}