import 'package:flutter/material.dart';

/// Displays the weekly class timetable.
///
/// Milestone 0 renders the static screen shell only; timetable
/// entries are added once the database layer exists.
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable')),
      body: const Center(
        child: Text('Your weekly schedule will appear here'),
      ),
    );
  }
}