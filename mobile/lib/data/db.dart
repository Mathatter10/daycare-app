import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models.dart';

Future<Isar> openDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [ChildEntitySchema, AttendanceEntitySchema, ActivityEntitySchema, OutboxEntrySchema, SyncStateEntitySchema],
    directory: dir.path,
    name: 'daycare',
  );
}

/// Removes all local data, e.g. on logout so the next user of a shared
/// phone sees nothing of the previous one.
Future<void> clearDatabase(Isar isar) => isar.writeTxn(() => isar.clear());
