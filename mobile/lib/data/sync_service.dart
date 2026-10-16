import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';

import '../core/api_client.dart';
import 'models.dart';

/// Outbox entry kinds.
abstract final class OutboxKind {
  static const checkIn = 'checkIn';
  static const checkOut = 'checkOut';
  static const putActivity = 'putActivity';
  static const deleteActivity = 'deleteActivity';
  static const uploadPhoto = 'uploadPhoto';
}

class SyncStatus {
  const SyncStatus({this.syncing = false, this.offline = false, this.lastSyncAt, this.error});

  final bool syncing;
  final bool offline;
  final DateTime? lastSyncAt;
  final String? error;
}

/// Offline-first sync (docs/API.md "Sinkronisasi offline-first"):
///  1. send queued writes in order (all endpoints are idempotent),
///  2. pull changes with /sync cursors and upsert them into Isar.
class SyncService {
  SyncService(this._isar, this._api, this._onStatus);

  final Isar _isar;
  final ApiClient _api;
  final void Function(SyncStatus) _onStatus;

  Future<void>? _running;
  bool _again = false;
  Timer? _debounce;
  DateTime? _lastSyncAt;

  /// Runs a sync. A call made while one is running schedules exactly one
  /// more run afterwards, so writes queued mid-sync are not left waiting.
  Future<void> syncNow() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = () async {
      do {
        _again = false;
        await _run();
      } while (_again);
    }().whenComplete(() => _running = null);
  }

  /// Schedules a sync shortly after a local write (coalesces bursts).
  void kick() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), syncNow);
  }

  /// Queues every write the server rejected once more ("Coba lagi"), e.g.
  /// after an admin fixed the cause, in their original order.
  Future<void> retryFailed() async {
    await _isar.writeTxn(() async {
      final failed = await _isar.outboxEntrys.filter().failedEqualTo(true).findAll();
      await _isar.outboxEntrys.putAll([for (final e in failed) e..failed = false]);
    });
    await syncNow();
  }

  void dispose() => _debounce?.cancel();

  Future<void> _run() async {
    _onStatus(SyncStatus(syncing: true, lastSyncAt: _lastSyncAt));
    try {
      await _pushOutbox();
      await _pull();
      _lastSyncAt = DateTime.now();
      _onStatus(SyncStatus(lastSyncAt: _lastSyncAt));
    } on ApiException catch (e) {
      _onStatus(SyncStatus(offline: e.isNetwork, lastSyncAt: _lastSyncAt, error: e.isNetwork ? null : e.message));
    } catch (e) {
      _onStatus(SyncStatus(lastSyncAt: _lastSyncAt, error: e.toString()));
    }
  }

  // --- push -----------------------------------------------------------------

  /// Sends entries oldest first. Attendance and activity entries stop the
  /// run on a temporary error, keeping their order. Photos are independent:
  /// a photo the server can't take right now (busy, storage not set up) is
  /// skipped so it never holds back check-ins or activities.
  Future<void> _pushOutbox() async {
    final entries = await _isar.outboxEntrys.where().filter().failedEqualTo(false).findAll();
    var photosBlocked = false;
    for (final entry in entries) {
      final isPhoto = entry.kind == OutboxKind.uploadPhoto;
      if (isPhoto && photosBlocked) continue;
      final payload = jsonDecode(entry.payload) as Map<String, dynamic>;
      try {
        await _send(entry.kind, payload);
        await _isar.writeTxn(() async {
          await _isar.outboxEntrys.delete(entry.id);
          await _markSynced(entry.kind, payload);
        });
      } on ApiException catch (e) {
        if (e.isRetryable) {
          if (isPhoto && !e.isNetwork) {
            photosBlocked = true;
            continue;
          }
          rethrow; // stop; try again on the next sync
        }
        await _isar.writeTxn(() async {
          if (_isHarmless(entry.kind, e)) {
            await _isar.outboxEntrys.delete(entry.id);
            await _markSynced(entry.kind, payload);
          } else {
            entry
              ..failed = true
              ..attempts += 1
              ..lastError = e.message;
            await _isar.outboxEntrys.put(entry);
          }
        });
      }
    }
  }

  Future<void> _send(String kind, Map<String, dynamic> p) async {
    switch (kind) {
      case OutboxKind.checkIn:
        await _api.checkIn(p);
      case OutboxKind.checkOut:
        await _api.checkOut(p);
      case OutboxKind.putActivity:
        await _api.putActivity(p['id'] as String, p['body'] as Map<String, dynamic>);
      case OutboxKind.deleteActivity:
        await _api.deleteActivity(p['id'] as String);
      case OutboxKind.uploadPhoto:
        final path = p['path'] as String;
        if (!File(path).existsSync()) return; // nothing left to send
        await _api.uploadPhoto(
          mediaId: p['media_id'] as String,
          childId: p['child_id'] as String,
          path: path,
          takenAt: p['taken_at'] as String,
          activityId: p['activity_id'] as String?,
        );
        await File(path).delete();
    }
  }

  /// A 409 for an activity that someone already deleted needs no retry.
  bool _isHarmless(String kind, ApiException e) =>
      kind == OutboxKind.putActivity && e.status == 409 && e.message == 'activity was deleted';

  Future<void> _markSynced(String kind, Map<String, dynamic> p) async {
    switch (kind) {
      case OutboxKind.putActivity:
        final id = p['id'] as String;
        if (await _isar.outboxEntrys.filter().payloadContains(id).count() > 0) return; // newer edit queued
        final a = await _isar.activityEntitys.getById(id);
        if (a != null) await _isar.activityEntitys.put(a..pending = false);
      case OutboxKind.checkIn:
      case OutboxKind.checkOut:
        final key = p['local_key'] as String?;
        if (key == null) return;
        if (await _isar.outboxEntrys.filter().payloadContains(key).count() > 0) return;
        final att = await _isar.attendanceEntitys.getByKey(key);
        if (att != null) await _isar.attendanceEntitys.put(att..pending = false);
    }
  }

  // --- pull -----------------------------------------------------------------

  Future<void> _pull() async {
    final state = await _isar.syncStateEntitys.get(0) ?? SyncStateEntity();
    var more = true;
    while (more) {
      final res = await _api.sync(activitiesCursor: state.activitiesCursor, attendanceCursor: state.attendanceCursor);
      if (await _hasNewChild(state, res)) {
        // A child just became visible (new class, newly linked parent). Its
        // history is older than our cursors, so start over from the last
        // 14 days; upserts make the repeat harmless.
        state
          ..activitiesCursor = null
          ..attendanceCursor = null;
        continue;
      }
      final activities = res['activities'] as Map<String, dynamic>;
      final attendance = res['attendance'] as Map<String, dynamic>;

      await _isar.writeTxn(() async {
        await _applyChildren((res['children'] as List).cast<Map<String, dynamic>>());
        await _applyActivities((activities['items'] as List).cast<Map<String, dynamic>>());
        await _applyAttendance((attendance['items'] as List).cast<Map<String, dynamic>>());
        state
          ..activitiesCursor = activities['next_cursor'] as String?
          ..attendanceCursor = attendance['next_cursor'] as String?
          ..lastSyncAt = DateTime.now();
        await _isar.syncStateEntitys.put(state);
      });
      more = activities['has_more'] == true || attendance['has_more'] == true;
    }
  }

  Future<bool> _hasNewChild(SyncStateEntity state, Map<String, dynamic> res) async {
    if (state.activitiesCursor == null && state.attendanceCursor == null) return false;
    final known = (await _isar.childEntitys.where().findAll()).map((c) => c.id).toSet();
    return (res['children'] as List).any((c) => !known.contains((c as Map<String, dynamic>)['id']));
  }

  /// The server sends the complete list; anything else is no longer
  /// visible to this user (moved class, deactivated) and is removed.
  Future<void> _applyChildren(List<Map<String, dynamic>> items) async {
    final ids = items.map((c) => c['id'] as String).toSet();
    final stale = (await _isar.childEntitys.where().findAll()).where((c) => !ids.contains(c.id)).map((c) => c.id);
    for (final id in stale) {
      await _isar.activityEntitys.filter().childIdEqualTo(id).deleteAll();
      await _isar.attendanceEntitys.filter().childIdEqualTo(id).deleteAll();
    }
    await _isar.childEntitys.deleteAllById(stale.toList());
    await _isar.childEntitys.putAll([
      for (final c in items)
        ChildEntity()
          ..id = c['id'] as String
          ..fullName = c['full_name'] as String
          ..nickname = c['nickname'] as String?
          ..dateOfBirth = c['date_of_birth'] as String
          ..gender = c['gender'] as String?
          ..className = (c['class_name'] as String?) ?? ''
          ..allergies = c['allergies'] as String?
          ..medicalNotes = c['medical_notes'] as String?,
    ]);
  }

  Future<void> _applyActivities(List<Map<String, dynamic>> items) async {
    for (final a in items) {
      final id = a['id'] as String;
      final local = await _isar.activityEntitys.getById(id);
      if (local != null && local.pending) continue; // local edit not sent yet
      if (a['deleted_at'] != null) {
        await _isar.activityEntitys.deleteById(id);
        continue;
      }
      await _isar.activityEntitys.put(
        ActivityEntity()
          ..id = id
          ..childId = a['child_id'] as String
          ..type = a['type'] as String
          ..startedAt = DateTime.parse(a['started_at'] as String).toLocal()
          ..endedAt = a['ended_at'] == null ? null : DateTime.parse(a['ended_at'] as String).toLocal()
          ..detailsJson = jsonEncode(a['details'] ?? const {})
          ..notes = a['notes'] as String?
          ..caregiverName = a['caregiver_name'] as String?,
      );
    }
  }

  Future<void> _applyAttendance(List<Map<String, dynamic>> items) async {
    for (final a in items) {
      final key = '${a['child_id']}|${a['date']}';
      final local = await _isar.attendanceEntitys.getByKey(key);
      if (local != null && local.pending) continue;
      await _isar.attendanceEntitys.put(
        AttendanceEntity()
          ..key = key
          ..serverId = a['id'] as String
          ..childId = a['child_id'] as String
          ..date = a['date'] as String
          ..checkInAt = DateTime.parse(a['check_in_at'] as String).toLocal()
          ..checkOutAt = a['check_out_at'] == null ? null : DateTime.parse(a['check_out_at'] as String).toLocal()
          ..pickedUpBy = a['picked_up_by'] as String?,
      );
    }
  }
}
