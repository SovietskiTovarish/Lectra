import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/constants/app_constants.dart';
import 'package:lectra/features/settings/controller.dart';

/// Application settings and preferences.
///
/// Covers appearance (theme mode), the attendance target used by
/// the Analytics section on each Subject Detail page, and basic app
/// info. Changes take effect immediately app-wide since both
/// [themeModeControllerProvider] and [attendanceTargetProvider] are
/// watched directly by the screens that use them.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceTarget = ref.watch(attendanceTargetProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          const _ThemeModeTile(),
          const Divider(height: 1),
          const _SectionHeader('Attendance'),
          _AttendanceTargetTile(target: attendanceTarget),
          const Divider(height: 1),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(AppConstants.appName),
            subtitle: Text('Track your classes, schedule, and attendance.'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Theme'),
          const SizedBox(height: 4),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) {
              ref
                  .read(themeModeControllerProvider.notifier)
                  .setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AttendanceTargetTile extends ConsumerWidget {
  const _AttendanceTargetTile({required this.target});

  final double target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attendance target'),
              Text(
                '${target.round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          Slider(
            value: target,
            min: 50,
            max: 100,
            divisions: 50,
            label: '${target.round()}%',
            onChanged: (value) {
              ref
                  .read(attendanceTargetProvider.notifier)
                  .setAttendanceTarget(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Used by each subject\'s Analytics section to show how '
              'many classes you can miss or need to attend to stay '
              'above this percentage.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}