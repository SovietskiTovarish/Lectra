import 'package:flutter/material.dart';

/// Reusable form containing the basic information for a subject.
///
/// Used by both:
/// - Add Subject
/// - Edit Subject
class SubjectInformationForm extends StatelessWidget {
  const SubjectInformationForm({
    super.key,
    required this.nameController,
    required this.codeController,
    required this.nicknameController,
    required this.facultyController,
  });

  final TextEditingController nameController;
  final TextEditingController codeController;
  final TextEditingController nicknameController;
  final TextEditingController facultyController;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Subject Name *',
                hintText: 'Operating Systems',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Subject name is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Subject Code',
                hintText: 'CS301',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: nicknameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                hintText: 'OS',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.short_text),
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: facultyController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Faculty',
                hintText: 'Dr. Sharma',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}