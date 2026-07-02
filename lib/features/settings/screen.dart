import 'package:flutter/material.dart';

/// Application settings and preferences.
///
/// Milestone 0 renders the static screen shell only; preference
/// controls are added once shared_preferences integration exists.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('App preferences will appear here'),
      ),
    );
  }
}