"""Loading, validating and splitting ClassVault training exports."""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import GroupShuffleSplit

SPEC_PATH = Path(__file__).resolve().parent.parent / "feature_spec.json"


@dataclass(frozen=True)
class FeatureSpec:
    feature_version: str
    label_version: str
    features: list[str]
    missing_indicator: dict[str, bool]
    meta_columns: list[str]
    label_columns: list[str]

    @property
    def columns(self) -> list[str]:
        return [*self.meta_columns, *self.features, *self.label_columns]


def load_spec(path: Path = SPEC_PATH) -> FeatureSpec:
    raw = json.loads(Path(path).read_text(encoding="utf-8"))
    return FeatureSpec(
        feature_version=raw["featureVersion"],
        label_version=raw["labelVersion"],
        features=[f["name"] for f in raw["features"]],
        missing_indicator={f["name"]: bool(f["missingIndicator"]) for f in raw["features"]},
        meta_columns=[c["name"] for c in raw["metaColumns"]],
        label_columns=[c["name"] for c in raw["labels"]],
    )


class DatasetError(ValueError):
    pass


def load_dataset(path: str | Path, spec: FeatureSpec) -> pd.DataFrame:
    """Reads an export and checks it matches the feature spec exactly."""
    df = pd.read_csv(path, dtype={"student_key": str, "data_source": str})
    if list(df.columns) != spec.columns:
        missing = [c for c in spec.columns if c not in df.columns]
        extra = [c for c in df.columns if c not in spec.columns]
        raise DatasetError(
            f"Columns do not match feature spec {spec.feature_version}. "
            f"Missing: {missing or 'none'}; unexpected: {extra or 'none'}. "
            "Export the dataset again from ClassVault."
        )
    for col in [*spec.features, *spec.label_columns]:
        df[col] = pd.to_numeric(df[col], errors="raise")
    if not set(df["label_risk"].dropna().unique()) <= {0, 1}:
        raise DatasetError("label_risk must be 0 or 1.")
    return df


def data_source(df: pd.DataFrame) -> str:
    sources = set(df["data_source"].unique())
    if sources == {"classvault"}:
        return "classvault"
    if sources == {"synthetic"}:
        return "synthetic"
    raise DatasetError(f"Mixed data sources {sorted(sources)}; train on one source at a time.")


@dataclass
class Split:
    train: pd.DataFrame
    validation: pd.DataFrame
    test: pd.DataFrame


def split_by_student(df: pd.DataFrame, seed: int = 20260926) -> Split:
    """60/20/20 split with every student's rows in exactly one part, so the
    model is never evaluated on a student it saw during training."""
    groups = df["student_key"].to_numpy()
    outer = GroupShuffleSplit(n_splits=1, test_size=0.2, random_state=seed)
    rest_idx, test_idx = next(outer.split(df, groups=groups))
    rest = df.iloc[rest_idx]
    inner = GroupShuffleSplit(n_splits=1, test_size=0.25, random_state=seed + 1)
    train_idx, val_idx = next(inner.split(rest, groups=rest["student_key"].to_numpy()))
    split = Split(rest.iloc[train_idx], rest.iloc[val_idx], df.iloc[test_idx])
    assert not (set(split.train.student_key) & set(split.test.student_key))
    assert not (set(split.train.student_key) & set(split.validation.student_key))
    return split


class Preprocessor:
    """Median imputation + missing-value indicators + standardisation, fitted
    on training rows only. Serialised into the model file so the app applies
    exactly the same transformation."""

    def __init__(self, spec: FeatureSpec):
        self.spec = spec
        self.inputs: list[dict] = []

    def fit(self, df: pd.DataFrame) -> "Preprocessor":
        self.inputs = []
        for name in self.spec.features:
            col = df[name]
            impute = float(col.median()) if col.notna().any() else 0.0
            values = col.fillna(impute).to_numpy(dtype=float)
            self.inputs.append(
                {"name": name, "source": name, "kind": "value", "impute": impute, **_scale(values)}
            )
            if self.spec.missing_indicator[name]:
                indicator = col.isna().to_numpy(dtype=float)
                self.inputs.append(
                    {"name": f"{name}__missing", "source": name, "kind": "missing", **_scale(indicator)}
                )
        return self

    def transform(self, df: pd.DataFrame) -> np.ndarray:
        columns = []
        for spec in self.inputs:
            col = df[spec["source"]]
            if spec["kind"] == "value":
                raw = col.fillna(spec["impute"]).to_numpy(dtype=float)
            else:
                raw = col.isna().to_numpy(dtype=float)
            columns.append((raw - spec["mean"]) / spec["std"])
        return np.column_stack(columns)

    @property
    def input_names(self) -> list[str]:
        return [i["name"] for i in self.inputs]


def _scale(values: np.ndarray) -> dict:
    mean = float(values.mean())
    std = float(values.std())
    return {"mean": mean, "std": std if std > 1e-12 else 1.0}
