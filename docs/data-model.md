# Data model

All data is stored in a local SQLite database through [Drift](https://drift.simonbinder.eu/).

**Where things live**
- **Table definitions:** `lib/data/database/app_database.dart`.
- **Schema snapshots:** `drift_schemas/`, one per version.
- **Migration tests:** `test/migration_test.dart`. They check that every older version upgrades to the current one without losing data.

## Academic structure

```text
Course
 └── Branch
      └── Semester
           └── Section
                └── Students
```

Example:

```text
B.Tech
 └── CSE
      └── Semester 6
           ├── Section A
           ├── Section B
           └── Section C
```

## Core tables

| Table | Fields | Notes |
|---|---|---|
| `courses` | id, name | B.Tech, M.Tech, BCA, MCA, MBA… |
| `branches` | id, course_id, name | CSE, CSIT, AIML, CE, ME… |
| `semesters` | id, branch_id, semester_number | |
| `sections` | id, semester_id, name | A, B, C… |
| `students` | id, roll_number (unique), name, section_id | `section_id` is the *current* section |
| `faculty` | id, employee_id (unique), name, email | |
| `subjects` | id, code, name | e.g. CS601 DBMS |
| `subject_mappings` | id, section_id, subject_id | Which subjects a section takes |
| `faculty_assignments` | id, faculty_id, subject_mapping_id | Who teaches a subject in a section |
| `attendance_sessions` | id, faculty_id, subject_id, section_id, date, start_time, end_time | One per lecture |
| `attendance_records` | id, session_id, student_id, status | `present` / `absent`; one per student per session |
| `users` | uid, name, login_id (unique), role, associated_id, password_hash, password_salt, created_at | Login accounts |

Examples of the mappings:

| Class | Subject | Faculty |
|---|---|---|
| CSE-6-A | DBMS | Dr Sharma |
| CSE-6-B | DBMS | Dr Gupta |
| CSE-6-A | AI | Dr Singh |

## Academic history (schema v1)

| Table | Holds | Natural key (re-imports update, never duplicate) |
|---|---|---|
| `student_enrollments` | Each stint in a section; promotion closes one and opens the next | — |
| `school_results` | 10th / 12th / diploma percentage, board, passing year | student, level |
| `semester_results` | SGPA, percentage, CGPA snapshot, backlogs, academic year | student, semester |
| `subject_results` | Internal, practical, external, total, max marks, grade, pass/fail, attempt | student, semester, subject, attempt |
| `attendance_summaries` | Attendance per subject per semester (held, attended, %) | student, semester, subject |
| `assessments` | Quizzes, mid-terms, labs, projects: score and max score | — (identical rows are skipped) |
| `import_batches` | One per import: file, time, record count, rejected rows and warnings (v4) | — |

Every imported row points to its import batch, so an import can be undone as a unit.

## Prediction (schema v2)

| Table | Holds |
|---|---|
| `ml_models` | Imported model files (verbatim JSON), task, family, feature version, synthetic/recommended flags, active flag |
| `predictions` | Every prediction, with its model and feature versions, the target semester, probability and band (risk) or value and range (forecast), the exact feature values used, and each feature's contribution |

Models that have made predictions cannot be deleted, so every prediction stays traceable.

## Faculty interventions (schema v3)

| Table | Holds |
|---|---|
| `interventions` | Notes, meetings, referrals and mentoring (with optional follow-up date and open/done status), plus prediction reviews (agree/disagree, linked to a prediction). Never deleted |

## Schema versions

| Version | Added |
|---|---|
| 1 | Core tables and academic history |
| 2 | `ml_models`, `predictions` |
| 3 | `interventions` |
| 4 | `import_batches.rejected_rows`, `import_batches.warning_count` |

**Changing tables:**
1. Bump `schemaVersion` and add a step to `onUpgrade`.
2. Run the code generator:
   ```sh
   dart run build_runner build
   dart run drift_dev schema dump lib/data/database/app_database.dart drift_schemas/
   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
   ```
3. Extend `test/migration_test.dart` to cover the new version.

## ML features

The prediction features (version `fv1`) are defined in `ml/feature_spec.json`. See [ml/README.md](../ml/README.md).
