import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get uid => text()();
  TextColumn get name => text()();
  // Email for admin/faculty, roll number for students. Stored lowercased.
  TextColumn get loginId => text().unique()();
  TextColumn get role => text()(); // UserRole.name
  TextColumn get associatedId => text().nullable()();
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {uid};
}

// ---------------------------------------------------------------------------
// Academic structure: Course -> Branch -> Semester -> Section -> Student
// ---------------------------------------------------------------------------

@UseRowClass(Course, generateInsertable: true)
class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Branch, generateInsertable: true)
class Branches extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Semester, generateInsertable: true)
class Semesters extends Table {
  TextColumn get id => text()();
  TextColumn get branchId => text()();
  IntColumn get semesterNumber => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Section, generateInsertable: true)
class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get semesterId => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Student, generateInsertable: true)
class Students extends Table {
  TextColumn get id => text()();
  // Roll/enrollment number is the stable identity used to match imports.
  TextColumn get rollNumber => text().unique()();
  TextColumn get name => text()();
  TextColumn get sectionId => text()(); // current section
  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Faculty, generateInsertable: true)
class FacultyMembers extends Table {
  @override
  String get tableName => 'faculty';

  TextColumn get id => text()();
  TextColumn get employeeId => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Subject, generateInsertable: true)
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(SubjectMapping, generateInsertable: true)
class SubjectMappings extends Table {
  TextColumn get id => text()();
  TextColumn get sectionId => text()();
  TextColumn get subjectId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(FacultyAssignment, generateInsertable: true)
class FacultyAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get facultyId => text()();
  TextColumn get subjectMappingId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// In-app attendance
// ---------------------------------------------------------------------------

@UseRowClass(AttendanceSession, generateInsertable: true)
class AttendanceSessions extends Table {
  TextColumn get id => text()();
  TextColumn get facultyId => text()();
  TextColumn get subjectId => text()();
  TextColumn get sectionId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(AttendanceRecord, generateInsertable: true)
class AttendanceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(AttendanceSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get status => text()(); // 'present' | 'absent'

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {sessionId, studentId},
      ];
}

// ---------------------------------------------------------------------------
// Academic history (Phase 1)
// ---------------------------------------------------------------------------

@UseRowClass(StudentEnrollment, generateInsertable: true)
class StudentEnrollments extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionId => text()();
  IntColumn get semesterNumber => integer()();
  TextColumn get academicYear => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(ImportBatch, generateInsertable: true)
class ImportBatches extends Table {
  TextColumn get id => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get importedAt => dateTime()();
  TextColumn get importedBy => text().nullable()();
  IntColumn get recordCount => integer()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(SchoolResult, generateInsertable: true)
class SchoolResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get level => text()();
  TextColumn get board => text().nullable()();
  RealColumn get percentage => real()();
  IntColumn get passingYear => integer().nullable()();
  TextColumn get importBatchId => text()
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {studentId, level},
      ];
}

@UseRowClass(SemesterResult, generateInsertable: true)
class SemesterResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get semesterNumber => integer()();
  TextColumn get academicYear => text().nullable()();
  RealColumn get sgpa => real().nullable()();
  RealColumn get percentage => real().nullable()();
  RealColumn get cgpa => real().nullable()();
  IntColumn get backlogs => integer().withDefault(const Constant(0))();
  TextColumn get importBatchId => text()
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {studentId, semesterNumber},
      ];
}

@UseRowClass(SubjectResult, generateInsertable: true)
class SubjectResults extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get semesterNumber => integer()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get subjectName => text()();
  RealColumn get internalMarks => real().nullable()();
  RealColumn get practicalMarks => real().nullable()();
  RealColumn get externalMarks => real().nullable()();
  RealColumn get totalMarks => real().nullable()();
  RealColumn get maxMarks => real().nullable()();
  TextColumn get grade => text().nullable()();
  BoolColumn get passed => boolean().nullable()();
  IntColumn get attempt => integer().withDefault(const Constant(1))();
  TextColumn get importBatchId => text()
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {studentId, semesterNumber, subjectName, attempt},
      ];
}

@UseRowClass(AttendanceSummary, generateInsertable: true)
class AttendanceSummaries extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get semesterNumber => integer()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get subjectName => text()();
  IntColumn get classesHeld => integer().nullable()();
  IntColumn get classesAttended => integer().nullable()();
  RealColumn get percentage => real()();
  TextColumn get importBatchId => text()
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {studentId, semesterNumber, subjectName},
      ];
}

@UseRowClass(Assessment, generateInsertable: true)
class Assessments extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  IntColumn get semesterNumber => integer()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get subjectName => text()();
  TextColumn get assessmentType => text()();
  TextColumn get title => text().nullable()();
  RealColumn get score => real()();
  RealColumn get maxScore => real()();
  DateTimeColumn get assessedOn => dateTime().nullable()();
  TextColumn get importBatchId => text()
      .nullable()
      .references(ImportBatches, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Prediction (Phase 5) — added in schema v2
// ---------------------------------------------------------------------------

/// Model files imported from the `ml/` pipeline. At most one active model
/// per task is enforced by the service layer.
@UseRowClass(MlModelRecord, generateInsertable: true)
class MlModels extends Table {
  TextColumn get id => text()(); // modelId from the file
  TextColumn get task => text()(); // 'risk' | 'forecast'
  TextColumn get family => text()();
  TextColumn get featureVersion => text()();
  TextColumn get bundleJson => text()();
  BoolColumn get synthetic => boolean()();
  BoolColumn get recommended => boolean()();
  BoolColumn get active => boolean().withDefault(const Constant(false))();
  DateTimeColumn get importedAt => dateTime()();
  TextColumn get importedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every generated prediction, with what it was based on, so each one can
/// be audited later even after models change.
@UseRowClass(PredictionRecord, generateInsertable: true)
class Predictions extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get task => text()();
  // No foreign key: history must survive a model being removed.
  TextColumn get modelId => text()();
  TextColumn get featureVersion => text()();
  IntColumn get targetSemester => integer()();
  RealColumn get probability => real().nullable()();
  TextColumn get band => text().nullable()();
  RealColumn get value => real().nullable()();
  RealColumn get lower => real().nullable()();
  RealColumn get upper => real().nullable()();
  TextColumn get featuresJson => text()();
  TextColumn get contributionsJson => text()();
  BoolColumn get synthetic => boolean()();
  DateTimeColumn get generatedAt => dateTime()();
  TextColumn get generatedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Faculty interventions (Phase 7) — added in schema v3
// ---------------------------------------------------------------------------

@UseRowClass(Intervention, generateInsertable: true)
class Interventions extends Table {
  TextColumn get id => text()();
  TextColumn get studentId =>
      text().references(Students, #id, onDelete: KeyAction.cascade)();
  TextColumn get authorId => text()();
  TextColumn get type => text()();
  TextColumn get note => text()();
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get followUpOn => dateTime().nullable()();
  // No foreign key: reviews must survive prediction clean-up.
  TextColumn get predictionId => text().nullable()();
  TextColumn get reviewAssessment => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Users,
  Courses,
  Branches,
  Semesters,
  Sections,
  Students,
  FacultyMembers,
  Subjects,
  SubjectMappings,
  FacultyAssignments,
  AttendanceSessions,
  AttendanceRecords,
  StudentEnrollments,
  ImportBatches,
  SchoolResults,
  SemesterResults,
  SubjectResults,
  AttendanceSummaries,
  Assessments,
  MlModels,
  Predictions,
  Interventions,
])
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] (e.g. `NativeDatabase.memory()`) in tests.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  // Bump [schemaVersion] and add steps in onUpgrade for every schema change;
  // never edit an already-shipped table definition without a migration.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(mlModels);
            await m.createTable(predictions);
          }
          if (from < 3) {
            await m.createTable(interventions);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'classvault',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
