import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:lectra/core/constants/app_constants.dart';
import 'package:lectra/core/routing/app_router.dart';
import 'package:lectra/core/theme/app_theme.dart';

/// Root widget of the Lectra application.
///
/// Wires together Material 3 theming (with dynamic color support on
/// Android 12+), and the go_router based navigation configuration.
class LectraApp extends StatelessWidget {
  const LectraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(lightDynamic),
          darkTheme: AppTheme.dark(darkDynamic),
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}