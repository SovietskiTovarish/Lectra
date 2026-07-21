import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lectra/features/ads/ad_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads and shows interstitial ads with a simple frequency cap so
/// they appear only occasionally, never on every app open.
///
/// Call [InterstitialAdManager.instance.maybeShowOnAppOpen] once,
/// after the app's first frame, from a place like [LectraApp]'s
/// initState. The manager tracks how many app opens have happened
/// since the ad last showed, using SharedPreferences so the count
/// survives app restarts.
class InterstitialAdManager {
  InterstitialAdManager._();
  static final InterstitialAdManager instance = InterstitialAdManager._();

  static const _prefsKey = 'interstitial_opens_since_last_show';

  InterstitialAd? _ad;
  bool _isLoading = false;

  /// Preloads an interstitial so it's ready to show instantly when
  /// [maybeShowOnAppOpen] decides it's time.
  void preload() {
    if (_ad != null || _isLoading) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Increments the open counter and shows the preloaded
  /// interstitial only once every [AdConfig.interstitialFrequencyCap]
  /// app opens. Dismissible by the user via the ad's built-in close
  /// button; no reward or forced wait is involved.
  Future<void> maybeShowOnAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final opens = (prefs.getInt(_prefsKey) ?? 0) + 1;

    if (opens < AdConfig.interstitialFrequencyCap) {
      await prefs.setInt(_prefsKey, opens);
      preload(); // keep one warm for next time
      return;
    }

    final ad = _ad;
    if (ad == null) {
      // Not ready yet this time; reset counter so we try again soon
      // rather than waiting a full cycle.
      await prefs.setInt(_prefsKey, AdConfig.interstitialFrequencyCap - 1);
      preload();
      return;
    }

    await prefs.setInt(_prefsKey, 0);
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        preload();
      },
    );
    ad.show();
  }
}
