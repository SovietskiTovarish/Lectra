import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/features/dashboard/screen.dart';
import 'package:lectra/features/settings/screen.dart';
import 'package:lectra/features/subjects/screen.dart';
import 'package:lectra/features/subjects/screens/add_edit_subject_screen.dart';
import 'package:lectra/features/subjects/subject_detail_screen.dart';
import 'package:lectra/shared/widgets/main_scaffold.dart';

/// Application-wide navigation configuration.
///
/// A single [StatefulShellRoute.indexedStack] hosts the bottom
/// navigation destinations, each with its own independent navigator
/// so per-tab state survives tab switches. Add/Edit Subject is a
/// real nested route (not a dialog) so it shares that same stack.
///
/// The Dashboard is the app's primary home screen and central
/// navigation hub: it hosts both Today's Schedule and the Weekly
/// Timetable (as an in-place toggle), so there is no separate
/// top-level Timetable destination anymore.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.subjects,
                name: RouteNames.subjects,
                builder: (context, state) => const SubjectsScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.addSubjectSegment,
                    name: RouteNames.addSubject,
                    builder: (context, state) => const AddEditSubjectScreen(),
                  ),
                  GoRoute(
                    path: RoutePaths.subjectDetailSegment,
                    name: RouteNames.subjectDetail,
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return SubjectDetailScreen(subjectId: id);
                    },
                    routes: [
                      GoRoute(
                        path: RoutePaths.editSubjectSegment,
                        name: RouteNames.editSubject,
                        builder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return AddEditSubjectScreen(subjectId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.settings,
                name: RouteNames.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
