# Attendance Management System (AMS)

## Project Overview

The Attendance Management System (AMS) is a cross-platform application designed for educational institutions to manage students, faculty, subjects, classes, and attendance records efficiently.

The system will be developed using Flutter to support Android, Web, Windows, Linux, and future iOS deployments from a single codebase.

---

# Objectives

* Simplify attendance marking for faculty.
* Reduce manual paperwork.
* Provide attendance analytics and reports.
* Support multiple courses, branches, semesters, and sections.
* Enable future integration with QR codes, biometrics, and face recognition.
* Maintain scalability for institute-wide deployment.

---

# User Roles

## 1. Administrator

Responsible for system setup and management.

### Permissions

* Manage Courses
* Manage Branches
* Manage Semesters
* Manage Sections
* Manage Students
* Manage Faculty
* Manage Subjects
* Assign Subjects to Classes
* Assign Faculty to Subjects
* Generate Reports
* Manage Academic Sessions
* Promote Students to Next Semester

---

## 2. Faculty

Responsible for attendance marking and monitoring.

### Permissions

* Login
* View Assigned Classes
* Mark Attendance
* Edit Attendance
* View Attendance Reports
* Export Reports

---

## 3. Student

### Permissions

* View Attendance Percentage
* View Subject-wise Attendance
* View Attendance History
* Download Attendance Reports

---

# Academic Structure

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

---

# Module 1: Course Management

## Course

Examples:

* B.Tech
* M.Tech
* BCA
* MCA
* MBA

### Fields

* Course ID
* Course Name

---

# Module 2: Branch Management

Examples:

* CSE
* CSIT
* AIML
* CE
* ME

### Fields

* Branch ID
* Course ID
* Branch Name

---

# Module 3: Semester Management

### Fields

* Semester ID
* Branch ID
* Semester Number

---

# Module 4: Section Management

### Fields

* Section ID
* Semester ID
* Section Name

Examples:

* A
* B
* C

---

# Module 5: Student Management

## Student Information

### Fields

* Student ID
* Roll Number
* Student Name
* Section ID

### Import Features

* CSV Import
* XLSX Import
* Bulk Upload
* Duplicate Detection
* Import Preview

### Sample Format

| Roll Number | Student Name |
| ----------- | ------------ |
| 101         | Akshay Kumar |
| 102         | Rahul Sharma |
| 103         | Priya Patel  |

---

# Module 6: Faculty Management

### Fields

* Faculty ID
* Employee ID
* Faculty Name

### Features

* Add Faculty
* Edit Faculty
* Delete Faculty
* Bulk Import

---

# Module 7: Subject Management

### Fields

* Subject ID
* Subject Code
* Subject Name

Example:

| Code  | Subject |
| ----- | ------- |
| CS601 | DBMS    |
| CS602 | CN      |
| CS603 | AI      |

---

# Module 8: Class Subject Mapping

Defines which subjects belong to a particular class.

Example:

| Class   | Subject |
| ------- | ------- |
| CSE-6-A | DBMS    |
| CSE-6-A | AI      |
| CSE-6-B | DBMS    |

### Fields

* Mapping ID
* Section ID
* Subject ID

---

# Module 9: Faculty Assignment

Assign faculty to teach a specific subject in a specific class.

Example:

| Faculty   | Subject | Class   |
| --------- | ------- | ------- |
| Dr Sharma | DBMS    | CSE-6-A |
| Dr Gupta  | DBMS    | CSE-6-B |
| Dr Singh  | AI      | CSE-6-A |

### Fields

* Assignment ID
* Faculty ID
* Subject Mapping ID

---

# Module 10: Attendance Sessions

Every lecture creates a session.

### Session Fields

* Session ID
* Faculty ID
* Subject ID
* Section ID
* Date
* Start Time
* End Time

Example:

```text
Session #102

DBMS
CSE-6-A

18/06/2026
10:00 AM - 11:00 AM
```

---

# Module 11: Attendance Records

Stores attendance against a session.

### Fields

* Attendance ID
* Session ID
* Student ID
* Status

### Status Values

* Present
* Absent

---

# Faculty Attendance Workflow

```text
Faculty Login
      ↓
My Classes
      ↓
Select Subject
      ↓
Create Session
      ↓
Student List
      ↓
Mark Attendance
      ↓
Save
```

---

# Attendance UI Design

Default State:

All Students Present

Faculty only marks absentees.

Example:

```text
✓ 101 Akshay Kumar
✓ 102 Rahul Sharma
✗ 103 Priya Patel
✓ 104 Aman Verma
```

This significantly reduces attendance marking time.

---

# Reports Module

## Student Report

Displays:

* Subject-wise Attendance
* Overall Attendance
* Attendance History

Example:

```text
DBMS  : 85%
CN    : 92%
AI    : 78%

Overall : 85%
```

---

## Subject Report

Displays:

* Total Classes Conducted
* Student-wise Attendance
* Defaulter List

---

## Faculty Report

Displays:

* Classes Conducted
* Attendance Submitted
* Attendance Pending

---

## Defaulter Report

Categories:

* Below 75%
* Below 65%
* Below 50%

---

# Dashboard

## Administrator Dashboard

* Total Students
* Total Faculty
* Total Subjects
* Attendance Statistics
* Defaulter Count

## Faculty Dashboard

* Assigned Classes
* Today's Classes
* Attendance Pending
* Attendance Submitted

## Student Dashboard

* Overall Attendance
* Subject-wise Attendance
* Recent Attendance Activity

---

# Semester Promotion

At the end of a semester:

```text
Semester 5
      ↓
Promote
      ↓
Semester 6
```

Features:

* Automatic Student Promotion
* Preserve Attendance History
* Generate New Class Structure

---

# Technology Stack

## Frontend

Flutter

Targets:

* Android
* Web
* Windows
* Linux
* iOS (Future)

---

## Backend Options

### Option A

Flutter + PHP API + MySQL

### Option B

Flutter + Supabase + PostgreSQL

Recommended for Version 1:

Flutter + PHP API + MySQL

---

# Future Enhancements

## Phase 2

* QR Attendance
* Offline Attendance Sync
* PDF Reports
* Excel Export
* Timetable Management

---

## Phase 3

* Face Recognition
* RFID Integration
* Biometric Integration
* Parent Notifications
* Mobile Push Notifications

---

## Phase 4

* AI-Based Attendance Analytics
* Risk Prediction
* Student Attendance Trends
* Academic Performance Correlation

---

# Version 1 Scope (MVP)

## Admin

* Courses
* Branches
* Semesters
* Sections
* Students
* Faculty
* Subjects
* Class Subject Mapping
* Faculty Assignment

## Faculty

* View Assigned Classes
* Mark Attendance
* Edit Attendance
* Reports

## Student

* View Attendance
* View Attendance Percentage

This scope is sufficient for department-level deployment and forms a scalable foundation for future ERP integration.

