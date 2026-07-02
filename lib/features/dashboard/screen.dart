import 'package:flutter/material.dart';

/// Landing screen showing a summary of the student's day.
///
/// Milestone 0 renders the static screen shell only; live data
/// (today's classes, attendance summary) is wired up once the
/// database layer exists.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text('Your day at a glance'),
      ),
    );
  }
}