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
    actions = CaregiverActions(isar, sync, user);
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

  test('editing an activity someone else deleted is dropped quietly', () async {
    await actions.logActivity(childId: 'c1', type: 'play');
    api.failWith['putActivity'] = ApiException('activity was deleted', status: 409);

    await sync.syncNow();

    expect(await outboxCount(), 0);
    expect(await outboxCount(failed: true), 0);
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
    });
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
