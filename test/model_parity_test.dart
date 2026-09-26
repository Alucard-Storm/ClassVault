import 'dart:convert';
import 'dart:io';

import 'package:classvault/features/prediction/engine/model_bundle.dart';
import 'package:flutter_test/flutter_test.dart';

/// `test/fixtures/ml_parity.json` is written by the Python pipeline:
///   cd ml && python -m classvault_ml train tests/data/synthetic_fv1.csv \
///     --out ../build/ml-try --allow-synthetic --parity-fixture ../test/fixtures/ml_parity.json
/// It holds every candidate model family and sklearn's outputs for held-out
/// rows; the app must reproduce them.
void main() {
  final fixture = jsonDecode(File('test/fixtures/ml_parity.json').readAsStringSync()) as Map<String, dynamic>;
  final bundles = [
    for (final m in (fixture['models'] as List).cast<Map<String, dynamic>>()) ModelBundle.parse(jsonEncode(m)),
  ];
  final rows = (fixture['rows'] as List).cast<Map<String, dynamic>>();

  test('fixture covers every model family and missing values', () {
    expect(bundles.map((b) => b.family).toSet(), {'logistic', 'gbt_classifier', 'ridge', 'gbt_regressor'});
    expect(rows.any((r) => (r['features'] as Map).containsValue(null)), isTrue);
  });

  for (final bundle in bundles) {
    test('${bundle.family} matches sklearn and contributions add up', () {
      for (final row in rows) {
        final features = (row['features'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num?)?.toDouble()));
        final expected = (row['expected'] as Map<String, dynamic>)[bundle.modelId] as Map<String, dynamic>;
        final out = Predictor.run(bundle, features);

        expect(out.raw, closeTo((expected['raw'] as num).toDouble(), 1e-6));
        if (bundle.task == ModelTask.risk) {
          expect(out.probability, closeTo((expected['probability'] as num).toDouble(), 1e-6));
          expect(out.band, isNotNull);
        } else {
          expect(out.lower! <= out.value! && out.value! <= out.upper!, isTrue);
        }
        final total = out.bias + out.contributions.fold<double>(0, (a, c) => a + c.contribution);
        expect(total, closeTo(out.raw, 1e-6));
      }
    });
  }

  group('rejects unusable model files', () {
    Map<String, dynamic> base() => jsonDecode(jsonEncode(fixture['models'][0])) as Map<String, dynamic>;

    test('wrong feature version', () {
      final j = base()..['featureVersion'] = 'fv0';
      expect(() => ModelBundle.parse(jsonEncode(j)), throwsA(isA<ModelFormatException>()));
    });
    test('unknown input feature', () {
      final j = base();
      (j['inputs'] as List).first['source'] = 'shoe_size';
      expect(() => ModelBundle.parse(jsonEncode(j)), throwsA(isA<ModelFormatException>()));
    });
    test('coefficient count mismatch', () {
      final j = base();
      final m = j['model'] as Map<String, dynamic>;
      if (m.containsKey('coefficients')) (m['coefficients'] as List).removeLast();
      expect(() => ModelBundle.parse(jsonEncode(j)), throwsA(isA<ModelFormatException>()));
    });
    test('not JSON', () {
      expect(() => ModelBundle.parse('nope'), throwsA(isA<ModelFormatException>()));
    });
  });
}
