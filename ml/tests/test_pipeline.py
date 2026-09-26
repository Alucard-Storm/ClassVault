"""Run with:  cd ml && python -m unittest discover -s tests -v"""

import json
import shutil
import tempfile
import unittest
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd

from classvault_ml import models
from classvault_ml.data import DatasetError, Preprocessor, load_dataset, load_spec, split_by_student
from classvault_ml.train import train

DATA = Path(__file__).parent / "data" / "synthetic_fv1.csv"
FIXED_TIME = datetime(2026, 9, 26, tzinfo=timezone.utc)


def evaluate_bundle(bundle: dict, features: dict) -> float:
    """Independent reference implementation of the app's model format."""
    x = []
    for spec in bundle["inputs"]:
        v = features[spec["source"]]
        if spec["kind"] == "value":
            raw = spec["impute"] if v is None else v
        else:
            raw = 1.0 if v is None else 0.0
        x.append((raw - spec["mean"]) / spec["std"])
    m = bundle["model"]
    if bundle["family"] in ("logistic", "ridge"):
        return m["intercept"] + sum(c * xi for c, xi in zip(m["coefficients"], x))
    # Round inputs to float32 like sklearn, but compare in float64 against the
    # float64 thresholds (a numpy float32 scalar would round the threshold).
    xf = [float(v) for v in np.array(x, dtype=np.float32)]
    total = m["init"]
    for t in m["trees"]:
        node = 0
        while t["left"][node] != -1:
            node = t["left"][node] if xf[t["feature"][node]] <= t["threshold"][node] else t["right"][node]
        total += m["learningRate"] * t["value"][node]
    return total


def tree_shap_bruteforce(bundle: dict, features: dict) -> tuple[list[float], float]:
    """Exact path-dependent Shapley values by enumerating feature subsets per
    tree (depth-3 trees use at most 7 features). Mirrors the app."""
    from itertools import combinations
    from math import factorial

    x = []
    for spec in bundle["inputs"]:
        v = features[spec["source"]]
        raw = (spec["impute"] if v is None else v) if spec["kind"] == "value" else (1.0 if v is None else 0.0)
        x.append((raw - spec["mean"]) / spec["std"])
    xf = [float(v) for v in np.array(x, dtype=np.float32)]  # see evaluate_bundle
    m = bundle["model"]
    phi = [0.0] * len(x)
    base = m["init"]
    for t in m["trees"]:
        def value(node, S):
            if t["left"][node] == -1:
                return t["value"][node]
            f = t["feature"][node]
            l, r = t["left"][node], t["right"][node]
            if f in S:
                return value(l if xf[f] <= t["threshold"][node] else r, S)
            return (t["cover"][l] * value(l, S) + t["cover"][r] * value(r, S)) / t["cover"][node]

        used = sorted({f for n, f in enumerate(t["feature"]) if t["left"][n] != -1})
        n = len(used)
        base += m["learningRate"] * value(0, set())
        for i in used:
            others = [f for f in used if f != i]
            for k in range(n):
                for S in combinations(others, k):
                    w = factorial(k) * factorial(n - k - 1) / factorial(n)
                    phi[i] += m["learningRate"] * w * (value(0, set(S) | {i}) - value(0, set(S)))
    return phi, base


class DatasetTests(unittest.TestCase):
    def setUp(self):
        self.spec = load_spec()
        self.df = load_dataset(DATA, self.spec)

    def test_rejects_mismatched_columns(self):
        with tempfile.TemporaryDirectory() as d:
            bad = Path(d) / "bad.csv"
            self.df.drop(columns=["prev_sgpa"]).to_csv(bad, index=False)
            with self.assertRaisesRegex(DatasetError, "prev_sgpa"):
                load_dataset(bad, self.spec)

    def test_split_keeps_each_student_in_one_part(self):
        s = split_by_student(self.df)
        parts = [set(p.student_key) for p in (s.train, s.validation, s.test)]
        self.assertFalse(parts[0] & parts[1] or parts[0] & parts[2] or parts[1] & parts[2])
        self.assertEqual(sum(len(p) for p in (s.train, s.validation, s.test)), len(self.df))

    def test_preprocessor_is_fitted_on_training_rows_only(self):
        s = split_by_student(self.df)
        pre = Preprocessor(self.spec).fit(s.train)
        prev = next(i for i in pre.inputs if i["name"] == "prev_attendance")
        self.assertAlmostEqual(prev["impute"], float(s.train["prev_attendance"].median()))
        X = pre.transform(s.train)
        self.assertEqual(X.shape[1], len(pre.inputs))
        self.assertTrue(np.allclose(X.mean(axis=0), 0, atol=1e-9))
        self.assertIn("prev_attendance__missing", pre.input_names)


class ModelTests(unittest.TestCase):
    def test_conformal_quantile(self):
        residuals = np.arange(1, 11, dtype=float)  # |r| = 1..10
        # ceil((10+1)*0.8)/10 = 0.9 quantile ('higher') → 9
        self.assertEqual(models.conformal_half_width(residuals, 0.8), 9.0)


class TrainingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = Path(tempfile.mkdtemp())
        cls.fixture = cls.tmp / "parity.json"
        cls.written = train(DATA, cls.tmp, allow_synthetic=True, parity_fixture=cls.fixture, created_at=FIXED_TIME)
        cls.risk = json.loads(Path(cls.written["risk"]).read_text())
        cls.forecast = json.loads(Path(cls.written["forecast"]).read_text())

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(cls.tmp)

    def test_refuses_synthetic_without_flag(self):
        with self.assertRaisesRegex(DatasetError, "synthetic"):
            train(DATA, self.tmp / "x")

    def test_refuses_too_little_data(self):
        small = self.tmp / "small.csv"
        pd.read_csv(DATA).head(60).to_csv(small, index=False)
        with self.assertRaisesRegex(DatasetError, "Not enough data"):
            train(small, self.tmp / "y", allow_synthetic=True)

    def test_bundles_are_complete_and_marked_synthetic(self):
        for bundle in (self.risk, self.forecast):
            self.assertEqual(bundle["schema"], "classvault-model/1")
            self.assertEqual(bundle["featureVersion"], "fv1")
            self.assertEqual(bundle["trainingData"]["source"], "synthetic")
            self.assertFalse(bundle["recommended"])  # never recommend synthetic models
            self.assertTrue(bundle["checks"])
        self.assertEqual(self.risk["calibration"]["type"], "platt")
        self.assertLess(self.risk["bands"]["moderate"], self.risk["bands"]["elevated"] + 1e-9)
        self.assertEqual(self.forecast["interval"]["level"], 0.8)

    def test_cross_validation_is_reported_and_checked(self):
        for bundle in (self.risk, self.forecast):
            stability = bundle["metrics"]["stability"]
            self.assertEqual(len(stability["folds"]), 5)
            self.assertGreater(stability["mean"], 0)
            self.assertIn("Stable across data splits", [c["name"] for c in bundle["checks"]])
        # Synthetic data is homogeneous, so folds should agree closely.
        self.assertLess(self.risk["metrics"]["stability"]["sd"], 0.05)

    def test_model_beats_chance_on_synthetic_data(self):
        self.assertGreater(self.risk["metrics"]["auc"], 0.75)
        self.assertLess(self.forecast["metrics"]["mae"], self.forecast["metrics"]["baselines"]["previousSgpaMae"])

    def test_exports_reproduce_sklearn_for_every_family(self):
        fixture = json.loads(self.fixture.read_text())
        families = {m["family"] for m in fixture["models"]}
        self.assertEqual(families, {"logistic", "gbt_classifier", "ridge", "gbt_regressor"})
        for row in fixture["rows"]:
            for bundle in fixture["models"]:
                expected = row["expected"][bundle["modelId"]]["raw"]
                self.assertAlmostEqual(evaluate_bundle(bundle, row["features"]), expected, places=6)

    def test_every_exported_model_records_its_data_source(self):
        fixture = json.loads(self.fixture.read_text())
        for bundle in fixture["models"]:
            self.assertEqual(bundle["trainingData"]["source"], "synthetic", bundle["modelId"])

    def test_bruteforce_tree_shap_matches_shap_library(self):
        fixture = json.loads(self.fixture.read_text())
        trees = [m for m in fixture["models"] if m["family"].startswith("gbt")]
        if "shap" not in fixture["rows"][0]["expected"][trees[0]["modelId"]]:
            self.skipTest("shap not installed; reference values not in fixture")
        for bundle in trees:
            for row in fixture["rows"][:8]:
                expected = row["expected"][bundle["modelId"]]
                phi, base = tree_shap_bruteforce(bundle, row["features"])
                self.assertAlmostEqual(base, expected["shapBase"], places=6)
                for got, want in zip(phi, expected["shap"]):
                    self.assertAlmostEqual(got, want, places=6)
                self.assertAlmostEqual(base + sum(phi), expected["raw"], places=6)

    def test_fixture_exercises_missing_values(self):
        fixture = json.loads(self.fixture.read_text())
        self.assertTrue(any(None in r["features"].values() for r in fixture["rows"]))

    def test_report_written(self):
        report = Path(self.written["report"]).read_text(encoding="utf-8")
        self.assertIn("Synthetic data", report)
        self.assertIn("Recommended for use:** no", report)


if __name__ == "__main__":
    unittest.main()
