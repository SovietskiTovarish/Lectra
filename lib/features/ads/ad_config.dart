import 'package:flutter/foundation.dart';

/// Centralized AdMob ad unit IDs.
///
/// Uses Google's official test ad unit IDs automatically in debug
/// mode so development/testing never risks policy violations from
/// serving real ads on a dev device. Replace the release IDs below
/// with the real ad unit IDs from your AdMob console before
/// shipping a release build.
abstract final class AdConfig {
  /// Your AdMob Application ID (from the AdMob console).
  /// This one also needs to be placed in
  /// android/app/src/main/AndroidManifest.xml as the
  /// com.google.android.gms.ads.APPLICATION_ID meta-data value.
  static const String applicationId =
      'xyz';

  static const String _releaseBannerId =
      'xyz';
  static const String _releaseInterstitialId =
      'xyz';

  // Google's official test ad unit IDs (Android).
  // Safe to use as-is during development.
  static const String _testBannerId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId =>
      kReleaseMode ? _releaseBannerId : _testBannerId;

  static String get interstitialAdUnitId =>
      kReleaseMode ? _releaseInterstitialId : _testInterstitialId;

  /// Minimum number of app opens between interstitial ad shows.
  /// Keeps ads occasional rather than frequent.
  static const int interstitialFrequencyCap = 4;
}
