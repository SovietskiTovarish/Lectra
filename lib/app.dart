import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lectra/core/constants/app_constants.dart';
import 'package:lectra/core/routing/app_router.dart';
import 'package:lectra/core/theme/app_theme.dart';
import 'package:lectra/features/settings/controller.dart';

/// Root widget of the Lectra application.
///
/// Wires together Material 3 theming (with dynamic color support on
/// Android 12+), the go_router based navigation configuration, and
/// the user's chosen theme mode from Settings.
class LectraApp extends ConsumerWidget {
  const LectraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeControllerProvider);

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
