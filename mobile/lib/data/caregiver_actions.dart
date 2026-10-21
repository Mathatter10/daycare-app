import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../core/dates.dart';
import '../core/session.dart';
import 'models.dart';
import 'sync_service.dart';

/// Caregiver writes. Each one updates Isar immediately (the UI reacts at
/// once, even offline) and queues the API call in the same transaction.
class CaregiverActions {
  CaregiverActions(this._isar, this._sync, this._user);

  final Isar _isar;
  final SyncService _sync;
  final AppUser _user;
  static const _uuid = Uuid();

  Future<void> _enqueue(String kind, Map<String, dynamic> payload) async {
    if (kind == OutboxKind.putActivity || kind == OutboxKind.deleteActivity) {
      // A PUT carries the whole activity and a DELETE ends it, so an older
      // rejected write for the same activity is obsolete. Dropping it keeps
      // "Coba lagi" from replaying it over this newer state.
      await _isar.outboxEntrys
          .filter()
          .failedEqualTo(true)
          .group((q) => q.kindEqualTo(OutboxKind.putActivity).or().kindEqualTo(OutboxKind.deleteActivity))
          .payloadContains('"id":"${payload['id']}"')
          .deleteAll();
    }
    await _isar.outboxEntrys.put(
      OutboxEntry()
        ..kind = kind
        ..payload = jsonEncode(payload)
        ..createdAt = DateTime.now(),
    );
  }

  Future<void> checkIn(String childId) async {
    final now = DateTime.now();
    final key = '$childId|${dayKey(now)}';
    await _isar.writeTxn(() async {
      if (await _isar.attendanceEntitys.getByKey(key) != null) return;
      await _isar.attendanceEntitys.put(
        AttendanceEntity()
          ..key = key
          ..childId = childId
          ..date = dayKey(now)
          ..checkInAt = now
          ..pending = true,
      );
      await _enqueue(OutboxKind.checkIn, {'child_id': childId, 'at': toApiTime(now), 'local_key': key});
    });
    _sync.kick();
  }

  Future<void> checkOut(String childId, String pickedUpBy) async {
    final now = DateTime.now();
    final key = '$childId|${dayKey(now)}';
    await _isar.writeTxn(() async {
      final att = await _isar.attendanceEntitys.getByKey(key);
      if (att == null) return;
      await _isar.attendanceEntitys.put(
        att
          ..checkOutAt = now
          ..pickedUpBy = pickedUpBy
          ..pending = true,
      );
      await _enqueue(OutboxKind.checkOut, {
        'child_id': childId,
        'at': toApiTime(now),
        'picked_up_by': pickedUpBy,
        'local_key': key,
      });
    });
    _sync.kick();
  }

  /// Logs an activity and returns its id (for undo).
  Future<String> logActivity({
    required String childId,
    required String type,
    Map<String, dynamic> details = const {},
    String? notes,
  }) async {
    final a = ActivityEntity()
      ..id = _uuid.v4()
      ..childId = childId
      ..type = type
      ..startedAt = DateTime.now()
      ..detailsJson = jsonEncode(details)
      ..notes = notes
      ..caregiverName = _user.fullName
      ..pending = true;
    await _save(a);
    return a.id;
  }

  Future<void> endSleep(ActivityEntity sleep) async {
    final now = DateTime.now();
    await _save(
      sleep
        ..endedAt = now.isAfter(sleep.startedAt) ? now : sleep.startedAt
        ..pending = true,
    );
  }

  Future<void> _save(ActivityEntity a) async {
    await _isar.writeTxn(() async {
      await _isar.activityEntitys.put(a);
      await _enqueue(OutboxKind.putActivity, {
        'id': a.id,
        'body': {
          'child_id': a.childId,
          'type': a.type,
          'started_at': toApiTime(a.startedAt),
          'ended_at': a.endedAt == null ? null : toApiTime(a.endedAt!),
          'details': jsonDecode(a.detailsJson),
          'notes': a.notes ?? '',
        },
      });
    });
    _sync.kick();
  }

  /// Queues a delete. The payload keeps a copy of the activity so the outbox
  /// can show what goes and [cancelDelete] can put it back.
  Future<void> deleteActivity(String id) async {
    await _isar.writeTxn(() async {
      final a = await _isar.activityEntitys.getById(id);
      await _isar.activityEntitys.deleteById(id);
      await _enqueue(OutboxKind.deleteActivity, {'id': id, if (a != null) 'activity': activitySnapshot(a)});
    });
    _sync.kick();
  }

  /// Takes a queued (or rejected) delete back out of the outbox and shows
  /// the activity again. Returns false if it was already sent.
  Future<bool> cancelDelete(int entryId) async {
    final cancelled = await _isar.writeTxn(() async {
      final entry = await _isar.outboxEntrys.get(entryId);
      if (entry == null || entry.kind != OutboxKind.deleteActivity) return false;
      await _isar.outboxEntrys.delete(entryId);
      final p = jsonDecode(entry.payload) as Map<String, dynamic>;
      final id = p['id'] as String;
      final snapshot = p['activity'] as Map<String, dynamic>?;
      if (snapshot == null) {
        // Queued by an older app version without a copy: fetch the last 14
        // days again, which brings the activity back from the server.
        await _isar.syncStateEntitys.put(SyncStateEntity());
      } else if (await _isar.activityEntitys.getById(id) == null) {
        final queuedEdit = await _isar.outboxEntrys
            .filter()
            .kindEqualTo(OutboxKind.putActivity)
            .payloadContains('"id":"$id"')
            .count();
        await _isar.activityEntitys.put(activityFromSnapshot(id, snapshot)..pending = queuedEdit > 0);
      }
      return true;
    });
    _sync.kick();
    return cancelled;
  }

  /// Moves a captured photo into app storage and queues its upload.
  Future<void> queuePhoto({required String childId, required String capturedPath, String? activityId}) async {
    final mediaId = _uuid.v4();
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/outbox_photos');
    await dir.create(recursive: true);
    final target = '${dir.path}/$mediaId.jpg';
    await File(capturedPath).copy(target);
    await File(capturedPath).delete().catchError((_) => File(capturedPath));

    await _isar.writeTxn(
      () => _enqueue(OutboxKind.uploadPhoto, {
        'media_id': mediaId,
        'child_id': childId,
        'activity_id': activityId,
        'taken_at': toApiTime(DateTime.now()),
        'path': target,
      }),
    );
    _sync.kick();
  }
}
