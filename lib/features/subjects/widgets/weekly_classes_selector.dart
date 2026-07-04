import 'package:flutter/material.dart';

class WeeklyClassesSelector extends StatelessWidget {
  const WeeklyClassesSelector({
    super.key,
    required this.current,
    required this.onChanged,
    this.maxClasses = 6,
    this.minClasses = 1,
  });

  final int current;
  final int maxClasses;
  final int minClasses;

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Weekly Classes',
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              '$current class${current == 1 ? '' : 'es'} / week',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: current <= minClasses
                        ? null
                        : () => onChanged(current - 1),
                    icon: const Icon(Icons.remove),
                    label: const Text('Less'),
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    current.toString(),
                    style: theme.textTheme.headlineMedium,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: FilledButton.icon(
                    onPressed: current >= maxClasses
                        ? null
                        : () => onChanged(current + 1),
                    icon: const Icon(Icons.add),
                    label: const Text('More'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}