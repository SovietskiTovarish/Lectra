import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/constants/app_constants.dart';
import 'package:lectra/core/routing/app_router.dart';
import 'package:lectra/core/services/update_controller.dart';
import 'package:lectra/core/theme/app_theme.dart';
import 'package:lectra/features/settings/controller.dart';
import 'package:lectra/shared/widgets/update_dialog.dart';

/// Root widget of the Lectra application.
///
/// Wires together Material 3 theming (with dynamic color support on
/// Android 12+), go_router based navigation, the user's chosen
/// theme mode from Settings, and the once-per-day OTA update check.
class LectraApp extends ConsumerStatefulWidget {
  const LectraApp({super.key});

  @override
  ConsumerState<LectraApp> createState() => _LectraAppState();
}

class _LectraAppState extends ConsumerState<LectraApp> {
  bool _promptShown = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeControllerProvider);

    ref.listen(updateControllerProvider, (previous, next) {
      final info = next.valueOrNull;
      if (info != null && !_promptShown) {
        _promptShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navigatorContext =
              AppRouter.router.routerDelegate.navigatorKey.currentContext;
          if (navigatorContext != null) {
            UpdateDialog.showIfNeeded(navigatorContext, info);
          }
        });
      }
    });

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(lightDynamic),
          darkTheme: AppTheme.dark(darkDynamic),
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}