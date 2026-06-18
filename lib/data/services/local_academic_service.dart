import '../models/models.dart';
import '../repositories/academic_repository.dart';

class LocalAcademicService implements AcademicRepository {
  // In-Memory Database Lists
  final List<Course> _courses = [
    Course(id: 'c_btech', name: 'B.Tech'),
    Course(id: 'c_mtech', name: 'M.Tech'),
    Course(id: 'c_bca', name: 'BCA'),
  ];

  final List<Branch> _branches = [
    Branch(id: 'b_cse', courseId: 'c_btech', name: 'CSE'),
    Branch(id: 'b_ece', courseId: 'c_btech', name: 'ECE'),
    Branch(id: 'b_it', courseId: 'c_bca', name: 'Information Technology'),
  ];

  final List<Semester> _semesters = [
    Semester(id: 'sem_cse_5', branchId: 'b_cse', semesterNumber: 5),
    Semester(id: 'sem_cse_6', branchId: 'b_cse', semesterNumber: 6),
  ];

  final List<Section> _sections = [
    Section(id: 'sec_cse_5_a', semesterId: 'sem_cse_5', name: 'Section A'),
    Section(id: 'sec_cse_6_a', semesterId: 'sem_cse_6', name: 'Section A'),
    Section(id: 'sec_cse_6_b', semesterId: 'sem_cse_6', name: 'Section B'),
  ];

  final List<Student> _students = [
    Student(id: 'stud_1', rollNumber: '101', name: 'Akshay Kumar', sectionId: 'sec_cse_6_a'),
    Student(id: 'stud_2', rollNumber: '102', name: 'Rahul Sharma', sectionId: 'sec_cse_6_a'),
    Student(id: 'stud_3', rollNumber: '103', name: 'Priya Patel', sectionId: 'sec_cse_6_a'),
    Student(id: 'stud_4', rollNumber: '104', name: 'Aman Verma', sectionId: 'sec_cse_6_a'),
    Student(id: 'stud_5', rollNumber: '201', name: 'Amit Singh', sectionId: 'sec_cse_5_a'),
    Student(id: 'stud_6', rollNumber: '202', name: 'Neha Gupta', sectionId: 'sec_cse_5_a'),
  ];

  final List<Faculty> _faculty = [
    Faculty(id: 'fac_1', employeeId: 'EMP101', name: 'Dr. Rahul Sharma', email: 'faculty@campusvault.com'),
    Faculty(id: 'fac_2', employeeId: 'EMP102', name: 'Dr. S. K. Gupta', email: 'gupta@campusvault.com'),
  ];

  final List<Subject> _subjects = [
    Subject(id: 'sub_dbms', code: 'CS601', name: 'DBMS'),
    Subject(id: 'sub_cn', code: 'CS602', name: 'CN'),
    Subject(id: 'sub_ai', code: 'CS603', name: 'AI'),
  ];

  final List<SubjectMapping> _subjectMappings = [
    SubjectMapping(id: 'map_dbms_6a', sectionId: 'sec_cse_6_a', subjectId: 'sub_dbms'),
    SubjectMapping(id: 'map_cn_6a', sectionId: 'sec_cse_6_a', subjectId: 'sub_cn'),
    SubjectMapping(id: 'map_ai_6a', sectionId: 'sec_cse_6_a', subjectId: 'sub_ai'),
    SubjectMapping(id: 'map_dbms_6b', sectionId: 'sec_cse_6_b', subjectId: 'sub_dbms'),
  ];

  final List<FacultyAssignment> _facultyAssignments = [
    FacultyAssignment(id: 'fa_dbms_6a', facultyId: 'fac_1', subjectMappingId: 'map_dbms_6a'),
    FacultyAssignment(id: 'fa_cn_6a', facultyId: 'fac_2', subjectMappingId: 'map_cn_6a'),
    FacultyAssignment(id: 'fa_ai_6a', facultyId: 'fac_1', subjectMappingId: 'map_ai_6a'),
    FacultyAssignment(id: 'fa_dbms_6b', facultyId: 'fac_2', subjectMappingId: 'map_dbms_6b'),
  ];

  // Course CRUD
  @override
  Future<List<Course>> getCourses() async => List.from(_courses);
  @override
  Future<void> addCourse(Course course) async => _courses.add(course);
  @override
  Future<void> updateCourse(Course course) async {
    final idx = _courses.indexWhere((c) => c.id == course.id);
    if (idx != -1) _courses[idx] = course;
  }
  @override
  Future<void> deleteCourse(String id) async => _courses.removeWhere((c) => c.id == id);

  // Branch CRUD
  @override
  Future<List<Branch>> getBranches() async => List.from(_branches);
  @override
  Future<void> addBranch(Branch branch) async => _branches.add(branch);
  @override
  Future<void> updateBranch(Branch branch) async {
    final idx = _branches.indexWhere((b) => b.id == branch.id);
    if (idx != -1) _branches[idx] = branch;
  }
  @override
  Future<void> deleteBranch(String id) async => _branches.removeWhere((b) => b.id == id);

  // Semester CRUD
  @override
  Future<List<Semester>> getSemesters() async => List.from(_semesters);
  @override
  Future<void> addSemester(Semester semester) async => _semesters.add(semester);
  @override
  Future<void> updateSemester(Semester semester) async {
    final idx = _semesters.indexWhere((s) => s.id == semester.id);
    if (idx != -1) _semesters[idx] = semester;
  }
  @override
  Future<void> deleteSemester(String id) async => _semesters.removeWhere((s) => s.id == id);

  // Section CRUD
  @override
  Future<List<Section>> getSections() async => List.from(_sections);
  @override
  Future<void> addSection(Section section) async => _sections.add(section);
  @override
  Future<void> updateSection(Section section) async {
    final idx = _sections.indexWhere((s) => s.id == section.id);
    if (idx != -1) _sections[idx] = section;
  }
  @override
  Future<void> deleteSection(String id) async => _sections.removeWhere((s) => s.id == id);

  // Student CRUD
  @override
  Future<List<Student>> getStudents() async => List.from(_students);
  @override
  Future<List<Student>> getStudentsBySection(String sectionId) async {
    return _students.where((s) => s.sectionId == sectionId).toList();
  }
  @override
  Future<void> addStudent(Student student) async => _students.add(student);
  @override
  Future<void> addStudentsBulk(List<Student> students) async => _students.addAll(students);
  @override
  Future<void> updateStudent(Student student) async {
    final idx = _students.indexWhere((s) => s.id == student.id);
    if (idx != -1) _students[idx] = student;
  }
  @override
  Future<void> deleteStudent(String id) async => _students.removeWhere((s) => s.id == id);

  @override
  Future<void> promoteStudents(String sourceSectionId, String destinationSectionId) async {
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].sectionId == sourceSectionId) {
        _students[i] = _students[i].copyWith(sectionId: destinationSectionId);
      }
    }
  }

  // Faculty CRUD
  @override
  Future<List<Faculty>> getFaculty() async => List.from(_faculty);
  @override
  Future<void> addFaculty(Faculty faculty) async => _faculty.add(faculty);
  @override
  Future<void> updateFaculty(Faculty faculty) async {
    final idx = _faculty.indexWhere((f) => f.id == faculty.id);
    if (idx != -1) _faculty[idx] = faculty;
  }
  @override
  Future<void> deleteFaculty(String id) async => _faculty.removeWhere((f) => f.id == id);

  // Subject CRUD
  @override
  Future<List<Subject>> getSubjects() async => List.from(_subjects);
  @override
  Future<void> addSubject(Subject subject) async => _subjects.add(subject);
  @override
  Future<void> updateSubject(Subject subject) async {
    final idx = _subjects.indexWhere((s) => s.id == subject.id);
    if (idx != -1) _subjects[idx] = subject;
  }
  @override
  Future<void> deleteSubject(String id) async => _subjects.removeWhere((s) => s.id == id);

  // Subject Mapping CRUD
  @override
  Future<List<SubjectMapping>> getSubjectMappings() async => List.from(_subjectMappings);
  @override
  Future<void> addSubjectMapping(SubjectMapping mapping) async => _subjectMappings.add(mapping);
  @override
  Future<void> deleteSubjectMapping(String id) async => _subjectMappings.removeWhere((s) => s.id == id);

  // Faculty Assignment CRUD
  @override
  Future<List<FacultyAssignment>> getFacultyAssignments() async => List.from(_facultyAssignments);
  @override
  Future<void> addFacultyAssignment(FacultyAssignment assignment) async => _facultyAssignments.add(assignment);
  @override
  Future<void> deleteFacultyAssignment(String id) async => _facultyAssignments.removeWhere((f) => f.id == id);
}
