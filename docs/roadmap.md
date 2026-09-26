# Roadmap

## Version 1 scope (attendance MVP): done

| Role | Scope |
|---|---|
| Admin | Courses, branches, semesters, sections, students, faculty, subjects, class–subject mapping, faculty assignment, promotion |
| Faculty | Assigned classes, mark and edit attendance, reports |
| Student | Attendance and attendance percentage |

This is enough for a department-level deployment, and it's the foundation for later ERP integration.
Step-by-step status is in [implementation-plan.md](implementation-plan.md).

## Academic Intelligence: built, pilot pending

The full plan and its status live on the ClassVault Notion page.

| Phase | Status |
|---|---|
| 0 Audit · 1 Data foundation · 2 Excel/CSV import · 3 Analytics | Done |
| 4 ML dataset pipeline · 5 Prediction · 6 Explainability · 7 Faculty dashboard | Done (models verified on synthetic data) |
| 8 Evaluation & pilot | Tools done; pilot pending ([pilot-plan.md](pilot-plan.md)) |

This covers the original spec's "AI-based analytics, risk prediction, trends and performance correlation" enhancements.

## Planned enhancements

**Attendance and reporting**
- QR attendance
- Offline attendance sync
- PDF reports; Excel export of reports
- Report downloads for students and faculty
- Timetable management
- Academic session management

**Integrations**
- Face recognition, RFID and biometric attendance
- Parent notifications
- Mobile push notifications
- Firebase backend ([implementation-plan.md](implementation-plan.md), Phase 6)

**Known issues**
- The admin dashboard's stat and shortcut cards overflow on phone widths, as does one header row (`admin_dashboard.dart`).
