# Roles and permissions

ClassVault has three roles. Access is enforced by the router (`appRedirect` in
`lib/core/router/app_router.dart`) and by each service, not only by hiding menu items.

Items marked *(planned)* are part of the original specification but are not built yet.

## Administrator

System setup and management.

**Academic setup**
- Manage courses, branches, semesters and sections
- Manage subjects and map them to sections
- Manage faculty and assign them to subjects in sections
- Manage students: add one at a time, or bulk-import from CSV (optionally creating login accounts)
- Promote students to the next semester, which keeps their enrollment history
- Manage academic sessions *(planned)*

**Academic intelligence**
- Import academic history: results, marks, attendance and assessments (History Import)
- Export training data, import prediction models, review their evaluation and activate them (Prediction Models)
- Run the pilot evaluation and export its report (Pilot Evaluation)
- Everything faculty can do below, for **every** section

**Reports**
- Attendance analytics and defaulter reports

## Faculty

Attendance marking and student support, **limited to the sections they are assigned to**.

**Attendance**
- View assigned classes
- Mark attendance (everyone starts present; mark absentees)
- Edit past attendance
- View attendance reports
- Export reports *(planned)*

**Academic intelligence**
- Academic Insights: class overview, trends, signals and each student's profile
- Generate predictions for their sections and read the "Why this signal?" explanations
- Agree or disagree with a prediction (a disagreement overrides it in the queue)
- Attention Queue: students to review, with notes, meetings, referrals and follow-ups

## Student

- View overall and subject-wise attendance percentage
- View attendance history
- Download attendance reports *(planned)*

Students **cannot** see academic insights, signals, predictions, readiness indicators or faculty
notes. The router redirects them away from `/analytics`.

## Accounts and passwords

- **First run:** there are no accounts, and the login screen asks for the first administrator.
- **Login IDs:** faculty sign in with their email, students with their roll number.
- **Initial password:** the same as the login ID. Everyone can change it from the account menu.
- **Storage:** passwords are stored as salted, iterated SHA-256 hashes.
