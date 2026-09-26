"""Command line: python -m classvault_ml train DATASET.csv --out models/"""

from __future__ import annotations

import argparse
import sys

from .data import DatasetError
from .train import train


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="classvault_ml", description="Train ClassVault prediction models.")
    sub = parser.add_subparsers(dest="command", required=True)
    t = sub.add_parser("train", help="Train risk and SGPA-forecast models from a ClassVault export.")
    t.add_argument("dataset", help="CSV exported from ClassVault (Prediction Models → Export training data).")
    t.add_argument("--out", default="models", help="Directory for model files and the report.")
    t.add_argument("--allow-synthetic", action="store_true", help="Allow synthetic data (test-only models).")
    t.add_argument("--allow-small", action="store_true", help="Train despite too little data (experiments only).")
    t.add_argument("--parity-fixture", help="Also write a fixture for the app's parity test.")
    args = parser.parse_args(argv)

    try:
        written = train(
            args.dataset,
            args.out,
            allow_synthetic=args.allow_synthetic,
            allow_small=args.allow_small,
            parity_fixture=args.parity_fixture,
        )
    except DatasetError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2
    for kind, path in written.items():
        print(f"{kind}: {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
