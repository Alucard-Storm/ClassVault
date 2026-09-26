import 'package:classvault/data/database/app_database.dart';
import 'package:classvault/data/models/models.dart';
import 'package:classvault/data/services/drift_academic_history_service.dart';
import 'package:classvault/data/services/drift_academic_service.dart';
import 'package:classvault/data/services/drift_attendance_service.dart';
import 'package:classvault/data/services/drift_auth_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftAuthService auth;
  late DriftAcademicService academic;
  late DriftAttendanceService attendance;
  late DriftAcademicHistoryService history;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    auth = DriftAuthService(db);
    academic = DriftAcademicService(db);
    attendance = DriftAttendanceService(db);
    history = DriftAcademicHistoryService(db);

    await academic.addCourse(Course(id: 'c1', name: 'B.Tech'));
    await academic.addBranch(Branch(id: 'b1', courseId: 'c1', name: 'CSE'));
    await academic.addSemester(Semester(id: 'sem3', branchId: 'b1', semesterNumber: 3));
    await academic.addSemester(Semester(id: 'sem4', branchId: 'b1', semesterNumber: 4));
    await academic.addSection(Section(id: 'sec3', semesterId: 'sem3', name: 'A'));
    await academic.addSection(Section(id: 'sec4', semesterId: 'sem4', name: 'A'));
  });

  tearDown(() => db.close());

  group('auth', () {
    test('fresh database needs setup; first admin can log in', () async {
      expect(await auth.needsInitialSetup(), isTrue);

      await auth.createInitialAdmin(name: 'Admin', email: 'Admin@College.edu', password: 'secret123');

      expect(await auth.needsInitialSetup(), isFalse);
      final user = await auth.login('admin@college.edu', 'secret123');
      expect(user!.role, UserRole.admin);
      await expectLater(auth.login('admin@college.edu', 'wrong'), throwsException);
      await expectLater(
        auth.createInitialAdmin(name: 'X', email: 'x@y.z', password: 'secret123'),
        throwsException,
      );
    });

    test('faculty and students get accounts; deleting removes them', () async {
      await academic.addFaculty(Faculty(id: 'f1', employeeId: 'EMP1', name: 'Dr. F', email: 'f@college.edu'));
      await academic.addStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'));

      // Initial password is the login ID itself.
      final faculty = await auth.login('f@college.edu', 'f@college.edu');
      expect(faculty!.role, UserRole.faculty);
      expect(faculty.associatedId, 'f1');

      final student = await auth.login('cs001', 'CS001');
      expect(student!.role, UserRole.student);
      expect(student.associatedId, 's1');

      await academic.deleteStudent('s1');
      await expectLater(auth.login('cs001', 'CS001'), throwsException);
    });

    test('change password requires the current one and replaces it', () async {
      await academic.addStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'));
      await auth.login('CS001', 'CS001');

      await expectLater(
        auth.changePassword(currentPassword: 'wrong', newPassword: 'new-pass-1'),
        throwsException,
      );
      await auth.changePassword(currentPassword: 'CS001', newPassword: 'new-pass-1');
      await auth.logout();

      await expectLater(auth.login('CS001', 'CS001'), throwsException);
      expect((await auth.login('CS001', 'new-pass-1'))!.associatedId, 's1');

      // Editing the student later must not reset the password.
      await academic.updateStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A. Renamed', sectionId: 'sec3'));
      expect((await auth.login('CS001', 'new-pass-1'))!.name, 'A. Renamed');
    });

    test('bulk import can skip accounts, and editing does not create one', () async {
      await academic.addStudentsBulk(
        [Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3')],
        createAccounts: false,
      );
      await expectLater(auth.login('CS001', 'CS001'), throwsException);

      await academic.updateStudent(Student(id: 's1', rollNumber: 'CS001', name: 'B', sectionId: 'sec3'));
      await expectLater(auth.login('CS001', 'CS001'), throwsException);

      // Enrollment history is still recorded without an account.
      expect(await history.getEnrollmentsForStudent('s1'), hasLength(1));
    });

    test('change password fails when signed out', () async {
      await expectLater(
        auth.changePassword(currentPassword: 'x', newPassword: 'new-pass-1'),
        throwsException,
      );
    });
  });

  group('enrollment history', () {
    test('promotion closes the old enrollment and opens a new one', () async {
      await academic.addStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'));

      await academic.promoteStudents('sec3', 'sec4');

      final student = (await academic.getStudents()).single;
      expect(student.sectionId, 'sec4');

      final enrollments = await history.getEnrollmentsForStudent('s1');
      expect(enrollments, hasLength(2));
      expect(enrollments[0].semesterNumber, 3);
      expect(enrollments[0].isCurrent, isFalse);
      expect(enrollments[1].semesterNumber, 4);
      expect(enrollments[1].isCurrent, isTrue);
    });

    test('roll numbers are unique and bulk insert is atomic', () async {
      await expectLater(
        academic.addStudentsBulk([
          Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'),
          Student(id: 's2', rollNumber: 'CS001', name: 'B', sectionId: 'sec3'),
        ]),
        throwsA(anything),
      );
      expect(await academic.getStudents(), isEmpty);
    });
  });

  group('academic history', () {
    setUp(() async {
      await academic.addStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'));
    });

    test('upserts match on natural key instead of duplicating', () async {
      await history.upsertSemesterResults([
        SemesterResult(id: 'r1', studentId: 's1', semesterNumber: 1, sgpa: 7.1),
      ]);
      await history.upsertSemesterResults([
        SemesterResult(id: 'r-new', studentId: 's1', semesterNumber: 1, sgpa: 7.4),
        SemesterResult(id: 'r2', studentId: 's1', semesterNumber: 2, sgpa: 7.8),
      ]);

      final results = await history.getSemesterResults('s1');
      expect(results.map((r) => (r.semesterNumber, r.sgpa)), [(1, 7.4), (2, 7.8)]);
      expect(results.first.id, 'r1');
    });

    test('subject re-attempts are kept as separate rows', () async {
      await history.upsertSubjectResults([
        SubjectResult(id: 'a', studentId: 's1', semesterNumber: 3, subjectName: 'DBMS', passed: false),
        SubjectResult(id: 'b', studentId: 's1', semesterNumber: 3, subjectName: 'DBMS', passed: true, attempt: 2),
      ]);
      final results = await history.getSubjectResults('s1');
      expect(results.map((r) => (r.attempt, r.passed)), [(1, false), (2, true)]);
    });

    test('deleting an import batch rolls back its records', () async {
      await history.createImportBatch(
        ImportBatch(id: 'batch1', fileName: 'x.xlsx', importedAt: DateTime.now(), recordCount: 2),
      );
      await history.upsertSchoolResults([
        SchoolResult(id: 'sc1', studentId: 's1', level: '10th', percentage: 82, importBatchId: 'batch1'),
      ]);
      await history.upsertAttendanceSummaries([
        AttendanceSummary(id: 'at1', studentId: 's1', semesterNumber: 3, subjectName: 'DBMS', percentage: 91, importBatchId: 'batch1'),
      ]);
      await history.upsertSemesterResults([
        SemesterResult(id: 'manual', studentId: 's1', semesterNumber: 1, sgpa: 7.0),
      ]);

      await history.deleteImportBatch('batch1');

      final h = (await history.getStudentHistory('s1'))!;
      expect(h.schoolResults, isEmpty);
      expect(h.attendanceSummaries, isEmpty);
      expect(h.semesterResults, hasLength(1)); // not part of the batch
    });

    test('deleting a student removes their history and attendance', () async {
      await history.upsertSemesterResults([
        SemesterResult(id: 'r1', studentId: 's1', semesterNumber: 1, sgpa: 7.1),
      ]);
      await attendance.addSession(
        AttendanceSession(
          id: 'sess1', facultyId: 'f1', subjectId: 'sub1', sectionId: 'sec3',
          date: DateTime(2026, 9, 1), startTime: '10:00 AM', endTime: '11:00 AM',
        ),
        [AttendanceRecord(id: 'rec1', sessionId: 'sess1', studentId: 's1', status: 'present')],
      );

      await academic.deleteStudent('s1');

      expect(await history.getStudentHistory('s1'), isNull);
      expect(await history.getSemesterResults('s1'), isEmpty);
      expect(await attendance.getAllAttendanceRecords(), isEmpty);
    });
  });

  test('re-marking attendance replaces the existing record', () async {
    await academic.addStudent(Student(id: 's1', rollNumber: 'CS001', name: 'A', sectionId: 'sec3'));
    await attendance.addSession(
      AttendanceSession(
        id: 'sess1', facultyId: 'f1', subjectId: 'sub1', sectionId: 'sec3',
        date: DateTime(2026, 9, 1), startTime: '10:00 AM', endTime: '11:00 AM',
      ),
      [AttendanceRecord(id: 'rec1', sessionId: 'sess1', studentId: 's1', status: 'present')],
    );

    await attendance.updateAttendanceRecords([
      AttendanceRecord(id: 'other-id', sessionId: 'sess1', studentId: 's1', status: 'absent'),
    ]);

    final records = await attendance.getAttendanceRecords('sess1');
    expect(records.single.status, 'absent');
  });
}
