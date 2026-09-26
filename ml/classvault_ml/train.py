"""End-to-end training: export CSV → validated, calibrated, evaluated model
files the ClassVault app can import."""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.metrics import mean_absolute_error, roc_auc_score
from sklearn.model_selection import GroupKFold

from . import evaluate, models
from .data import DatasetError, FeatureSpec, Preprocessor, data_source, load_dataset, load_spec, split_by_student

SCHEMA = "classvault-model/1"
INTERVAL_LEVEL = 0.8
CV_FOLDS = 5

# Refuse to train on less than this unless explicitly overridden.
MIN_ROWS = 200
MIN_STUDENTS = 50
MIN_PER_CLASS = 30


def check_data(df: pd.DataFrame, allow_small: bool) -> list[str]:
    risk = df["label_risk"].dropna()
    problems = []
    if len(df) < MIN_ROWS:
        problems.append(f"{len(df)} rows (minimum {MIN_ROWS})")
    if df["student_key"].nunique() < MIN_STUDENTS:
        problems.append(f"{df['student_key'].nunique()} students (minimum {MIN_STUDENTS})")
    if (risk == 1).sum() < MIN_PER_CLASS or (risk == 0).sum() < MIN_PER_CLASS:
        problems.append(
            f"{int((risk == 1).sum())} difficulty / {int((risk == 0).sum())} no-difficulty outcomes "
            f"(minimum {MIN_PER_CLASS} each)"
        )
    if problems and not allow_small:
        raise DatasetError(
            "Not enough data to train a trustworthy model: " + "; ".join(problems)
            + ". Import more history, or pass --allow-small for experiments."
        )
    return problems


def train(
    dataset: str | Path,
    out_dir: str | Path,
    *,
    allow_synthetic: bool = False,
    allow_small: bool = False,
    parity_fixture: str | Path | None = None,
    created_at: datetime | None = None,
) -> dict:
    spec = load_spec()
    df = load_dataset(dataset, spec)
    source = data_source(df)
    if source == "synthetic" and not allow_synthetic:
        raise DatasetError("This is a synthetic dataset. Pass --allow-synthetic to train a test-only model.")
    small_data = check_data(df, allow_small)

    created = (created_at or datetime.now(timezone.utc)).replace(microsecond=0)
    stamp = created.strftime("%Y%m%dT%H%M%SZ")
    split = split_by_student(df)
    pre = Preprocessor(spec).fit(split.train)

    common = {
        "schema": SCHEMA,
        "featureVersion": spec.feature_version,
        "labelVersion": spec.label_version,
        "createdAt": created.isoformat().replace("+00:00", "Z"),
        "inputs": pre.inputs,
    }

    risk = _train_risk(spec, split, pre, source, small_data, common, stamp)
    forecast = _train_forecast(spec, split, pre, source, small_data, common, stamp)

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    written = {}
    for bundle in (risk["bundle"], forecast["bundle"]):
        path = out / f"{bundle['modelId']}.json"
        path.write_text(json.dumps(bundle, indent=1), encoding="utf-8")
        written[bundle["task"]] = str(path)
    report = out / f"report-{stamp}.md"
    report.write_text(_report(risk["bundle"], forecast["bundle"]), encoding="utf-8")
    written["report"] = str(report)

    if parity_fixture:
        _write_parity_fixture(Path(parity_fixture), split.test, pre, risk, forecast)
        written["parity_fixture"] = str(parity_fixture)
    return written


def _train_risk(spec, split, pre, source, small_data, common, stamp) -> dict:
    tr, va, te = (s[s["label_risk"].notna()] for s in (split.train, split.validation, split.test))
    Xtr, Xva, Xte = pre.transform(tr), pre.transform(va), pre.transform(te)
    ytr, yva, yte = (s["label_risk"].to_numpy(dtype=int) for s in (tr, va, te))

    candidates = models.fit_risk_candidates(Xtr, ytr, Xva, yva)
    for c in candidates:
        c["platt"] = models.fit_platt(models.raw_score(c["model"], Xva), yva)
    chosen, reason = models.choose_risk(candidates)
    a, b = chosen["platt"]
    p_val = models.sigmoid(a * models.raw_score(chosen["model"], Xva) + b)
    train_rate = float(ytr.mean())
    bands = models.choose_bands(p_val, yva, train_rate)

    p_test = models.sigmoid(a * models.raw_score(chosen["model"], Xte) + b)
    metrics = evaluate.evaluate_risk(p_test, yte, te, bands, train_rate)
    metrics["stability"] = _cross_validate(spec, pd.concat([tr, va]), chosen, "label_risk")
    checks = evaluate.risk_checks(metrics) + [evaluate.risk_stability_check(metrics["stability"])]

    training_data = _training_data(source, split, "label_risk", small_data, positive_rate=train_rate)

    def bundle_for(c: dict) -> dict:
        ca, cb = c["platt"]
        return {
            **common,
            "modelId": f"risk-{common['featureVersion']}-{stamp}-{c['family']}",
            "task": "risk",
            "family": c["family"],
            "trainingData": training_data,
            "model": models.export_model(c["model"], c["family"], Xva),
            "calibration": {"type": "platt", "a": ca, "b": cb},
            "bands": bands,
        }

    bundle = {
        **bundle_for(chosen),
        "selection": {
            "reason": reason,
            "candidates": [
                {"family": c["family"], "params": c["params"], "validationAuc": round(c["validation_auc"], 4)}
                for c in candidates
            ],
        },
        "metrics": metrics,
        "checks": checks,
        "recommended": source == "classvault" and not small_data and all(c["passed"] for c in checks),
    }
    return {"bundle": bundle, "candidates": candidates, "bundle_for": bundle_for}


def _train_forecast(spec, split, pre, source, small_data, common, stamp) -> dict:
    tr, va, te = (s[s["label_sgpa"].notna()] for s in (split.train, split.validation, split.test))
    Xtr, Xva, Xte = pre.transform(tr), pre.transform(va), pre.transform(te)
    ytr, yva, yte = (s["label_sgpa"].to_numpy(dtype=float) for s in (tr, va, te))

    candidates = models.fit_forecast_candidates(Xtr, ytr, Xva, yva)
    for c in candidates:
        c["half_width"] = models.conformal_half_width(yva - c["model"].predict(Xva), INTERVAL_LEVEL)
    chosen, reason = models.choose_forecast(candidates)
    pred = chosen["model"].predict(Xte)
    metrics = evaluate.evaluate_forecast(pred, yte, chosen["half_width"], INTERVAL_LEVEL, te)
    metrics["stability"] = _cross_validate(spec, pd.concat([tr, va]), chosen, "label_sgpa")
    checks = evaluate.forecast_checks(metrics) + [evaluate.forecast_stability_check(metrics["stability"])]

    training_data = _training_data(source, split, "label_sgpa", small_data)

    def bundle_for(c: dict) -> dict:
        return {
            **common,
            "modelId": f"forecast-{common['featureVersion']}-{stamp}-{c['family']}",
            "task": "forecast",
            "family": c["family"],
            "trainingData": training_data,
            "model": models.export_model(c["model"], c["family"], Xva),
            "interval": {"level": INTERVAL_LEVEL, "halfWidth": c["half_width"]},
        }

    bundle = {
        **bundle_for(chosen),
        "selection": {
            "reason": reason,
            "candidates": [
                {"family": c["family"], "params": c["params"], "validationMae": round(c["validation_mae"], 4)}
                for c in candidates
            ],
        },
        "metrics": metrics,
        "checks": checks,
        "recommended": source == "classvault" and not small_data and all(c["passed"] for c in checks),
    }
    return {"bundle": bundle, "candidates": candidates, "bundle_for": bundle_for}


def _cross_validate(spec: FeatureSpec, rows: pd.DataFrame, chosen: dict, label: str) -> dict:
    """Refits the chosen model family on student-grouped folds of the
    training + validation rows (preprocessing refitted per fold, test rows
    untouched) and scores each held-out fold."""
    folds = GroupKFold(n_splits=min(CV_FOLDS, rows["student_key"].nunique()))
    scores = []
    for train_idx, test_idx in folds.split(rows, groups=rows["student_key"]):
        fit_rows, score_rows = rows.iloc[train_idx], rows.iloc[test_idx]
        pre = Preprocessor(spec).fit(fit_rows)
        model = models.new_estimator(chosen["family"], chosen["params"])
        model.fit(pre.transform(fit_rows), fit_rows[label].to_numpy())
        X, y = pre.transform(score_rows), score_rows[label].to_numpy()
        if label == "label_risk":
            if len(set(y)) < 2:
                continue
            scores.append(roc_auc_score(y, models.raw_score(model, X)))
        else:
            scores.append(mean_absolute_error(y, model.predict(X)))
    return evaluate.stability(scores)


def _training_data(source, split, label, small_data, positive_rate=None) -> dict:
    parts = {n: s[s[label].notna()] for n, s in
             (("train", split.train), ("validation", split.validation), ("test", split.test))}
    info = {
        "source": source,
        "rows": int(sum(len(p) for p in parts.values())),
        "students": int(sum(p["student_key"].nunique() for p in parts.values())),
        "trainRows": len(parts["train"]),
        "validationRows": len(parts["validation"]),
        "testRows": len(parts["test"]),
        "splitBy": "student",
        "smallDataWarnings": small_data,
    }
    if positive_rate is not None:
        info["positiveRate"] = round(positive_rate, 4)
    return info


# ---------------------------------------------------------------------------
# Parity fixture: every candidate model plus expected outputs for held-out
# rows, so the app's implementation can be checked against sklearn.
# ---------------------------------------------------------------------------

def _write_parity_fixture(path: Path, test: pd.DataFrame, pre: Preprocessor, risk: dict, forecast: dict) -> None:
    # Prefer rows with missing values so imputation/indicators are exercised.
    rows = pd.concat([test[test.isna().any(axis=1)].head(15), test[~test.isna().any(axis=1)].head(10)])
    X = pre.transform(rows)
    fixture_models, expected = [], {i: {} for i in range(len(rows))}

    for c in risk["candidates"]:
        bundle = risk["bundle_for"](c)
        fixture_models.append(bundle)
        a, b = c["platt"]
        raw = models.raw_score(c["model"], X)
        p = models.sigmoid(a * raw + b)
        for i in range(len(rows)):
            expected[i][bundle["modelId"]] = {"raw": float(raw[i]), "probability": float(p[i])}
        _add_shap(expected, bundle, c["model"], X)
    for c in forecast["candidates"]:
        bundle = forecast["bundle_for"](c)
        fixture_models.append(bundle)
        pred = c["model"].predict(X)
        for i in range(len(rows)):
            expected[i][bundle["modelId"]] = {"raw": float(pred[i])}
        _add_shap(expected, bundle, c["model"], X)

    features = rows[pre.spec.features]
    payload = {
        "models": fixture_models,
        "rows": [
            {
                "features": {k: (None if pd.isna(v) else float(v)) for k, v in features.iloc[i].items()},
                "expected": expected[i],
            }
            for i in range(len(rows))
        ],
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload), encoding="utf-8")


def _add_shap(expected: dict, bundle: dict, model, X: np.ndarray) -> None:
    """Reference SHAP values from the `shap` library for tree models, if it
    is installed (test-only dependency; see requirements-dev.txt)."""
    if not bundle["family"].startswith("gbt"):
        return
    try:
        import shap  # noqa: PLC0415
    except ImportError:
        return
    explainer = shap.TreeExplainer(model, feature_perturbation="tree_path_dependent")
    values = np.asarray(explainer.shap_values(X))
    base = float(np.ravel(explainer.expected_value)[0])
    for i in range(len(X)):
        expected[i][bundle["modelId"]]["shap"] = [float(v) for v in values[i]]
        expected[i][bundle["modelId"]]["shapBase"] = base


# ---------------------------------------------------------------------------

def _report(risk: dict, forecast: dict) -> str:
    def checks(bundle):
        return "\n".join(f"- {'PASS' if c['passed'] else 'FAIL'} **{c['name']}**: {c['detail']}" for c in bundle["checks"])

    rm, fm = risk["metrics"], forecast["metrics"]
    td = risk["trainingData"]
    warning = ""
    if td["source"] == "synthetic":
        warning = "\n> **Synthetic data.** These models are for testing the pipeline only and must not be used for real students.\n"
    if td["smallDataWarnings"]:
        warning += "\n> **Small dataset:** " + "; ".join(td["smallDataWarnings"]) + ".\n"
    calib = "\n".join(
        f"| {r['range']} | {r['count']} | {r['meanPredicted']:.2f} | {r['observedRate']:.2f} |" for r in rm["calibration"]
    )
    at = rm["atElevatedThreshold"]
    return f"""# ClassVault model report ({risk['createdAt']})
{warning}
Feature version `{risk['featureVersion']}`, labels `{risk['labelVersion']}`. Data split by student:
{td['trainRows']} train / {td['validationRows']} validation / {td['testRows']} test rows. All metrics below are on the
held-out test students.

## Academic risk: `{risk['modelId']}`

{risk['selection']['reason']}

| Metric | Value |
|---|---|
| AUC | {rm['auc']} |
| Average precision | {rm['averagePrecision']} |
| Brier score | {rm['brier']} (constant-rate baseline {rm['baselines']['constantRateBrier']}) |
| "Elevated" threshold | p ≥ {risk['bands']['elevated']} ("moderate" from {risk['bands']['moderate']}) |
| Precision / recall at "elevated" | {at['precision']} / {at['recall']} |
| False positives / false negatives | {at['falsePositives']} / {at['falseNegatives']} |

Calibration (predicted vs observed difficulty rate):

| Predicted range | Rows | Mean predicted | Observed |
|---|---|---|---|
{calib}

Stability by target semester: {', '.join(f"S{s['targetSemester']} AUC {s['auc']}" for s in rm['perTargetSemester']) or 'n/a'}.
Cross-validated across student groups: AUC {rm['stability']['mean']} ± {rm['stability']['sd']} ({len(rm['stability']['folds'])} folds).

{checks(risk)}

**Recommended for use:** {'yes' if risk['recommended'] else 'no'}

## SGPA forecast: `{forecast['modelId']}`

{forecast['selection']['reason']}

| Metric | Value |
|---|---|
| MAE | {fm['mae']} (previous-SGPA baseline {fm['baselines']['previousSgpaMae']}) |
| RMSE | {fm['rmse']} |
| {fm['intervalLevel']:.0%} range | ± {fm['intervalHalfWidth']:.2f} SGPA, covering {fm['intervalCoverage']:.0%} of test outcomes |
| Cross-validated MAE | {fm['stability']['mean']} ± {fm['stability']['sd']} ({len(fm['stability']['folds'])} student-grouped folds) |

{checks(forecast)}

**Recommended for use:** {'yes' if forecast['recommended'] else 'no'}
"""
