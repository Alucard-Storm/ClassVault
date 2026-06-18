import '../models/models.dart';

abstract class AcademicRepository {
  // Course
  Future<List<Course>> getCourses();
  Future<void> addCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);

  // Branch
  Future<List<Branch>> getBranches();
  Future<void> addBranch(Branch branch);
  Future<void> updateBranch(Branch branch);
  Future<void> deleteBranch(String id);

  // Semester
  Future<List<Semester>> getSemesters();
  Future<void> addSemester(Semester semester);
  Future<void> updateSemester(Semester semester);
  Future<void> deleteSemester(String id);

  // Section
  Future<List<Section>> getSections();
  Future<void> addSection(Section section);
  Future<void> updateSection(Section section);
  Future<void> deleteSection(String id);

  // Student
  Future<List<Student>> getStudents();
  Future<List<Student>> getStudentsBySection(String sectionId);
  Future<void> addStudent(Student student);
  Future<void> addStudentsBulk(List<Student> students);
  Future<void> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<void> promoteStudents(String sourceSectionId, String destinationSectionId);

  // Faculty
  Future<List<Faculty>> getFaculty();
  Future<void> addFaculty(Faculty faculty);
  Future<void> updateFaculty(Faculty faculty);
  Future<void> deleteFaculty(String id);

  // Subject
  Future<List<Subject>> getSubjects();
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);

  // Subject Mapping (Class Subject Mapping)
  Future<List<SubjectMapping>> getSubjectMappings();
  Future<void> addSubjectMapping(SubjectMapping mapping);
  Future<void> deleteSubjectMapping(String id);

  // Faculty Assignment
  Future<List<FacultyAssignment>> getFacultyAssignments();
  Future<void> addFacultyAssignment(FacultyAssignment assignment);
  Future<void> deleteFacultyAssignment(String id);
}
