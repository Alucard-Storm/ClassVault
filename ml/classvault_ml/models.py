"""Candidate models and their export to the app's model format.

Only model families the app can evaluate from plain data are used:
logistic/ridge regression and gradient-boosted decision trees.
"""

from __future__ import annotations

import numpy as np
from sklearn.ensemble import GradientBoostingClassifier, GradientBoostingRegressor
from sklearn.linear_model import LogisticRegression, Ridge
from sklearn.metrics import log_loss, mean_absolute_error, roc_auc_score

SEED = 20260926

# Prefer the more interpretable linear model unless trees are clearly better.
AUC_MARGIN_FOR_TREES = 0.01
MAE_MARGIN_FOR_TREES = 0.02


# ---------------------------------------------------------------------------
# Raw scores (log-odds for classifiers, value for regressors), computed the
# same way the app computes them, so exports can be checked for parity.
# ---------------------------------------------------------------------------

def tree_input(X: np.ndarray) -> np.ndarray:
    """sklearn trees compare float32 inputs; the app mirrors this."""
    return X.astype(np.float32)


def _gbt_tree_sum(model, X: np.ndarray) -> np.ndarray:
    Xf = tree_input(X)
    return sum(est[0].predict(Xf) for est in model.estimators_) * model.learning_rate


def gbt_init(model, X: np.ndarray) -> float:
    """The constant the boosting starts from, derived from the model's own
    output rather than private attributes."""
    total = model.decision_function(X) if hasattr(model, "decision_function") else model.predict(X)
    init = total - _gbt_tree_sum(model, X)
    if not np.allclose(init, init[0], atol=1e-6):
        raise RuntimeError("Could not derive a constant boosting init value.")
    return float(init[0])


def raw_score(model, X: np.ndarray) -> np.ndarray:
    if isinstance(model, (LogisticRegression,)):
        return model.decision_function(X)
    if isinstance(model, GradientBoostingClassifier):
        return model.decision_function(X)
    return model.predict(X)


# ---------------------------------------------------------------------------
# Risk (classification)
# ---------------------------------------------------------------------------

def fit_risk_candidates(X_train, y_train, X_val, y_val) -> list[dict]:
    candidates = []
    best_lr = None
    for C in (0.01, 0.1, 1.0, 10.0):
        m = LogisticRegression(C=C, max_iter=2000).fit(X_train, y_train)
        loss = log_loss(y_val, m.predict_proba(X_val)[:, 1])
        if best_lr is None or loss < best_lr[1]:
            best_lr = (m, loss, C)
    candidates.append({"family": "logistic", "model": best_lr[0], "params": {"C": best_lr[2]}})

    gbt = GradientBoostingClassifier(
        n_estimators=150, max_depth=3, learning_rate=0.05, subsample=0.8, random_state=SEED
    ).fit(X_train, y_train)
    candidates.append(
        {"family": "gbt_classifier", "model": gbt,
         "params": {"n_estimators": 150, "max_depth": 3, "learning_rate": 0.05}}
    )

    for c in candidates:
        c["validation_auc"] = float(roc_auc_score(y_val, raw_score(c["model"], X_val)))
    return candidates


def choose_risk(candidates: list[dict]) -> tuple[dict, str]:
    lr = next(c for c in candidates if c["family"] == "logistic")
    gbt = next(c for c in candidates if c["family"] == "gbt_classifier")
    if gbt["validation_auc"] > lr["validation_auc"] + AUC_MARGIN_FOR_TREES:
        return gbt, (
            f"Gradient-boosted trees chosen: validation AUC {gbt['validation_auc']:.3f} vs "
            f"{lr['validation_auc']:.3f} for logistic regression (margin > {AUC_MARGIN_FOR_TREES})."
        )
    return lr, (
        f"Logistic regression chosen for interpretability: validation AUC {lr['validation_auc']:.3f} vs "
        f"{gbt['validation_auc']:.3f} for gradient-boosted trees (trees need a margin > {AUC_MARGIN_FOR_TREES})."
    )


def fit_platt(scores: np.ndarray, y: np.ndarray) -> tuple[float, float]:
    """p = sigmoid(a * score + b), fitted on validation rows."""
    m = LogisticRegression(C=1e6, max_iter=2000).fit(scores.reshape(-1, 1), y)
    return float(m.coef_[0, 0]), float(m.intercept_[0])


def sigmoid(z):
    return 1.0 / (1.0 + np.exp(-z))


def choose_bands(p_val: np.ndarray, y_val: np.ndarray, base_rate: float) -> dict:
    """'Elevated' threshold maximises F1 on validation rows; 'moderate'
    starts at the base rate (the average risk)."""
    best_t, best_f1 = 0.5, -1.0
    for t in np.unique(np.round(p_val, 3)):
        pred = p_val >= t
        tp = float(np.sum(pred & (y_val == 1)))
        fp = float(np.sum(pred & (y_val == 0)))
        fn = float(np.sum(~pred & (y_val == 1)))
        f1 = 2 * tp / (2 * tp + fp + fn) if tp else 0.0
        if f1 > best_f1:
            best_t, best_f1 = float(t), f1
    moderate = min(base_rate, best_t)
    return {"elevated": round(best_t, 4), "moderate": round(moderate, 4)}


# ---------------------------------------------------------------------------
# Forecast (regression)
# ---------------------------------------------------------------------------

def fit_forecast_candidates(X_train, y_train, X_val, y_val) -> list[dict]:
    best = None
    for alpha in (0.1, 1.0, 10.0, 100.0):
        m = Ridge(alpha=alpha).fit(X_train, y_train)
        mae = mean_absolute_error(y_val, m.predict(X_val))
        if best is None or mae < best[1]:
            best = (m, mae, alpha)
    candidates = [{"family": "ridge", "model": best[0], "params": {"alpha": best[2]}}]
    gbt = GradientBoostingRegressor(
        n_estimators=200, max_depth=3, learning_rate=0.05, subsample=0.8, random_state=SEED
    ).fit(X_train, y_train)
    candidates.append(
        {"family": "gbt_regressor", "model": gbt,
         "params": {"n_estimators": 200, "max_depth": 3, "learning_rate": 0.05}}
    )
    for c in candidates:
        c["validation_mae"] = float(mean_absolute_error(y_val, c["model"].predict(X_val)))
    return candidates


def choose_forecast(candidates: list[dict]) -> tuple[dict, str]:
    ridge = next(c for c in candidates if c["family"] == "ridge")
    gbt = next(c for c in candidates if c["family"] == "gbt_regressor")
    if gbt["validation_mae"] < ridge["validation_mae"] - MAE_MARGIN_FOR_TREES:
        return gbt, (
            f"Gradient-boosted trees chosen: validation MAE {gbt['validation_mae']:.3f} vs "
            f"{ridge['validation_mae']:.3f} for ridge regression."
        )
    return ridge, (
        f"Ridge regression chosen for interpretability: validation MAE {ridge['validation_mae']:.3f} vs "
        f"{gbt['validation_mae']:.3f} for gradient-boosted trees (trees need a margin > {MAE_MARGIN_FOR_TREES})."
    )


def conformal_half_width(residuals: np.ndarray, level: float) -> float:
    """Split-conformal interval: the finite-sample-corrected quantile of
    absolute validation residuals."""
    ordered = np.sort(np.abs(residuals))
    k = int(np.ceil((len(ordered) + 1) * level))  # k-th smallest, 1-based
    return float(ordered[min(k, len(ordered)) - 1])


def new_estimator(family: str, params: dict):
    """A fresh, unfitted estimator matching a chosen candidate."""
    if family == "logistic":
        return LogisticRegression(C=params["C"], max_iter=2000)
    if family == "ridge":
        return Ridge(alpha=params["alpha"])
    cls = GradientBoostingClassifier if family == "gbt_classifier" else GradientBoostingRegressor
    return cls(subsample=0.8, random_state=SEED, **params)


# ---------------------------------------------------------------------------
# Export
# ---------------------------------------------------------------------------

def export_model(model, family: str, X_reference: np.ndarray) -> dict:
    if family in ("logistic", "ridge"):
        coef = np.ravel(model.coef_)
        intercept = float(np.ravel(model.intercept_)[0]) if np.ndim(model.intercept_) else float(model.intercept_)
        return {"intercept": intercept, "coefficients": [float(c) for c in coef]}
    return {
        "init": gbt_init(model, X_reference),
        "learningRate": float(model.learning_rate),
        "trees": [_export_tree(est[0].tree_) for est in model.estimators_],
    }


def _export_tree(tree) -> dict:
    return {
        "left": tree.children_left.tolist(),
        "right": tree.children_right.tolist(),
        "feature": tree.feature.tolist(),
        "threshold": [float(t) for t in tree.threshold],
        "value": [float(v) for v in tree.value[:, 0, 0]],
        # Training samples reaching each node; needed for exact TreeSHAP.
        "cover": [float(c) for c in tree.weighted_n_node_samples],
    }
