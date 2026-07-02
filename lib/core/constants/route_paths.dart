/// Route path and name constants used by [AppRouter].
///
/// Keeping these in one place prevents typo-driven navigation bugs
/// and magic strings inside the routing configuration.
abstract final class RoutePaths {
  static const String dashboard = '/dashboard';
  static const String subjects = '/subjects';
  static const String settings = '/settings';
}

/// Route name constants, used with `context.goNamed`.
abstract final class RouteNames {
  static const String dashboard = 'dashboard';
  static const String subjects = 'subjects';
  static const String settings = 'settings';
}