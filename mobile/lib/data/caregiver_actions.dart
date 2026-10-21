import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  CaregiverActions(this._isar, this._sync, this._user, {Future<Directory> Function()? photoDir})
    : _photoDir = photoDir ?? _defaultPhotoDir;

  final Isar _isar;
  final SyncService _sync;
  final AppUser _user;
  final Future<Directory> Function() _photoDir;

  /// Queued photos live here until sent (survives restarts, unlike cache).
  static Future<Directory> _defaultPhotoDir() async =>
      Directory('${(await getApplicationDocumentsDirectory()).path}/outbox_photos');
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

  /// Logs the same activity for several children at once ("aktivitas
  /// bersama"). The API stores one activity per child, so each gets its own
  /// id. Returns child id → activity id.
  Future<Map<String, String>> logGroupActivity({
    required Iterable<String> childIds,
    required String type,
    Map<String, dynamic> details = const {},
  }) async {
    final now = DateTime.now();
    final ids = <String, String>{};
    await _isar.writeTxn(() async {
      for (final childId in childIds) {
        final a = ActivityEntity()
          ..id = _uuid.v4()
          ..childId = childId
          ..type = type
          ..startedAt = now
          ..detailsJson = jsonEncode(details)
          ..caregiverName = _user.fullName
          ..pending = true;
        await _putActivity(a);
        ids[childId] = a.id;
      }
    });
    _sync.kick();
    return ids;
  }

  /// Undoes a [logGroupActivity]: deletes its activities and drops their
  /// photos that have not been sent yet.
  Future<void> undoGroup(Iterable<String> activityIds) async {
    await _isar.writeTxn(() async {
      for (final id in activityIds) {
        await _deleteActivity(id);
        final photos = await _isar.outboxEntrys
            .filter()
            .kindEqualTo(OutboxKind.uploadPhoto)
            .payloadContains('"activity_id":"$id"')
            .findAll();
        for (final p in photos) {
          final path = (jsonDecode(p.payload) as Map<String, dynamic>)['path'] as String;
          await File(path).delete().catchError((_) => File(path));
          await _isar.outboxEntrys.delete(p.id);
        }
      }
    });
    _sync.kick();
  }

  Future<void> _save(ActivityEntity a) async {
    await _isar.writeTxn(() => _putActivity(a));
    _sync.kick();
  }

  /// Stores [a] and queues its PUT; call inside a write transaction.
  Future<void> _putActivity(ActivityEntity a) async {
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
  }

  /// Queues a delete. The payload keeps a copy of the activity so the outbox
  /// can show what goes and [cancelDelete] can put it back.
  Future<void> deleteActivity(String id) async {
    await _isar.writeTxn(() => _deleteActivity(id));
    _sync.kick();
  }

  Future<void> _deleteActivity(String id) async {
    final a = await _isar.activityEntitys.getById(id);
    await _isar.activityEntitys.deleteById(id);
    await _enqueue(OutboxKind.deleteActivity, {'id': id, if (a != null) 'activity': activitySnapshot(a)});
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

  /// Queues photos (camera or gallery) for one or more children; [targets]
  /// maps child id → activity id to link the photo to, or null. A photo
  /// belongs to one child on the server, so a group photo is sent once per
  /// child. Each file is first shrunk on the phone to the size the server
  /// keeps (1600 px), which saves mobile data and turns HEIC into JPEG.
  Future<void> queuePhotos({required List<String> paths, required Map<String, String?> targets}) async {
    if (paths.isEmpty || targets.isEmpty) return;
    final dir = await _photoDir();
    await dir.create(recursive: true);
    final takenAt = toApiTime(DateTime.now());
    final entries = <Map<String, dynamic>>[];
    for (final source in paths) {
      final shrunk = await _shrink(source, '${dir.path}/${_uuid.v4()}.jpg');
      for (final t in targets.entries) {
        final mediaId = _uuid.v4();
        final target = '${dir.path}/$mediaId.jpg';
        await File(shrunk).copy(target);
        entries.add({
          'media_id': mediaId,
          'child_id': t.key,
          'activity_id': t.value,
          'taken_at': takenAt,
          'path': target,
        });
      }
      await File(shrunk).delete();
      if (shrunk != source) await File(source).delete().catchError((_) => File(source));
    }
    await _isar.writeTxn(() async {
      for (final e in entries) {
        await _enqueue(OutboxKind.uploadPhoto, e);
      }
    });
    _sync.kick();
  }

  Future<void> queuePhoto({required String childId, required String capturedPath, String? activityId}) =>
      queuePhotos(paths: [capturedPath], targets: {childId: activityId});

  /// JPEG of at most ~1600 px at [target]; the original if that fails (the
  /// server resizes anyway).
  Future<String> _shrink(String source, String target) async {
    try {
      final out = await FlutterImageCompress.compressAndGetFile(
        source,
        target,
        minWidth: 1600,
        minHeight: 1600,
        quality: 85,
        keepExif: false,
      );
      if (out != null) return out.path;
    } catch (_) {}
    return source;
  }
}
