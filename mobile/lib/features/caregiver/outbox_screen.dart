import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/dates.dart';
import '../../core/labels.dart';
import '../../data/models.dart';
import '../../data/sync_service.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../common/widgets.dart';

/// Writes still on the phone: waiting to be sent, or rejected by the
/// server. A queued delete can be cancelled here before it goes out.
class OutboxScreen extends ConsumerWidget {
  const OutboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(outboxEntriesProvider);
    final children = {for (final c in ref.watch(childrenProvider).value ?? const <ChildEntity>[]) c.id: c};
    final status = ref.watch(syncStatusProvider);
    final hasFailed = entries.value?.any((e) => e.failed) ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Data belum terkirim'), actions: const [SyncButton()]),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text('Semua data sudah terkirim.', style: TextStyle(color: AppColors.muted)),
              )
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [for (final e in list) _EntryTile(entry: e, children: children)],
              ),
      ),
      bottomNavigationBar: hasFailed
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  onPressed: status.syncing ? null : () => ref.read(syncServiceProvider).retryFailed(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kirim ulang yang ditolak'),
                ),
              ),
            )
          : null,
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry, required this.children});

  final OutboxEntry entry;
  final Map<String, ChildEntity> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = jsonDecode(entry.payload) as Map<String, dynamic>;
    final (icon, title, childId) = _describe(p);
    final child = children[childId];
    final isDelete = entry.kind == OutboxKind.deleteActivity;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: Icon(icon, color: isDelete ? AppColors.medical : AppColors.brand),
                title: Text(child == null ? title : '$title · ${displayName(child)}'),
                subtitle: Text(
                  entry.failed
                      ? 'Ditolak server: ${entry.lastError ?? '-'}'
                      : 'Menunggu dikirim · dibuat ${hm(entry.createdAt)}',
                  style: TextStyle(color: entry.failed ? AppColors.medical : AppColors.muted),
                ),
              ),
            ),
            if (isDelete)
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
                onPressed: () => _cancelDelete(context, ref),
                child: const Text('BATALKAN\nHAPUS', textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelDelete(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(caregiverActionsProvider).cancelDelete(entry.id);
    rootMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Hapus dibatalkan. Aktivitas tampil lagi.'
                : 'Sudah terkirim. Minta admin memulihkannya di menu Aktivitas terhapus.',
          ),
        ),
      );
  }

  (IconData, String, String?) _describe(Map<String, dynamic> p) {
    switch (entry.kind) {
      case OutboxKind.checkIn:
        return (Icons.login, 'Check-in', p['child_id'] as String?);
      case OutboxKind.checkOut:
        return (Icons.logout, 'Check-out', p['child_id'] as String?);
      case OutboxKind.putActivity:
        final body = p['body'] as Map<String, dynamic>;
        final at = DateTime.parse(body['started_at'] as String);
        return (Icons.edit_note, '${styleFor(body['type'] as String).label} ${hm(at)}', body['child_id'] as String?);
      case OutboxKind.deleteActivity:
        final a = p['activity'] as Map<String, dynamic>?;
        if (a == null) return (Icons.delete_outline, 'Hapus aktivitas', null);
        final at = DateTime.parse(a['started_at'] as String);
        return (
          Icons.delete_outline,
          'Hapus ${styleFor(a['type'] as String).label} ${hm(at)}',
          a['child_id'] as String?,
        );
      case OutboxKind.uploadPhoto:
        return (Icons.photo_camera, 'Foto', p['child_id'] as String?);
      default:
        return (Icons.help_outline, entry.kind, null);
    }
  }
}
