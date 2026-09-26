# Architecture

## Technology

| Layer | Choice |
|---|---|
| App | Flutter, state with Riverpod, routing with go_router |
| Platforms | Android, Web, Windows, Linux (iOS and macOS later) |
| Storage | Local SQLite database via Drift (the web version uses `web/sqlite3.wasm` and `web/drift_worker.js`) |
| Charts | fl_chart |
| Import | `excel` and `csv` packages |
| ML training | Python: pandas, scikit-learn (`ml/`) |
| ML prediction | Pure Dart, inside the app, offline |

**Storage history.** The original specification considered two server backends: Flutter + PHP + MySQL, or Supabase. The app instead uses a local database behind repository interfaces. A Firebase implementation can replace it later without changing the screens; see [implementation-plan.md](implementation-plan.md), Phase 6.

## Project structure

```text
lib/
├── main.dart, app.dart
├── core/
│   ├── constants/          App-wide constants (attendance thresholds)
│   ├── router/             Routes and the role-based route guard (appRedirect)
│   ├── theme/              Light/dark themes and colour tokens
│   ├── utils/              Validators, ID generator, password hashing, file saving
│   └── widgets/            Shared UI: scaffold, tables, dialogs, cards, skeletons
├── data/
│   ├── database/           Drift tables, migrations (app_database.dart)
│   ├── models/             Plain data classes
│   ├── repositories/       Abstract interfaces the features depend on
│   └── services/           Drift implementations + Riverpod providers
└── features/
    ├── auth/               Login, first-run setup, change password
    ├── admin/              Academic setup, students, faculty, subjects, promotion
    ├── faculty/            Dashboard, mark/edit attendance
    ├── student/            Student dashboard
    ├── reports/            Attendance reports and defaulters
    ├── academic_import/    History Import wizard (engine/ = reader, mapper, validator)
    ├── analytics/          Academic Insights (engine/ = trends, consistency, backlogs)
    ├── prediction/         Models, predictions, explanations (engine/ = features, predictor)
    ├── intelligence/       Attention Queue, notes, reviews, readiness
    └── pilot/              Pilot evaluation (engine/ = metrics and criteria)

ml/                         Python training pipeline (see ml/README.md)
drift_schemas/              Database schema snapshots per version
test/                       Unit, widget and migration tests
docs/                       This documentation
```

Each `engine/` folder is plain Dart with no Flutter UI, so its logic is unit-tested directly.

## Key design decisions

- **Features are defined once.** `ml/feature_spec.json` lists the prediction features, and the app computes them for both the training export and live predictions. A test fails if the app and the spec disagree.
- **Python trains, the app predicts.** Model files are plain JSON (logistic/ridge coefficients or boosted trees), so predictions run offline on every platform. `test/model_parity_test.dart` checks the app reproduces scikit-learn to 1e-6, and its SHAP values match the `shap` library.
- **No leakage.** A prediction for semester *T* uses only data from semesters before *T*.
- **Decision support only.** Signals are worded neutrally, never shown to students, and never acted on automatically. Faculty can override them.
- **Auditable.** Every prediction stores its model version, feature snapshot and explanation. Models that made predictions are kept.

## Tests

```sh
flutter test                                      # app: unit, widget, migration, parity
cd ml && python -m unittest discover -s tests     # ML pipeline
```
