import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'feature_extractor.dart';

enum ModelTask { risk, forecast }

class ModelFormatException implements Exception {
  final String message;
  ModelFormatException(this.message);
  @override
  String toString() => message;
}

/// One model input after preprocessing: a feature's (imputed) value or its
/// missing-value indicator, standardised.
class ModelInput {
  final String name;
  final String source;
  final bool isMissingIndicator;
  final double impute;
  final double mean;
  final double std;

  const ModelInput(this.name, this.source, this.isMissingIndicator, this.impute, this.mean, this.std);

  double transform(double? raw) {
    final x = isMissingIndicator ? (raw == null ? 1.0 : 0.0) : (raw ?? impute);
    return (x - mean) / std;
  }
}

class QualityCheck {
  final String name;
  final bool passed;
  final String detail;
  const QualityCheck(this.name, this.passed, this.detail);
}

class DecisionTree {
  final List<int> left, right, feature;
  final List<double> threshold, value;
  DecisionTree(this.left, this.right, this.feature, this.threshold, this.value);
}

/// A model file produced by `ml/` (schema `classvault-model/1`).
class ModelBundle {
  static const schema = 'classvault-model/1';

  final String rawJson;
  final String modelId;
  final ModelTask task;
  final String family;
  final String featureVersion;
  final String labelVersion;
  final DateTime createdAt;
  final List<ModelInput> inputs;
  final String trainingSource;
  final int trainingRows;
  final bool recommended;
  final List<QualityCheck> checks;
  final Map<String, dynamic> metrics;
  final String selectionReason;

  // Linear families
  final double? intercept;
  final List<double>? coefficients;
  // Tree families
  final double? init;
  final double? learningRate;
  final List<DecisionTree>? trees;

  // Risk
  final double? calibrationA, calibrationB;
  final double? elevatedThreshold, moderateThreshold;
  // Forecast
  final double? intervalLevel, intervalHalfWidth;

  ModelBundle._({
    required this.rawJson,
    required this.modelId,
    required this.task,
    required this.family,
    required this.featureVersion,
    required this.labelVersion,
    required this.createdAt,
    required this.inputs,
    required this.trainingSource,
    required this.trainingRows,
    required this.recommended,
    required this.checks,
    required this.metrics,
    required this.selectionReason,
    this.intercept,
    this.coefficients,
    this.init,
    this.learningRate,
    this.trees,
    this.calibrationA,
    this.calibrationB,
    this.elevatedThreshold,
    this.moderateThreshold,
    this.intervalLevel,
    this.intervalHalfWidth,
  });

  bool get isSynthetic => trainingSource == 'synthetic';
  bool get isTree => trees != null;

  static ModelBundle parse(String text) {
    final Map<String, dynamic> j;
    try {
      j = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      throw ModelFormatException('Not a valid model file (could not read JSON).');
    }
    T req<T>(Map<String, dynamic> m, String key) {
      final v = m[key];
      if (v is! T) throw ModelFormatException('Model file is missing "$key".');
      return v;
    }

    if (j['schema'] != schema) {
      throw ModelFormatException('Unsupported model format "${j['schema']}" (expected $schema).');
    }
    final featureVersion = req<String>(j, 'featureVersion');
    if (featureVersion != FeatureSpec.version) {
      throw ModelFormatException(
          'Model uses features $featureVersion but this app computes ${FeatureSpec.version}. Retrain with a current export.');
    }
    final task = switch (req<String>(j, 'task')) {
      'risk' => ModelTask.risk,
      'forecast' => ModelTask.forecast,
      final t => throw ModelFormatException('Unknown task "$t".'),
    };
    final family = req<String>(j, 'family');

    final inputs = [
      for (final i in req<List>(j, 'inputs').cast<Map<String, dynamic>>())
        ModelInput(
          req<String>(i, 'name'),
          req<String>(i, 'source'),
          i['kind'] == 'missing',
          (i['impute'] as num?)?.toDouble() ?? 0,
          req<num>(i, 'mean').toDouble(),
          req<num>(i, 'std').toDouble(),
        ),
    ];
    for (final i in inputs) {
      if (!FeatureSpec.names.contains(i.source)) {
        throw ModelFormatException('Model input "${i.source}" is not a known feature.');
      }
      if (i.std <= 0) throw ModelFormatException('Invalid scaling for "${i.name}".');
    }

    final model = req<Map<String, dynamic>>(j, 'model');
    double? intercept, init, learningRate;
    List<double>? coefficients;
    List<DecisionTree>? trees;
    switch (family) {
      case 'logistic' || 'ridge':
        intercept = req<num>(model, 'intercept').toDouble();
        coefficients = [for (final c in req<List>(model, 'coefficients')) (c as num).toDouble()];
        if (coefficients.length != inputs.length) {
          throw ModelFormatException('Model has ${coefficients.length} coefficients for ${inputs.length} inputs.');
        }
      case 'gbt_classifier' || 'gbt_regressor':
        init = req<num>(model, 'init').toDouble();
        learningRate = req<num>(model, 'learningRate').toDouble();
        trees = [
          for (final t in req<List>(model, 'trees').cast<Map<String, dynamic>>())
            DecisionTree(
              [for (final v in req<List>(t, 'left')) v as int],
              [for (final v in req<List>(t, 'right')) v as int],
              [for (final v in req<List>(t, 'feature')) v as int],
              [for (final v in req<List>(t, 'threshold')) (v as num).toDouble()],
              [for (final v in req<List>(t, 'value')) (v as num).toDouble()],
            ),
        ];
        for (final t in trees) {
          for (var n = 0; n < t.left.length; n++) {
            if (t.left[n] != -1 && (t.feature[n] < 0 || t.feature[n] >= inputs.length)) {
              throw ModelFormatException('Tree refers to an unknown input.');
            }
          }
        }
      default:
        throw ModelFormatException('Unsupported model family "$family".');
    }
    final expectedFamilies = task == ModelTask.risk ? {'logistic', 'gbt_classifier'} : {'ridge', 'gbt_regressor'};
    if (!expectedFamilies.contains(family)) {
      throw ModelFormatException('A $family model cannot be used for ${task.name}.');
    }

    final training = (j['trainingData'] as Map<String, dynamic>?) ?? const {};
    final calibration = j['calibration'] as Map<String, dynamic>?;
    final bands = j['bands'] as Map<String, dynamic>?;
    final interval = j['interval'] as Map<String, dynamic>?;
    if (task == ModelTask.risk && (calibration == null || bands == null)) {
      throw ModelFormatException('Risk model is missing calibration or bands.');
    }
    if (task == ModelTask.forecast && interval == null) {
      throw ModelFormatException('Forecast model is missing its interval.');
    }

    return ModelBundle._(
      rawJson: text,
      modelId: req<String>(j, 'modelId'),
      task: task,
      family: family,
      featureVersion: featureVersion,
      labelVersion: (j['labelVersion'] as String?) ?? '',
      createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      inputs: inputs,
      trainingSource: (training['source'] as String?) ?? 'unknown',
      trainingRows: (training['rows'] as num?)?.toInt() ?? 0,
      recommended: j['recommended'] == true,
      checks: [
        for (final c in ((j['checks'] as List?) ?? const []).cast<Map<String, dynamic>>())
          QualityCheck(c['name'] as String, c['passed'] == true, c['detail'] as String? ?? ''),
      ],
      metrics: (j['metrics'] as Map<String, dynamic>?) ?? const {},
      selectionReason: ((j['selection'] as Map<String, dynamic>?)?['reason'] as String?) ?? '',
      intercept: intercept,
      coefficients: coefficients,
      init: init,
      learningRate: learningRate,
      trees: trees,
      calibrationA: (calibration?['a'] as num?)?.toDouble(),
      calibrationB: (calibration?['b'] as num?)?.toDouble(),
      elevatedThreshold: (bands?['elevated'] as num?)?.toDouble(),
      moderateThreshold: (bands?['moderate'] as num?)?.toDouble(),
      intervalLevel: (interval?['level'] as num?)?.toDouble(),
      intervalHalfWidth: (interval?['halfWidth'] as num?)?.toDouble(),
    );
  }
}

/// How much one feature moved the model's raw output (log-odds for risk,
/// SGPA for forecasts) relative to the training average.
class FeatureContribution {
  final String feature;
  final double? value;
  final double contribution;
  const FeatureContribution(this.feature, this.value, this.contribution);

  Map<String, dynamic> toJson() => {'feature': feature, 'value': value, 'contribution': contribution};

  factory FeatureContribution.fromJson(Map<String, dynamic> j) => FeatureContribution(
      j['feature'] as String, (j['value'] as num?)?.toDouble(), (j['contribution'] as num).toDouble());
}

enum RiskBand { low, moderate, elevated }

class ModelOutput {
  final double raw;
  final double bias;
  final List<FeatureContribution> contributions; // sorted by |contribution|
  final double? probability;
  final RiskBand? band;
  final double? value, lower, upper;

  const ModelOutput({
    required this.raw,
    required this.bias,
    required this.contributions,
    this.probability,
    this.band,
    this.value,
    this.lower,
    this.upper,
  });
}

/// Evaluates a [ModelBundle] exactly as `ml/` does (see the parity test).
class Predictor {
  const Predictor._();

  static ModelOutput run(ModelBundle m, Map<String, double?> features) {
    final x = [for (final i in m.inputs) i.transform(features[i.source])];
    final perInput = List<double>.filled(x.length, 0);
    double bias;
    double raw;

    if (!m.isTree) {
      bias = m.intercept!;
      raw = bias;
      for (var i = 0; i < x.length; i++) {
        perInput[i] = m.coefficients![i] * x[i];
        raw += perInput[i];
      }
    } else {
      // sklearn compares float32 inputs against the split thresholds.
      final xf = Float32List.fromList(x);
      final lr = m.learningRate!;
      bias = m.init!;
      for (final t in m.trees!) {
        var node = 0;
        bias += lr * t.value[0];
        while (t.left[node] != -1) {
          final next = xf[t.feature[node]] <= t.threshold[node] ? t.left[node] : t.right[node];
          // Path attribution: the change in node value is credited to the
          // feature that was split on (sums exactly to the prediction).
          perInput[t.feature[node]] += lr * (t.value[next] - t.value[node]);
          node = next;
        }
      }
      raw = bias + perInput.fold(0.0, (a, b) => a + b);
    }

    // Group value + missing-indicator inputs under their feature.
    final grouped = <String, double>{};
    for (var i = 0; i < x.length; i++) {
      final source = m.inputs[i].source;
      grouped[source] = (grouped[source] ?? 0) + perInput[i];
    }
    final contributions = [
      for (final e in grouped.entries) FeatureContribution(e.key, features[e.key], e.value),
    ]..sort((a, b) => b.contribution.abs().compareTo(a.contribution.abs()));

    if (m.task == ModelTask.risk) {
      final p = 1 / (1 + math.exp(-(m.calibrationA! * raw + m.calibrationB!)));
      final band = p >= m.elevatedThreshold!
          ? RiskBand.elevated
          : p >= m.moderateThreshold!
              ? RiskBand.moderate
              : RiskBand.low;
      return ModelOutput(raw: raw, bias: bias, contributions: contributions, probability: p, band: band);
    }
    final half = m.intervalHalfWidth!;
    return ModelOutput(
      raw: raw,
      bias: bias,
      contributions: contributions,
      value: raw,
      // SGPA is bounded; the range never extends past the scale.
      lower: (raw - half).clamp(0, 10).toDouble(),
      upper: (raw + half).clamp(0, 10).toDouble(),
    );
  }
}
