/// Design tokens shared across the app: spacing, radius, breakpoints, and
/// motion timing. Every screen should pull from these instead of inventing
/// its own magic numbers.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Locked radius scale: inputs are 8, cards/dialogs/sheets are 16, actions
/// (buttons, chips, badges) are fully-rounded pills. Never mix in a fourth
/// value.
class AppRadius {
  const AppRadius._();

  static const double control = 8;
  static const double card = 16;
  static const double pill = 999;
}

/// Layout breakpoints (logical px width).
class AppBreakpoints {
  const AppBreakpoints._();

  /// Below this, screens use the mobile/tablet chrome (drawer or bottom
  /// nav) instead of the persistent desktop sidebar.
  static const double desktop = 960;

  /// Below this, two-pane layouts collapse into a single stacked column.
  static const double twoPane = 1100;
}

/// Standard motion durations and curve. See flutter_animate usage across
/// the app — entrances should stay within this budget.
class AppMotion {
  const AppMotion._();

  static const Duration press = Duration(milliseconds: 120);
  static const Duration entrance = Duration(milliseconds: 250);
  static const Duration stagger = Duration(milliseconds: 40);
}
