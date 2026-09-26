"""Held-out evaluation, baselines and deployment checks."""

from __future__ import annotations

import numpy as np
import pandas as pd
from sklearn.metrics import (
    average_precision_score,
    brier_score_loss,
    log_loss,
    mean_absolute_error,
    mean_squared_error,
    roc_auc_score,
)

# Rule baseline mirrors part of the label definition: "last SGPA below 6".
RULE_BASELINE_SGPA = 6.0

# A model is only recommended for use if it passes every check.
MIN_TEST_AUC = 0.65
COVERAGE_TOLERANCE = 0.07


def _prf(pred: np.ndarray, y: np.ndarray) -> dict:
    tp = int(np.sum(pred & (y == 1)))
    fp = int(np.sum(pred & (y == 0)))
    fn = int(np.sum(~pred & (y == 1)))
    tn = int(np.sum(~pred & (y == 0)))
    precision = tp / (tp + fp) if tp + fp else 0.0
    recall = tp / (tp + fn) if tp + fn else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    return {
        "precision": round(precision, 4), "recall": round(recall, 4), "f1": round(f1, 4),
        "truePositives": tp, "falsePositives": fp, "falseNegatives": fn, "trueNegatives": tn,
    }


def calibration_table(p: np.ndarray, y: np.ndarray, bins: int = 10) -> list[dict]:
    edges = np.linspace(0, 1, bins + 1)
    rows = []
    for lo, hi in zip(edges[:-1], edges[1:]):
        mask = (p >= lo) & (p < hi if hi < 1 else p <= hi)
        if mask.sum() == 0:
            continue
        rows.append({
            "range": f"{lo:.1f}-{hi:.1f}", "count": int(mask.sum()),
            "meanPredicted": round(float(p[mask].mean()), 4),
            "observedRate": round(float(y[mask].mean()), 4),
        })
    return rows


def evaluate_risk(p: np.ndarray, y: np.ndarray, test: pd.DataFrame, bands: dict, train_rate: float) -> dict:
    y = y.astype(int)
    rule_rows = test["prev_sgpa"].notna().to_numpy()
    rule_pred = (test["prev_sgpa"].fillna(10) < RULE_BASELINE_SGPA).to_numpy()
    per_semester = []
    for sem, idx in test.groupby("target_semester").indices.items():
        ys = y[idx]
        if len(set(ys)) == 2 and len(idx) >= 20:
            per_semester.append({
                "targetSemester": int(sem), "rows": int(len(idx)),
                "auc": round(float(roc_auc_score(ys, p[idx])), 4),
                "positiveRate": round(float(ys.mean()), 4),
            })
    brier = float(brier_score_loss(y, p))
    brier_constant = float(brier_score_loss(y, np.full_like(p, train_rate)))
    return {
        "rows": int(len(y)),
        "positiveRate": round(float(y.mean()), 4),
        "auc": round(float(roc_auc_score(y, p)), 4),
        "averagePrecision": round(float(average_precision_score(y, p)), 4),
        "brier": round(brier, 4),
        "logLoss": round(float(log_loss(y, np.clip(p, 1e-6, 1 - 1e-6))), 4),
        "atElevatedThreshold": _prf(p >= bands["elevated"], y),
        "calibration": calibration_table(p, y),
        "perTargetSemester": per_semester,
        "baselines": {
            "constantRateBrier": round(brier_constant, 4),
            f"rulePrevSgpaBelow{RULE_BASELINE_SGPA:g}": {
                "rowsWithPrevSgpa": int(rule_rows.sum()),
                **_prf(rule_pred[rule_rows], y[rule_rows]),
            },
        },
    }


def evaluate_forecast(pred: np.ndarray, y: np.ndarray, half_width: float, level: float, test: pd.DataFrame) -> dict:
    prev = test["prev_sgpa"].to_numpy()
    has_prev = ~np.isnan(prev)
    covered = np.abs(y - pred) <= half_width
    return {
        "rows": int(len(y)),
        "mae": round(float(mean_absolute_error(y, pred)), 4),
        "rmse": round(float(np.sqrt(mean_squared_error(y, pred))), 4),
        "intervalLevel": level,
        "intervalHalfWidth": round(half_width, 4),
        "intervalCoverage": round(float(covered.mean()), 4),
        "baselines": {
            "previousSgpaMae": round(float(mean_absolute_error(y[has_prev], prev[has_prev])), 4),
            "rowsWithPrevSgpa": int(has_prev.sum()),
        },
    }


def risk_checks(metrics: dict) -> list[dict]:
    rule_key = next(k for k in metrics["baselines"] if k.startswith("rule"))
    rule_f1 = metrics["baselines"][rule_key]["f1"]
    return [
        _check("Discrimination", metrics["auc"] >= MIN_TEST_AUC,
               f"Test AUC {metrics['auc']} (minimum {MIN_TEST_AUC})."),
        _check("Better than simple rule", metrics["atElevatedThreshold"]["f1"] > rule_f1,
               f"F1 {metrics['atElevatedThreshold']['f1']} vs {rule_f1} for 'previous SGPA below "
               f"{RULE_BASELINE_SGPA:g}'."),
        _check("Calibrated better than a constant", metrics["brier"] < metrics["baselines"]["constantRateBrier"],
               f"Brier {metrics['brier']} vs {metrics['baselines']['constantRateBrier']} for always "
               "predicting the average rate."),
    ]


def forecast_checks(metrics: dict) -> list[dict]:
    level = metrics["intervalLevel"]
    return [
        _check("Better than last semester's SGPA", metrics["mae"] < metrics["baselines"]["previousSgpaMae"],
               f"MAE {metrics['mae']} vs {metrics['baselines']['previousSgpaMae']} for repeating the "
               "previous SGPA."),
        _check("Interval coverage", abs(metrics["intervalCoverage"] - level) <= COVERAGE_TOLERANCE,
               f"{metrics['intervalCoverage']:.0%} of test outcomes fell inside the {level:.0%} range "
               f"(tolerance ±{COVERAGE_TOLERANCE:.0%})."),
    ]


def _check(name: str, passed: bool, detail: str) -> dict:
    return {"name": name, "passed": bool(passed), "detail": detail}
