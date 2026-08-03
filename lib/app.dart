import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/providers.dart';

class ClassVaultApp extends ConsumerWidget {
  const ClassVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'ClassVault',
          themeMode: themeMode,
          theme: AppTheme.fromDynamic(lightDynamic, isDark: false),
          darkTheme: AppTheme.fromDynamic(darkDynamic, isDark: true),
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
