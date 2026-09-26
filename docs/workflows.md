# Workflows

## Marking attendance (faculty)

```text
Faculty login
      ↓
My classes
      ↓
Select subject
      ↓
Create session
      ↓
Student list (everyone present by default)
      ↓
Mark absentees
      ↓
Save
```

Every lecture creates a session, for example:

```text
Session #102
DBMS · CSE-6-A
18/06/2026 · 10:00 AM – 11:00 AM
```

Faculty only mark absentees, which keeps marking fast:

```text
✓ 101 Akshay Kumar
✓ 102 Rahul Sharma
✗ 103 Priya Patel
✓ 104 Aman Verma
```

Past sessions can be edited under **Edit Attendance**.

## Semester promotion (admin)

```text
Semester 5 section  →  Promote  →  Semester 6 section
```

- **Students move to the new section**, and their current enrollment is closed.
- **History is kept:** a new enrollment record is added for the new section, so each student's path through semesters stays on record.
- **Attendance history** stays linked to the sessions where it was taken.

## Importing academic history (admin)

**History Import** takes `.xlsx` or `.csv` files, from the ClassVault template or your own spreadsheets:

1. **Upload:** the downloadable template has one sheet per record type.
2. **Map columns:** the columns are recognised automatically, including college-specific names and layouts like `Sem 1 SGPA`. Adjust any mapping that's wrong.
3. **Preview:** see the records to be imported, and every rejected row with its sheet, row number and reason.
4. **Import:** everything is saved at once or not at all. Each import can be undone later.

Students must exist in ClassVault before their history is imported. Rows for unknown roll numbers are rejected.

## Supporting students (faculty)

1. **Attention Queue:** students whose data raises a signal, most pressing first.
2. **Student page:** trends, attendance, subjects, backlogs, readiness indicators and predictions.
3. **"Why this signal?":** what the model estimated, how much each factor moved it, the data it used, and suggested next steps.
4. **Record what you did:** a note, meeting, referral or mentoring session, with an optional follow-up date.
5. **Agree or disagree** with a prediction. A disagreement stops it counting in the queue.

## Prediction models (admin)

```text
Export training CSV  →  train in ml/  →  import model files  →  review checks  →  activate
```

See [ml/README.md](../ml/README.md). Before relying on predictions, run the [pilot](pilot-plan.md).

## Reports

| Report | Shows |
|---|---|
| Student | Subject-wise and overall attendance, attendance history |
| Subject | Classes conducted, student-wise attendance, defaulters |
| Defaulters | Students below a chosen threshold (80%, 60% or 40%) |

Example student summary:

```text
DBMS    : 85%
CN      : 92%
AI      : 78%
Overall : 85%
```

## Dashboards

| Dashboard | Shows |
|---|---|
| Administrator | Totals (students, faculty, subjects), attendance statistics, defaulter count |
| Faculty | Assigned classes, lectures conducted, quick actions, the Attention Queue summary |
| Student | Overall and subject-wise attendance, recent activity |
