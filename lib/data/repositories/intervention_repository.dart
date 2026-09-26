import '../models/models.dart';

class InterventionEntry {
  final Intervention intervention;
  final String? authorName;
  const InterventionEntry(this.intervention, this.authorName);
}

/// Faculty notes and prediction reviews. Entries are never deleted, only
/// marked done, so the record of what was considered stays intact.
abstract class InterventionRepository {
  Future<void> add(Intervention intervention);
  Future<void> update(Intervention intervention);
  Future<Intervention?> get(String id);

  /// Newest first, grouped by student.
  Future<Map<String, List<InterventionEntry>>> forStudents(List<String> studentIds);
}
