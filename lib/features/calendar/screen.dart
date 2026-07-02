import 'package:flutter/material.dart';

/// Calendar view for holidays, exams, and academic events.
///
/// Milestone 0 renders the static screen shell only; event data is
/// added once the database layer exists.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: const Center(
        child: Text('Academic events will appear here'),
      ),
    );
  }
}