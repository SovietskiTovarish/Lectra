abstract final class RoutePaths {
  static const String dashboard = '/dashboard';
  static const String subjects = '/subjects';
  static const String settings = '/settings';
  static const String addSubjectSegment = 'add';
  static const String subjectDetailSegment = ':id';
  static const String editSubjectSegment = 'edit';
}

/// Route name constants, used with `context.goNamed`/`pushNamed`.
abstract final class RouteNames {
  static const String dashboard = 'dashboard';
  static const String subjects = 'subjects';
  static const String addSubject = 'addSubject';
  static const String subjectDetail = 'subjectDetail';
  static const String editSubject = 'editSubject';
  static const String settings = 'settings';
}
