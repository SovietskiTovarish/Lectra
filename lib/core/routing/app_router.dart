import 'package:go_router/go_router.dart';
import 'package:lectra/core/constants/route_paths.dart';
import 'package:lectra/features/dashboard/screen.dart';
import 'package:lectra/features/settings/screen.dart';
import 'package:lectra/features/subjects/screen.dart';
import 'package:lectra/shared/widgets/main_scaffold.dart';

/// Application-wide navigation configuration.
///
/// A single [StatefulShellRoute.indexedStack] hosts the three bottom
/// navigation destinations, each with its own independent navigator
/// so per-tab state survives tab switches.
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