import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/app.dart';

/// Prepares the Flutter engine and launches [LectraApp].
///
/// This is the single place where app-wide initialization happens.
/// Milestone 0 only needs binding initialization; later milestones
/// (database, notifications, ads) will extend this function without
/// touching [main.dart].
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LectraApp(),
    ),
  );
}