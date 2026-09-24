import 'package:flutter/material.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.outline,
    required this.outlineVariant,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.inversePrimary,
    required this.shadow,
    required this.scrim,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;
  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color outline;
  final Color outlineVariant;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color inversePrimary;
  final Color shadow;
  final Color scrim;

  // "Warm Amber & Ink": success/danger/info keep their conventional hues
  // (green/red/blue read correctly regardless of brand accent), but the
  // neutral family is warm stone (not cool slate) to match the amber
  // primary, and `warning` is shifted to gold so it doesn't twin with the
  // amber-700 primary/accent.
  static const AppColorScheme light = AppColorScheme(
    // success/warning/info are darkened one step from the "obvious" 500
    // shade specifically so they pass 4.5:1 text/icon contrast on white —
    // the 500 shades (emerald-500, blue-500, yellow-600) look right in a
    // palette swatch but measure 2.5-3.7:1 here and fail WCAG AA when used
    // as status text/icons rather than large fills.
    success: Color(0xFF047857), // emerald-700, 5.48:1 on white
    successContainer: Color(0xFFD1FAE5),
    onSuccessContainer: Color(0xFF065F46),
    warning: Color(0xFFA16207), // yellow-700, 4.92:1 on white — also distinct from the amber-700 accent
    warningContainer: Color(0xFFFEF9C3),
    onWarningContainer: Color(0xFF713F12),
    danger: Color(0xFFDC2626),
    dangerContainer: Color(0xFFFEF2F2),
    onDangerContainer: Color(0xFF991B1B),
    info: Color(0xFF2563EB), // blue-600, 5.17:1 on white
    infoContainer: Color(0xFFDBEAFE),
    onInfoContainer: Color(0xFF1E40AF),
    outline: Color(0xFFE7E5E4), // stone-200
    outlineVariant: Color(0xFFD6D3D1), // stone-300
    surfaceVariant: Color(0xFFFAFAF9), // stone-50
    onSurfaceVariant: Color(0xFF78716C), // stone-500
    inverseSurface: Color(0xFF1C1917), // stone-900
    inversePrimary: Color(0xFFFCD34D), // amber-300
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const AppColorScheme dark = AppColorScheme(
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    onSuccessContainer: Color(0xFFD1FAE5),
    warning: Color(0xFFFACC15), // yellow-400
    warningContainer: Color(0xFF422006),
    onWarningContainer: Color(0xFFFEF9C3),
    danger: Color(0xFFF87171),
    dangerContainer: Color(0xFF7F1D1D),
    onDangerContainer: Color(0xFFFEF2F2),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF1E3A5F),
    onInfoContainer: Color(0xFFDBEAFE),
    outline: Color(0xFF57534E), // stone-600
    outlineVariant: Color(0xFF44403C), // stone-700
    surfaceVariant: Color(0xFF292524), // stone-800
    onSurfaceVariant: Color(0xFFA8A29E), // stone-400
    inverseSurface: Color(0xFFFAFAF9), // stone-50
    inversePrimary: Color(0xFFB45309), // amber-700
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  @override
  AppColorScheme copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? outline,
    Color? outlineVariant,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? inversePrimary,
    Color? shadow,
    Color? scrim,
  }) {
    return AppColorScheme(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inversePrimary: inversePrimary ?? this.inversePrimary,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer: Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      inversePrimary: Color.lerp(inversePrimary, other.inversePrimary, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

extension AppColorSchemeExt on ThemeData {
  AppColorScheme get appColors => extension<AppColorScheme>() ?? AppColorScheme.light;
}