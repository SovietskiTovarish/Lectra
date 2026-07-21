import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lectra/core/constants/update_constants.dart';
import 'package:lectra/core/services/update_models.dart';

/// Checks GitHub Releases for a newer signed APK than the one
/// currently installed.
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns update info if a newer release is available, or `null`
  /// if the installed version is current or the check fails.
  Future<UpdateInfo?> checkForUpdate() async {
    final response = await _client.get(
      Uri.parse(
        'https://api.github.com/repos/${UpdateConstants.githubOwner}/'
        '${UpdateConstants.githubRepo}/releases/latest',
      ),
      headers: const {'Accept': 'application/vnd.github+json'},
    );
    if (response.statusCode != 200) return null;

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = (json['tag_name'] as String?)?.replaceFirst('v', '');
    if (tagName == null) return null;

    final assets = (json['assets'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final apkAsset = assets.firstWhere(
      (asset) => (asset['name'] as String? ?? '').endsWith('.apk'),
      orElse: () => const {},
    );
    final downloadUrl = apkAsset['browser_download_url'] as String?;
    if (downloadUrl == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final severity = _compare(packageInfo.version, tagName);
    if (severity == null) return null;

    return UpdateInfo(
      version: tagName,
      downloadUrl: downloadUrl,
      releaseNotes: (json['body'] as String? ?? '').trim(),
      severity: severity,
    );
  }

  /// Returns the severity of the difference if [remote] is newer
  /// than [current], or `null` if [current] is already up to date.
  UpdateSeverity? _compare(String current, String remote) {
    final c = _parse(current);
    final r = _parse(remote);
    if (r[0] > c[0]) return UpdateSeverity.major;
    if (r[0] == c[0] && r[1] > c[1]) return UpdateSeverity.minor;
    if (r[0] == c[0] && r[1] == c[1] && r[2] > c[2]) {
      return UpdateSeverity.patch;
    }
    return null;
  }

  List<int> _parse(String version) {
    final parts = version.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts;
  }

  void dispose() => _client.close();
}