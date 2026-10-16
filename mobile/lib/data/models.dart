import 'package:isar_community/isar.dart';

part 'models.g.dart';

/// A child the signed-in user may see (from GET /sync `children`).
@collection
class ChildEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String fullName;
  String? nickname;
  late String dateOfBirth; // yyyy-MM-dd
  String? gender;
  late String className;
  String? allergies;
  String? medicalNotes;
}

/// One attendance day per child. [key] is "childId|yyyy-MM-dd" so a local
/// check-in made offline and the server record land on the same row.
@collection
class AttendanceEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  String? serverId;

  @Index()
  late String childId;

  late String date; // yyyy-MM-dd
  late DateTime checkInAt;
  DateTime? checkOutAt;
  String? pickedUpBy;

  /// True while a local change waits in the outbox; sync won't overwrite it.
  bool pending = false;
}

@collection
class ActivityEntity {
  Id isarId = Isar.autoIncrement;

  /// Client-generated UUID, also used as the server id.
  @Index(unique: true, replace: true)
  late String id;

  @Index()
  late String childId;

  late String type; // eat | sleep | toilet | play | medical
  late DateTime startedAt;
  DateTime? endedAt;
  late String detailsJson;
  String? notes;
  String? caregiverName;

  bool pending = false;
}

/// A queued write to the API, sent in order when online.
@collection
class OutboxEntry {
  Id id = Isar.autoIncrement;

  late String kind; // see OutboxKind
  late String payload; // JSON
  late DateTime createdAt;
  int attempts = 0;

  /// Rejected by the server for good (validation, access); kept so the
  /// user can see it, never retried.
  bool failed = false;
  String? lastError;
}

/// Sync cursors; a single row with id 0.
@collection
class SyncStateEntity {
  Id id = 0;
  String? activitiesCursor;
  String? attendanceCursor;
  DateTime? lastSyncAt;
}
