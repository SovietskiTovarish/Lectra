import 'package:flutter/material.dart';
import 'package:lectra/features/subjects/model.dart';

/// Subject information: full name, code, and faculty.
class SubjectInfoCard extends StatelessWidget {
  const SubjectInfoCard({required this.subject, super.key});

  final SubjectItem subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: subject.accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject.name, style: theme.textTheme.titleMedium),
                  if (subject.hasCode)
                    Text(
                      'Code: ${subject.code}',
                      style: theme.textTheme.bodySmall,
                    ),
                  if (subject.hasFaculty)
                    Text(
                      'Faculty: ${subject.facultyName}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}