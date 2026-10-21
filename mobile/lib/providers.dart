import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'core/api_client.dart';
import 'core/dates.dart';
import 'core/session.dart';
import 'data/caregiver_actions.dart';
import 'data/db.dart';
import 'data/models.dart';
import 'data/sync_service.dart';

/// Opened in main() and injected with overrideWithValue.
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError('isarProvider must be overridden'));

final authStoreProvider = Provider<AuthStore>((ref) => AuthStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    store: ref.watch(authStoreProvider),
    onSessionExpired: () => ref.read(sessionProvider.notifier).sessionExpired(),
  ),
);

// --- session ------------------------------------------------------------------

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class SignedOut extends SessionState {
  const SignedOut([this.message]);
  final String? message;
}

class SignedIn extends SessionState {
  const SignedIn(this.user);
  final AppUser user;
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    _restore();
    return const SessionLoading();
  }

  Future<void> _restore() async {
    final stored = await ref.read(authStoreProvider).load();
    state = stored == null ? const SignedOut() : SignedIn(stored.user);
  }

  /// Throws [ApiException] with a user-facing message on failure.
  Future<void> signIn(String email, String password) async {
    final result = await ref.read(apiClientProvider).login(email.trim(), password);
    final store = ref.read(authStoreProvider);
    // Unsent data kept from an expired session is only sent by its owner.
    final owner = await store.dataOwner();
    if (owner != null && owner != result.user.id) await clearDatabase(ref.read(isarProvider));
    await store.setDataOwner(null);
    await store.save(result.user, result.tokens);
    state = SignedIn(result.user);
  }

  /// Revokes the refresh token (best effort) and wipes all local data.
  Future<void> signOut({String? message}) async {
    if (state is SignedOut) return;
    await ref.read(apiClientProvider).logout();
    await ref.read(authStoreProvider).clear();
    await clearDatabase(ref.read(isarProvider));
    state = SignedOut(message);
  }

  bool _expiring = false;

  /// The server refused to renew the session (account deactivated, token
  /// revoked). Unsent writes stay on the phone until the same account
  /// logs in again; otherwise this is a normal sign-out.
  Future<void> sessionExpired() async {
    final s = state;
    if (s is! SignedIn || _expiring) return;
    _expiring = true;
    try {
      final unsent = await ref.read(isarProvider).outboxEntrys.filter().failedEqualTo(false).count();
      if (unsent == 0) return await signOut(message: 'Sesi berakhir. Silakan masuk lagi.');
      final store = ref.read(authStoreProvider);
      await store.clear();
      await store.setDataOwner(s.user.id);
      state = SignedOut(
        'Sesi berakhir. $unsent data belum terkirim masih tersimpan di HP ini. '
        'Masuk lagi sebagai ${s.user.email} untuk mengirimnya; masuk dengan akun lain akan menghapusnya.',
      );
    } finally {
      _expiring = false;
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);

/// The signed-in user. Only read below the signed-in part of the tree.
final currentUserProvider = Provider<AppUser>((ref) {
  final s = ref.watch(sessionProvider);
  if (s is SignedIn) return s.user;
  throw StateError('not signed in');
});

// --- sync -----------------------------------------------------------------------

class SyncStatusNotifier extends Notifier<SyncStatus> {
  @override
  SyncStatus build() => const SyncStatus();

  void set(SyncStatus s) => state = s;
}

final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncStatus>(SyncStatusNotifier.new);

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.watch(isarProvider),
    ref.watch(apiClientProvider),
    (s) => ref.read(syncStatusProvider.notifier).set(s),
  );
  ref.onDispose(service.dispose);
  return service;
});

final caregiverActionsProvider = Provider<CaregiverActions>(
  (ref) => CaregiverActions(ref.watch(isarProvider), ref.watch(syncServiceProvider), ref.watch(currentUserProvider)),
);

/// (pending, failed) outbox counts, live.
final outboxCountsProvider = StreamProvider<({int pending, int failed})>((ref) async* {
  final isar = ref.watch(isarProvider);
  Future<({int pending, int failed})> counts() async => (
    pending: await isar.outboxEntrys.filter().failedEqualTo(false).count(),
    failed: await isar.outboxEntrys.filter().failedEqualTo(true).count(),
  );
  yield await counts();
  await for (final _ in isar.outboxEntrys.watchLazy()) {
    yield await counts();
  }
});

/// Every queued write, oldest first, live.
final outboxEntriesProvider = StreamProvider.autoDispose<List<OutboxEntry>>(
  (ref) => ref.watch(isarProvider).outboxEntrys.where().watch(fireImmediately: true),
);

// --- local data streams ---------------------------------------------------------

final childrenProvider = StreamProvider<List<ChildEntity>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.childEntitys.where().sortByClassName().thenByFullName().watch(fireImmediately: true);
});

/// Today's attendance per child id.
final todayAttendanceProvider = StreamProvider<Map<String, AttendanceEntity>>((ref) {
  final isar = ref.watch(isarProvider);
  final today = dayKey(DateTime.now());
  return isar.attendanceEntitys
      .filter()
      .dateEqualTo(today)
      .watch(fireImmediately: true)
      .map((list) => {for (final a in list) a.childId: a});
});

/// Sleeps without an end time, per child id (child is asleep).
final openSleepsProvider = StreamProvider<Map<String, ActivityEntity>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.activityEntitys
      .filter()
      .typeEqualTo('sleep')
      .endedAtIsNull()
      .startedAtGreaterThan(startOfDay(DateTime.now()))
      .watch(fireImmediately: true)
      .map((list) => {for (final a in list) a.childId: a});
});

typedef ChildDay = ({String childId, DateTime day});

final dayActivitiesProvider = StreamProvider.autoDispose.family<List<ActivityEntity>, ChildDay>((ref, arg) {
  final isar = ref.watch(isarProvider);
  final from = startOfDay(arg.day);
  return isar.activityEntitys
      .filter()
      .childIdEqualTo(arg.childId)
      .startedAtBetween(from, from.add(const Duration(days: 1)), includeUpper: false)
      .sortByStartedAtDesc()
      .watch(fireImmediately: true);
});

final dayAttendanceProvider = StreamProvider.autoDispose.family<AttendanceEntity?, ChildDay>((ref, arg) {
  final isar = ref.watch(isarProvider);
  return isar.attendanceEntitys
      .filter()
      .keyEqualTo('${arg.childId}|${dayKey(arg.day)}')
      .watch(fireImmediately: true)
      .map((list) => list.isEmpty ? null : list.first);
});

/// Photos/videos for a child's day, read online (signed URLs expire).
final dayMediaProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, ChildDay>((ref, arg) async {
  final res = await ref.watch(apiClientProvider).timeline(arg.childId, dayKey(arg.day));
  return ((res['media'] as List?) ?? const []).cast<Map<String, dynamic>>();
});
