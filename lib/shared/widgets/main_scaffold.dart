import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent bottom-navigation scaffold shared by the top level
/// destinations.
///
/// Used as the builder for a [StatefulShellRoute.indexedStack], so
/// each branch keeps its own navigation stack and state alive when
/// switching tabs.
///
/// The Dashboard is the app's primary home and central navigation
/// hub — it hosts Today's Schedule and the Weekly Timetable together,
/// so there is no separate Timetable destination.
class MainScaffold extends StatelessWidget {
  const MainScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Subjects',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: _destinations,
      ),
    );
  }
}
