import 'package:drift/drift.dart';

import '../../core/utils/id_generator.dart';
import '../database/app_database.dart';
import '../models/models.dart';
import '../repositories/academic_repository.dart';
import 'user_accounts.dart';

class DriftAcademicService implements AcademicRepository {
  final AppDatabase _db;
  final UserAccounts _accounts;

  DriftAcademicService(this._db) : _accounts = UserAccounts(_db);

  // Course CRUD
  @override
  Future<List<Course>> getCourses() => _db.select(_db.courses).get();
  @override
  Future<void> addCourse(Course course) => _db.into(_db.courses).insert(course.toInsertable());
  @override
  Future<void> updateCourse(Course course) => _db.update(_db.courses).replace(course.toInsertable());
  @override
  Future<void> deleteCourse(String id) => (_db.delete(_db.courses)..where((t) => t.id.equals(id))).go();

  // Branch CRUD
  @override
  Future<List<Branch>> getBranches() => _db.select(_db.branches).get();
  @override
  Future<void> addBranch(Branch branch) => _db.into(_db.branches).insert(branch.toInsertable());
  @override
  Future<void> updateBranch(Branch branch) => _db.update(_db.branches).replace(branch.toInsertable());
  @override
  Future<void> deleteBranch(String id) => (_db.delete(_db.branches)..where((t) => t.id.equals(id))).go();

  // Semester CRUD
  @override
  Future<List<Semester>> getSemesters() => _db.select(_db.semesters).get();
  @override
  Future<void> addSemester(Semester semester) => _db.into(_db.semesters).insert(semester.toInsertable());
  @override
  Future<void> updateSemester(Semester semester) => _db.update(_db.semesters).replace(semester.toInsertable());
  @override
  Future<void> deleteSemester(String id) => (_db.delete(_db.semesters)..where((t) => t.id.equals(id))).go();

  // Section CRUD
  @override
  Future<List<Section>> getSections() => _db.select(_db.sections).get();
  @override
  Future<void> addSection(Section section) => _db.into(_db.sections).insert(section.toInsertable());
  @override
  Future<void> updateSection(Section section) => _db.update(_db.sections).replace(section.toInsertable());
  @override
  Future<void> deleteSection(String id) => (_db.delete(_db.sections)..where((t) => t.id.equals(id))).go();

  // Student CRUD
  @override
  Future<List<Student>> getStudents() => _db.select(_db.students).get();
  @override
  Future<List<Student>> getStudentsBySection(String sectionId) =>
      (_db.select(_db.students)..where((t) => t.sectionId.equals(sectionId))).get();

  @override
  Future<void> addStudent(Student student) => addStudentsBulk([student]);

  @override
  Future<void> addStudentsBulk(List<Student> students, {bool createAccounts = true}) {
    return _db.transaction(() async {
      final now = DateTime.now();
      for (final student in students) {
        await _db.into(_db.students).insert(student.toInsertable());
        await _db.into(_db.studentEnrollments).insert(
              StudentEnrollment(
                id: IdGenerator.next('enr'),
                studentId: student.id,
                sectionId: student.sectionId,
                semesterNumber: await _semesterNumberForSection(student.sectionId),
                startedAt: now,
              ).toInsertable(),
            );
        if (createAccounts) {
          await _accounts.upsertFor(
            associatedId: student.id,
            role: UserRole.student,
            name: student.name,
            loginId: student.rollNumber,
          );
        }
      }
    });
  }

  @override
  Future<void> updateStudent(Student student) {
    return _db.transaction(() async {
      final previous = await (_db.select(_db.students)..where((t) => t.id.equals(student.id)))
          .getSingleOrNull();
      await _db.update(_db.students).replace(student.toInsertable());

      // Editing the section is treated as a correction of the current
      // enrollment; moving a student forward goes through promoteStudents.
      if (previous != null && previous.sectionId != student.sectionId) {
        await (_db.update(_db.studentEnrollments)
              ..where((e) => e.studentId.equals(student.id) & e.endedAt.isNull()))
            .write(StudentEnrollmentsCompanion(
          sectionId: Value(student.sectionId),
          semesterNumber: Value(await _semesterNumberForSection(student.sectionId)),
        ));
      }

      // Keep an existing login in sync, but never create one here: students
      // imported without accounts stay without one.
      await _accounts.upsertFor(
        associatedId: student.id,
        role: UserRole.student,
        name: student.name,
        loginId: student.rollNumber,
        createIfMissing: false,
      );
    });
  }

  @override
  Future<void> deleteStudent(String id) {
    return _db.transaction(() async {
      // History tables and attendance records cascade via foreign keys.
      await (_db.delete(_db.students)..where((t) => t.id.equals(id))).go();
      await _accounts.deleteFor(id);
    });
  }

  @override
  Future<void> promoteStudents(String sourceSectionId, String destinationSectionId) {
    return _db.transaction(() async {
      final now = DateTime.now();
      final destinationSemester = await _semesterNumberForSection(destinationSectionId);
      final students = await getStudentsBySection(sourceSectionId);

      for (final student in students) {
        await (_db.update(_db.studentEnrollments)
              ..where((e) => e.studentId.equals(student.id) & e.endedAt.isNull()))
            .write(StudentEnrollmentsCompanion(endedAt: Value(now)));

        await _db.into(_db.studentEnrollments).insert(
              StudentEnrollment(
                id: IdGenerator.next('enr'),
                studentId: student.id,
                sectionId: destinationSectionId,
                semesterNumber: destinationSemester,
                startedAt: now,
              ).toInsertable(),
            );
      }

      await (_db.update(_db.students)..where((t) => t.sectionId.equals(sourceSectionId)))
          .write(StudentsCompanion(sectionId: Value(destinationSectionId)));
    });
  }

  // Faculty CRUD
  @override
  Future<List<Faculty>> getFaculty() => _db.select(_db.facultyMembers).get();

  @override
  Future<void> addFaculty(Faculty faculty) {
    return _db.transaction(() async {
      await _db.into(_db.facultyMembers).insert(faculty.toInsertable());
      await _upsertFacultyAccount(faculty);
    });
  }

  @override
  Future<void> updateFaculty(Faculty faculty) {
    return _db.transaction(() async {
      await _db.update(_db.facultyMembers).replace(faculty.toInsertable());
      await _upsertFacultyAccount(faculty);
    });
  }

  @override
  Future<void> deleteFaculty(String id) {
    return _db.transaction(() async {
      await (_db.delete(_db.facultyMembers)..where((t) => t.id.equals(id))).go();
      await _accounts.deleteFor(id);
    });
  }

  // Subject CRUD
  @override
  Future<List<Subject>> getSubjects() => _db.select(_db.subjects).get();
  @override
  Future<void> addSubject(Subject subject) => _db.into(_db.subjects).insert(subject.toInsertable());
  @override
  Future<void> updateSubject(Subject subject) => _db.update(_db.subjects).replace(subject.toInsertable());
  @override
  Future<void> deleteSubject(String id) => (_db.delete(_db.subjects)..where((t) => t.id.equals(id))).go();

  // Subject Mapping CRUD
  @override
  Future<List<SubjectMapping>> getSubjectMappings() => _db.select(_db.subjectMappings).get();
  @override
  Future<void> addSubjectMapping(SubjectMapping mapping) =>
      _db.into(_db.subjectMappings).insert(mapping.toInsertable());
  @override
  Future<void> deleteSubjectMapping(String id) =>
      (_db.delete(_db.subjectMappings)..where((t) => t.id.equals(id))).go();

  // Faculty Assignment CRUD
  @override
  Future<List<FacultyAssignment>> getFacultyAssignments() => _db.select(_db.facultyAssignments).get();
  @override
  Future<void> addFacultyAssignment(FacultyAssignment assignment) =>
      _db.into(_db.facultyAssignments).insert(assignment.toInsertable());
  @override
  Future<void> deleteFacultyAssignment(String id) =>
      (_db.delete(_db.facultyAssignments)..where((t) => t.id.equals(id))).go();

  // Helpers

  Future<void> _upsertFacultyAccount(Faculty faculty) {
    return _accounts.upsertFor(
      associatedId: faculty.id,
      role: UserRole.faculty,
      name: faculty.name,
      loginId: faculty.email,
    );
  }

  /// Semester number of the section's semester, or 0 if the section or its
  /// semester no longer exists.
  Future<int> _semesterNumberForSection(String sectionId) async {
    final query = _db.select(_db.sections).join([
      innerJoin(_db.semesters, _db.semesters.id.equalsExp(_db.sections.semesterId)),
    ])
      ..where(_db.sections.id.equals(sectionId));
    final row = await query.getSingleOrNull();
    return row?.readTable(_db.semesters).semesterNumber ?? 0;
  }
}
