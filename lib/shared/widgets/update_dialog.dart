import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/services/update_controller.dart';
import 'package:lectra/core/services/update_installer.dart';
import 'package:lectra/core/services/update_models.dart';

/// Prompts the user to install an available update.
///
/// Major-version updates use `barrierDismissible: false` so the
/// user must explicitly choose "Install" or "Later" rather than
/// tapping outside the dialog — Android still requires their
/// confirmation in the system installer regardless.
class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({required this.info, super.key});

  final UpdateInfo info;

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();

  static Future<void> showIfNeeded(BuildContext context, UpdateInfo info) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !info.isMajor,
      builder: (_) => UpdateDialog(info: info),
    );
  }
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _installing = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update available: ${widget.info.version}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.info.isMajor)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'This is a major update.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              widget.info.releaseNotes.isEmpty
                  ? 'A new version of Lectra is ready to install.'
                  : widget.info.releaseNotes,
            ),
            if (_installing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!widget.info.isMajor)
          TextButton(
            onPressed: _installing
                ? null
                : () {
                    ref.read(updateControllerProvider.notifier).dismiss();
                    Navigator.of(context).pop();
                  },
            child: const Text('Later'),
          ),
        FilledButton(
          onPressed: _installing ? null : _install,
          child: Text(
            _installing
                ? (_progress > 0
                    ? 'Downloading ${(_progress * 100).round()}%'
                    : 'Downloading…')
                : 'Install',
          ),
        ),
      ],
    );
  }

  Future<void> _install() async {
    setState(() {
      _installing = true;
      _progress = 0;
    });
    final result = await ref
        .read(updateControllerProvider.notifier)
        .installUpdate(
          widget.info,
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
        );
    if (!mounted) return;
    setState(() => _installing = false);

    switch (result) {
      case InstallResult.launched:
        ref.read(updateControllerProvider.notifier).dismiss();
        Navigator.of(context).pop();
      case InstallResult.downloadFailed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download failed. Check your connection and try again.'),
          ),
        );
      case InstallResult.installFailed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not start the installer. Enable "Install unknown apps" '
              'for Lectra in system settings, then try again.',
            ),
          ),
        );
    }
  }
}