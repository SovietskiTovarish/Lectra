import 'package:flutter/material.dart';

/// Lists the student's enrolled subjects.
///
/// Milestone 0 renders the static screen shell only; subject data
/// is added once the Drift-backed repository layer exists.
class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: const Center(
        child: Text('Your subjects will appear here'),
      ),
    );
  }
}