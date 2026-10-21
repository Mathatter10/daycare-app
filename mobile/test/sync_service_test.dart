import 'dart:convert';
import 'dart:io';

import 'package:daycare_app/core/api_client.dart';
import 'package:daycare_app/core/session.dart';
import 'package:daycare_app/data/caregiver_actions.dart';
import 'package:daycare_app/data/models.dart';
import 'package:daycare_app/data/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

/// Records calls; [failWith] makes an endpoint throw.
class FakeApi extends ApiClient {
  FakeApi() : super(store: AuthStore(), onSessionExpired: () {});

  final calls = <String>[];
  final syncCursors = <String?>[];
  final failWith = <String, ApiException>{};
  Map<String, dynamic> syncResponse = _syncBody(children: []);

  Future<Map<String, dynamic>> _record(String name) async {
    calls.add(name);
    final err = failWith[name];
    if (err != null) throw err;
    return {};
  }

  @override
  Future<Map<String, dynamic>> checkIn(Map<String, dynamic> body) => _record('checkIn');
  @override
  Future<Map<String, dynamic>> checkOut(Map<String, dynamic> body) => _record('checkOut');
  @override
  Future<Map<String, dynamic>> putActivity(String id, Map<String, dynamic> body) => _record('putActivity');
  @override
  Future<void> deleteActivity(String id) => _record('deleteActivity');
  @override
  Future<Map<String, dynamic>> uploadPhoto({
    required String mediaId,
    required String childId,
    required String path,
    required String takenAt,
    String? activityId,
  }) => _record('uploadPhoto');
  @override
  Future<Map<String, dynamic>> sync({String? activitiesCursor, String? attendanceCursor}) async {
    calls.add('sync');
    syncCursors.add(activitiesCursor);
    final err = failWith['sync'];
    if (err != null) throw err;
    return syncResponse;
  }
}

/// Sync without the debounce timer, so tests control when it runs.
class TestSync extends SyncService {
  TestSync(super.isar, super.api, super.onStatus);
  @override
  void kick() {}
}

Map<String, dynamic> _child(String id) => {
  'id': id,
  'full_name': 'Anak $id',
  'nickname': null,
  'date_of_birth': '2024-01-01',
  'gender': null,
  'class_name': 'Kelas X',
  'allergies': null,
  'medical_notes': null,
};

Map<String, dynamic> _syncBody({
  required List<Map<String, dynamic>> children,
  List<Map<String, dynamic>> activities = const [],
}) => {
  'children': children,
  'activities': {'items': activities, 'next_cursor': 'a1', 'has_more': false},
  'attendance': {'items': <Map<String, dynamic>>[], 'next_cursor': 'b1', 'has_more': false},
};

void main() {
  late Isar isar;
  late FakeApi api;
  late TestSync sync;
  late CaregiverActions actions;
  final statuses = <SyncStatus>[];
  const user = AppUser(id: 'u1', email: 'ani@d.id', fullName: 'Ani', role: Role.caregiver);

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    final dir = Directory.systemTemp.createTempSync('isar_test');
    isar = await Isar.open(
      [ChildEntitySchema, AttendanceEntitySchema, ActivityEntitySchema, OutboxEntrySchema, SyncStateEntitySchema],
      directory: dir.path,
      name: 'test${DateTime.now().microsecondsSinceEpoch}',
    );
    api = FakeApi()..syncResponse = _syncBody(children: [_child('c1')]);
    statuses.clear();
    sync = TestSync(isar, api, statuses.add);
    final photoDir = Directory.systemTemp.createTempSync('outbox_photos');
    actions = CaregiverActions(isar, sync, user, photoDir: () async => photoDir);
  });

  tearDown(() => isar.close(deleteFromDisk: true));

  Future<int> outboxCount({bool failed = false}) => isar.outboxEntrys.filter().failedEqualTo(failed).count();

  test('sends queued writes in order, then pulls, and clears pending flags', () async {
    await actions.checkIn('c1');
    final id = await actions.logActivity(childId: 'c1', type: 'eat', details: {'portion': 'half'});
    expect(await outboxCount(), 2);
    expect((await isar.activityEntitys.getById(id))!.pending, isTrue);

    await sync.syncNow();

    expect(api.calls, ['checkIn', 'putActivity', 'sync']);
    expect(await outboxCount(), 0);
    expect((await isar.activityEntitys.getById(id))!.pending, isFalse);
    expect((await isar.attendanceEntitys.where().findFirst())!.pending, isFalse);
    expect(statuses.last.error, isNull);
    expect((await isar.syncStateEntitys.get(0))!.activitiesCursor, 'a1');
  });

  test('a photo the server cannot take yet does not hold back other writes', () async {
    final photo = File('${Directory.systemTemp.createTempSync().path}/p.jpg')..writeAsBytesSync([1, 2, 3]);
    await isar.writeTxn(
      () => isar.outboxEntrys.put(
        OutboxEntry()
          ..kind = OutboxKind.uploadPhoto
          ..payload = jsonEncode({'media_id': 'm1', 'child_id': 'c1', 'taken_at': 'x', 'path': photo.path})
          ..createdAt = DateTime.now(),
      ),
    );
    await actions.logActivity(childId: 'c1', type: 'toilet', details: {'kind': 'wet'});
    api.failWith['uploadPhoto'] = ApiException('media storage is not configured', status: 503);

    await sync.syncNow();

    expect(api.calls, ['uploadPhoto', 'putActivity', 'sync']);
    expect(await outboxCount(), 1, reason: 'photo stays queued for a later retry');
    expect(await outboxCount(failed: true), 0);
    expect(photo.existsSync(), isTrue);
  });

  test('offline: stops at the first entry and keeps the whole queue', () async {
    await actions.checkIn('c1');
    await actions.logActivity(childId: 'c1', type: 'play');
    api.failWith['checkIn'] = ApiException('offline');

    await sync.syncNow();

    expect(api.calls, ['checkIn']);
    expect(await outboxCount(), 2);
    expect(statuses.last.offline, isTrue);
  });

  test('a write the server rejects for good is parked as failed; later writes continue', () async {
    await actions.logActivity(childId: 'c1', type: 'eat', details: {'portion': 'banyak'});
    await actions.checkIn('c1');
    api.failWith['putActivity'] = ApiException('details.portion must be one of …', status: 422);

    await sync.syncNow();

    expect(api.calls, ['putActivity', 'checkIn', 'sync']);
    expect(await outboxCount(failed: true), 1);
    expect(await outboxCount(), 0);
    final failed = await isar.outboxEntrys.where().findFirst();
    expect(failed!.lastError, contains('portion'));
  });

  test('"Coba lagi" resends rejected writes once the server accepts them', () async {
    await actions.logActivity(childId: 'c1', type: 'eat', details: {'portion': 'half'});
    api.failWith['putActivity'] = ApiException('Not Found', status: 404);
    await sync.syncNow();
    expect(await outboxCount(failed: true), 1);

    api.failWith.clear();
    api.calls.clear();
    await sync.retryFailed();

    expect(api.calls, ['putActivity', 'sync']);
    expect(await outboxCount(failed: true), 0);
    expect(await outboxCount(), 0);
  });

  test('a newer edit replaces a rejected one, so a retry cannot overwrite it', () async {
    final id = await actions.logActivity(childId: 'c1', type: 'eat', details: {'portion': 'half'});
    final other = await actions.logActivity(childId: 'c1', type: 'toilet', details: {'kind': 'wet'});
    api.failWith['putActivity'] = ApiException('details.portion must be one of …', status: 422);
    await sync.syncNow();
    expect(await outboxCount(failed: true), 2);

    await actions.deleteActivity(id);

    final failed = await isar.outboxEntrys.filter().failedEqualTo(true).findAll();
    expect(failed.map((e) => e.payload), [contains(other)], reason: 'only the unrelated rejection is left');
    expect(await outboxCount(), 1, reason: 'the delete is queued');
  });

  test('a child that becomes visible gets its earlier history (cursors restart)', () async {
    await sync.syncNow(); // c1 known, cursor a1 stored
    final earlier = {
      'id': 'act-old',
      'child_id': 'c2',
      'type': 'eat',
      'started_at': '2026-10-16T02:00:00Z',
      'ended_at': null,
      'details': {'portion': 'all'},
      'notes': null,
      'caregiver_name': 'Nadia',
      'deleted_at': null,
    };
    api.syncResponse = _syncBody(children: [_child('c1'), _child('c2')], activities: [earlier]);
    api.syncCursors.clear();

    await sync.syncNow();

    expect(api.syncCursors, ['a1', null], reason: 'second request starts over without cursors');
    expect(await isar.childEntitys.getById('c2'), isNotNull);
    expect(await isar.activityEntitys.getById('act-old'), isNotNull);

    api.syncCursors.clear();
    await sync.syncNow();
    expect(api.syncCursors, ['a1'], reason: 'no restart once the child is known');
  });

  test('editing an activity someone else deleted is dropped quietly', () async {
    await actions.logActivity(childId: 'c1', type: 'play');
    api.failWith['putActivity'] = ApiException('activity was deleted', status: 409);

    await sync.syncNow();

    expect(await outboxCount(), 0);
    expect(await outboxCount(failed: true), 0);
  });

  Map<String, dynamic> serverRow(String id) => {
    'id': id,
    'child_id': 'c1',
    'type': 'play',
    'started_at': DateTime.now().toUtc().toIso8601String(),
    'ended_at': null,
    'details': {'activity': 'Mewarnai'},
    'notes': null,
    'caregiver_name': 'Nadia',
    'deleted_at': null,
  };

  test('a rejected delete keeps the activity hidden, so a later retry is no surprise', () async {
    // The 20 Oct incident: the delete was rejected, the pull brought the
    // activity back on the phone, and "Coba lagi" deleted it an hour later.
    final id = await actions.logActivity(childId: 'c1', type: 'play', details: {'activity': 'Mewarnai'});
    await sync.syncNow();
    await actions.deleteActivity(id);
    api.failWith['deleteActivity'] = ApiException('forbidden', status: 403);
    api.syncResponse = _syncBody(children: [_child('c1')], activities: [serverRow(id)]);

    await sync.syncNow();

    expect(await outboxCount(failed: true), 1);
    expect(await isar.activityEntitys.getById(id), isNull, reason: 'still marked for deletion on this phone');
  });

  test('cancelling a queued delete puts the activity back and never sends it', () async {
    final id = await actions.logActivity(childId: 'c1', type: 'play', details: {'activity': 'Mewarnai'});
    await sync.syncNow();
    api.calls.clear();
    await actions.deleteActivity(id);
    final entry = await isar.outboxEntrys.where().findFirst();

    expect(await actions.cancelDelete(entry!.id), isTrue);
    await sync.syncNow();

    expect(api.calls, ['sync']);
    final back = await isar.activityEntitys.getById(id);
    expect(back!.detailsJson, contains('Mewarnai'));
    expect(back.pending, isFalse);
    expect(await outboxCount(), 0);
  });

  test('cancelling an old delete without a copy refetches history', () async {
    await sync.syncNow(); // cursor a1 stored
    await isar.writeTxn(
      () => isar.outboxEntrys.put(
        OutboxEntry()
          ..kind = OutboxKind.deleteActivity
          ..payload = jsonEncode({'id': 'old'})
          ..createdAt = DateTime.now()
          ..failed = true,
      ),
    );
    final entry = await isar.outboxEntrys.where().findFirst();
    api.syncResponse = _syncBody(children: [_child('c1')], activities: [serverRow('old')]);
    api.syncCursors.clear();

    expect(await actions.cancelDelete(entry!.id), isTrue);
    await sync.syncNow();

    expect(api.syncCursors, [null]);
    expect(await isar.activityEntitys.getById('old'), isNotNull);
  });

  test('group activity: one activity per child, photos copied per child and linked', () async {
    final photo = File('${Directory.systemTemp.createTempSync().path}/g.jpg')..writeAsBytesSync([1, 2, 3]);

    final ids = await actions.logGroupActivity(
      childIds: ['c1', 'c2', 'c3'],
      type: 'play',
      details: {'activity': 'Mewarnai'},
    );
    await actions.queuePhotos(paths: [photo.path], targets: ids);

    expect(ids.keys, ['c1', 'c2', 'c3']);
    expect(ids.values.toSet(), hasLength(3), reason: 'separate activity ids');
    for (final e in ids.entries) {
      final a = await isar.activityEntitys.getById(e.value);
      expect(a!.childId, e.key);
      expect(a.detailsJson, contains('Mewarnai'));
    }
    final uploads = await isar.outboxEntrys.filter().kindEqualTo(OutboxKind.uploadPhoto).findAll();
    expect(uploads, hasLength(3));
    final payloads = [for (final u in uploads) jsonDecode(u.payload) as Map<String, dynamic>];
    expect({for (final p in payloads) p['child_id']: p['activity_id']}, ids, reason: 'each photo linked to its child');
    expect(payloads.map((p) => p['path']).toSet(), hasLength(3), reason: 'one file per upload');
    expect(payloads.every((p) => File(p['path'] as String).existsSync()), isTrue);
    expect(photo.existsSync(), isFalse, reason: 'source moved into the outbox');

    await sync.syncNow();
    expect(api.calls.where((c) => c == 'putActivity'), hasLength(3));
    expect(api.calls.where((c) => c == 'uploadPhoto'), hasLength(3));
    expect(
      api.calls.indexOf('uploadPhoto'),
      greaterThan(api.calls.lastIndexOf('putActivity')),
      reason: 'activities exist on the server before photos link to them',
    );
    for (final id in ids.values) {
      expect(
        (await isar.activityEntitys.getById(id))!.pending,
        isFalse,
        reason: 'a queued photo mentioning the activity is not an unsent edit',
      );
    }
  });

  test('an activity left "pending" with nothing queued is cleared on sync', () async {
    await isar.writeTxn(
      () => isar.activityEntitys.put(
        ActivityEntity()
          ..id = 'stuck'
          ..childId = 'c1'
          ..type = 'play'
          ..startedAt = DateTime.now()
          ..detailsJson = '{}'
          ..pending = true,
      ),
    );

    await sync.syncNow();

    expect((await isar.activityEntitys.getById('stuck'))!.pending, isFalse);
  });

  test('undoing a group activity deletes all of it and drops unsent photos', () async {
    final photo = File('${Directory.systemTemp.createTempSync().path}/g.jpg')..writeAsBytesSync([1, 2, 3]);
    final ids = await actions.logGroupActivity(childIds: ['c1', 'c2'], type: 'eat', details: {'portion': 'all'});
    await actions.queuePhotos(paths: [photo.path], targets: ids);
    final files = [
      for (final u in await isar.outboxEntrys.filter().kindEqualTo(OutboxKind.uploadPhoto).findAll())
        (jsonDecode(u.payload) as Map<String, dynamic>)['path'] as String,
    ];

    await actions.undoGroup(ids.values);

    expect(await isar.activityEntitys.where().count(), 0);
    expect(await isar.outboxEntrys.filter().kindEqualTo(OutboxKind.uploadPhoto).count(), 0);
    expect(files.any((f) => File(f).existsSync()), isFalse);
    expect(await isar.outboxEntrys.filter().kindEqualTo(OutboxKind.deleteActivity).count(), 2);
  });

  test('pull removes hidden children, applies deletions, keeps unsent local edits', () async {
    ActivityEntity act(String id, String child, {bool pending = false}) => ActivityEntity()
      ..id = id
      ..childId = child
      ..type = 'play'
      ..startedAt = DateTime.now()
      ..detailsJson = '{}'
      ..notes = 'lokal'
      ..pending = pending;
    await isar.writeTxn(() async {
      await isar.childEntitys.putAll([
        for (final id in ['c1', 'c2'])
          ChildEntity()
            ..id = id
            ..fullName = id
            ..dateOfBirth = '2024-01-01'
            ..className = 'X',
      ]);
      await isar.activityEntitys.putAll([
        act('deleted-on-server', 'c1'),
        act('edited-locally', 'c1', pending: true),
        act('of-moved-child', 'c2'),
      ]);
      // The unsent edit of 'edited-locally' (here: rejected, so still queued).
      await isar.outboxEntrys.put(
        OutboxEntry()
          ..kind = OutboxKind.putActivity
          ..payload = jsonEncode({'id': 'edited-locally', 'body': <String, dynamic>{}})
          ..createdAt = DateTime.now(),
      );
    });
    api.failWith['putActivity'] = ApiException('details invalid', status: 422);
    final serverActivity = {
      'child_id': 'c1',
      'type': 'play',
      'started_at': DateTime.now().toUtc().toIso8601String(),
      'ended_at': null,
      'details': <String, dynamic>{},
      'notes': 'server',
      'caregiver_name': 'Bayu',
    };
    api.syncResponse = _syncBody(
      children: [_child('c1')], // c2 moved to another class
      activities: [
        {...serverActivity, 'id': 'deleted-on-server', 'deleted_at': DateTime.now().toIso8601String()},
        {...serverActivity, 'id': 'edited-locally', 'deleted_at': null},
        {...serverActivity, 'id': 'new-from-server', 'deleted_at': null},
      ],
    );

    await sync.syncNow();

    final ids = (await isar.activityEntitys.where().findAll()).map((a) => a.id).toSet();
    expect(ids, {'edited-locally', 'new-from-server'});
    expect((await isar.activityEntitys.getById('edited-locally'))!.notes, 'lokal');
    expect((await isar.childEntitys.where().findAll()).map((c) => c.id), ['c1']);
  });
}
