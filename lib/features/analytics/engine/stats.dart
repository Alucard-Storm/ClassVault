import 'dart:math' as math;

/// Small statistics helpers shared by analytics (Phase 3) and ML feature
/// extraction (Phase 4), so both compute trends identically.
class Stats {
  const Stats._();

  static double mean(List<double> v) => v.reduce((a, b) => a + b) / v.length;

  /// Least-squares slope of [ys] against [xs]; 0 when all xs are equal.
  static double slope(List<double> xs, List<double> ys) {
    final n = xs.length;
    final mx = mean(xs);
    final my = mean(ys);
    var num = 0.0, den = 0.0;
    for (var i = 0; i < n; i++) {
      num += (xs[i] - mx) * (ys[i] - my);
      den += (xs[i] - mx) * (xs[i] - mx);
    }
    return den == 0 ? 0 : num / den;
  }

  /// Population standard deviation of the residuals around the least-squares
  /// line, i.e. spread that a steady trend does not explain.
  static double residualStdDev(List<double> xs, List<double> ys) {
    final b = slope(xs, ys);
    final mx = mean(xs);
    final my = mean(ys);
    var sumSq = 0.0;
    for (var i = 0; i < xs.length; i++) {
      final r = ys[i] - (my + b * (xs[i] - mx));
      sumSq += r * r;
    }
    return math.sqrt(sumSq / xs.length);
  }
}
