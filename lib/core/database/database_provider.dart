import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/database/app_database.dart';

/// Provides the single shared [AppDatabase] instance for the app.
///
/// Opened lazily on first read and kept alive for the app's
/// lifetime; disposed automatically when the [ProviderScope] is
/// torn down. Override this in tests to inject an in-memory database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});