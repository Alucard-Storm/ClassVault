# ClassVault

ClassVault is a cross-platform academic management app for colleges. It handles attendance
day to day, and turns students' academic history into analytics and explainable decision
support, so faculty can see where additional support may help.

Built with Flutter for Android, Web, Windows and Linux. Data is stored locally, and
predictions run inside the app, offline.

> Predictions are decision-support signals for faculty, not labels or automatic decisions.
> Students never see them.

## Features

### Academic management
- Courses, branches, semesters and sections
- Students, faculty and subjects; subject-to-section mapping; faculty assignments
- Bulk student import from CSV, with duplicate detection, a preview, and optional login accounts
- Semester promotion that keeps each student's enrollment history
- Role-based access for administrators, faculty and students

### Attendance
- Lecture sessions; everyone starts present and faculty mark absentees
- Edit past sessions
- Student, subject and defaulter reports with adjustable thresholds
- Dashboards for each role

### Academic history import
- Import results, subject marks, attendance and assessments from `.xlsx` or `.csv`
- Columns detected automatically, including college-specific names and "Sem 1 SGPA"-style layouts
- Validation and preview before anything is saved; imports are atomic and can be undone
- Downloadable template

### Academic Insights
- Class overview: SGPA and attendance trends, consistency, backlogs, class trend chart
- Student profile: timeline charts, subject strengths, backlog history, trends within a subject
- Neutral "attention" and "monitor" signals, each with its reason
- Rule-based project-readiness indicators with every criterion shown

### Predictions and explanations
- Academic risk signal (low / moderate / elevated) and an expected SGPA range for the current semester
- Models trained in Python ([ml/](ml/README.md)), imported as versioned files, evaluated against baselines
- "Why this signal?" page:
  - the contribution of each factor (exact SHAP values)
  - the data used and the model card
  - a warning when the data has changed since the prediction
  - suggested next steps
- Every prediction is stored with its model version and inputs, for audit

### Faculty support
- Attention Queue across a faculty member's sections, most pressing first
- Notes, meetings, referrals and mentoring with follow-up dates
- Agree or disagree with a prediction; a disagreement overrides it in the queue

### Pilot evaluation
- Compares predictions with real outcomes: precision, recall, calibration, misses and false alarms
- Stability across sections, how faculty used the signals, and data-quality failures
- Pass/fail criteria, a verdict, and an exportable report

## Getting started

```sh
flutter pub get
flutter run -d windows        # or chrome, linux, android
```

- **First launch:** you'll be asked to create the administrator account.
- **Faculty log in** with their email, and **students** with their roll number. The initial password is the same as the login ID, and can be changed from the account menu.
- **Example data:** History Import → *Download Template* gives an example workbook.
- **Prediction models** (optional) are trained with the Python pipeline in `ml/`; see [ml/README.md](ml/README.md).

## Tests

```sh
flutter test
cd ml && python -m unittest discover -s tests
```

## Documentation

See [docs/](docs/README.md) for:
- roles and permissions
- the data model
- workflows
- architecture
- the roadmap
- the implementation plan
- the pilot plan
