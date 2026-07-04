import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/app.dart';
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

  runApp(
    const ProviderScope(
      child: LectraApp(),
    ),
  );
}