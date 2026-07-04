import 'package:flutter/material.dart';
import 'package:lectra/core/theme/subject_colors.dart';

/// Material 3 color picker used for subjects.
///
/// If no colour is selected, the repository automatically assigns one.
class SubjectColorPicker extends StatelessWidget {
  const SubjectColorPicker({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  /// Selected ARGB integer.
  ///
  /// Null means "Auto".
  final int? selectedColor;

  final ValueChanged<int?> onChanged;

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
              'Accent Colour',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AutoChip(
                  selected: selectedColor == null,
                  onTap: () => onChanged(null),
                ),

                ...SubjectColors.palette.map(
                  (value) => _ColorCircle(
                    color: Color(value),
                    selected: selectedColor == value,
                    onTap: () => onChanged(value),
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

class _AutoChip extends StatelessWidget {
  const _AutoChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: const Text('Auto'),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: selected ? 8 : 2,
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ],
        ),
        child: selected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}