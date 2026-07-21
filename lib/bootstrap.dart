import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lectra/app.dart';
import 'package:lectra/features/ads/interstitial_ad_manager.dart';
import 'package:lectra/features/notifications/notification_service.dart';

/// Prepares the Flutter engine and launches [LectraApp].
///
/// This is the single place where app-wide initialization happens.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requests notification permissions and sets up the Android
  // notification channel before the app's first frame, so the
  // notificationSchedulerProvider (activated from LectraApp) can
  // schedule class reminders as soon as subjects/timetable data
  // loads.
  await NotificationService.instance.initialize();

  // Initializes the Google Mobile Ads SDK. Must complete before any
  // BannerAd/InterstitialAd is loaded elsewhere in the app.
  await MobileAds.instance.initialize();
  InterstitialAdManager.instance.preload();

  runApp(
    const ProviderScope(
      child: LectraApp(),
    ),
  );

  // Runs after the first frame so it never delays app startup or
  // competes with the initial UI paint. Frequency-capped internally
  // (see InterstitialAdManager) so this does not show on every open.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    InterstitialAdManager.instance.maybeShowOnAppOpen();
  });
}