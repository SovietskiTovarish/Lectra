import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lectra/core/constants/update_constants.dart';
import 'package:lectra/core/services/update_installer.dart';
import 'package:lectra/core/services/update_models.dart';
import 'package:lectra/core/services/update_service.dart';

/// Exposes [UpdateService] for the update feature.
final updateServiceProvider = Provider<UpdateService>((ref) {
  final service = UpdateService();
  ref.onDispose(service.dispose);
  return service;
});

/// Exposes [UpdateInstaller] for the update feature.
final updateInstallerProvider = Provider<UpdateInstaller>((ref) {
  final installer = UpdateInstaller();
  ref.onDispose(installer.dispose);
  return installer;
});

/// Runs the once-per-day update check and holds the result, if any,
/// so the UI can prompt the user.
class UpdateController extends AsyncNotifier<UpdateInfo?> {
  @override
  Future<UpdateInfo?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckMillis = prefs.getInt(UpdateConstants.lastCheckPrefKey);
    final now = DateTime.now();

    if (lastCheckMillis != null) {
      final elapsed = now.difference(
        DateTime.fromMillisecondsSinceEpoch(lastCheckMillis),
      );
      if (elapsed < UpdateConstants.checkInterval) return null;
    }

    final result = await ref.read(updateServiceProvider).checkForUpdate();
    await prefs.setInt(UpdateConstants.lastCheckPrefKey, now.millisecondsSinceEpoch);
    return result;
  }

  /// Downloads and launches the installer for the given update.
  ///
  /// [onProgress] is forwarded to [UpdateInstaller.downloadAndInstall]
  /// and called with a value in `[0.0, 1.0]` as the download proceeds.
  Future<InstallResult> installUpdate(
    UpdateInfo info, {
    void Function(double progress)? onProgress,
  }) {
    return ref.read(updateInstallerProvider).downloadAndInstall(
          info.downloadUrl,
          onProgress: onProgress,
        );
  }

  /// Dismisses the current update prompt without installing.
  void dismiss() {
    state = const AsyncData(null);
  }
}

/// Provider for [UpdateController].
final updateControllerProvider =
    AsyncNotifierProvider<UpdateController, UpdateInfo?>(UpdateController.new);