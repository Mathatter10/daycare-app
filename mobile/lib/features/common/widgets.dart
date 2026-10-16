import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../providers.dart';
import '../../theme.dart';

/// App bar icon showing sync state; tap to sync now.
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final counts = ref.watch(outboxCountsProvider).value ?? (pending: 0, failed: 0);
    final IconData icon;
    final String tooltip;
    if (status.syncing) {
      icon = Icons.sync;
      tooltip = 'Menyinkronkan…';
    } else if (status.offline) {
      icon = Icons.cloud_off;
      tooltip = 'Offline';
    } else if (counts.pending > 0) {
      icon = Icons.cloud_upload;
      tooltip = '${counts.pending} data menunggu dikirim';
    } else {
      icon = Icons.cloud_done;
      tooltip = status.lastSyncAt == null ? 'Sinkron' : 'Sinkron ${hm(status.lastSyncAt!)}';
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: () => ref.read(syncServiceProvider).syncNow(),
      icon: Badge(isLabelVisible: counts.pending > 0, label: Text('${counts.pending}'), child: Icon(icon)),
    );
  }
}

/// Thin banner under the app bar when offline or when writes were rejected.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final counts = ref.watch(outboxCountsProvider).value ?? (pending: 0, failed: 0);
    String? text;
    Color color = AppColors.muted;
    final rejected = counts.failed > 0;
    if (rejected) {
      text = '${counts.failed} data ditolak server. Hubungi admin bila berulang.';
      color = AppColors.medical;
    } else if (status.offline) {
      text = counts.pending > 0
          ? 'Offline · ${counts.pending} data tersimpan di HP, dikirim saat online'
          : 'Offline · data terakhir ditampilkan';
    } else if (status.error != null) {
      text = status.error;
      color = AppColors.medical;
    }
    if (text == null) return const SizedBox.shrink();
    return Material(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: TextStyle(color: color, fontSize: 13)),
            ),
            if (rejected)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: color, minimumSize: const Size(48, 48)),
                onPressed: status.syncing ? null : () => ref.read(syncServiceProvider).retryFailed(),
                child: const Text('COBA LAGI', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final pending = ref.read(outboxCountsProvider).value?.pending ?? 0;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Keluar?'),
      content: Text(
        pending > 0
            ? 'Masih ada $pending data yang belum terkirim. Jika keluar sekarang, data itu akan HILANG.'
            : 'Data di HP ini akan dihapus. Anda bisa masuk lagi kapan saja.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Keluar', style: TextStyle(color: pending > 0 ? AppColors.medical : null)),
        ),
      ],
    ),
  );
  if (ok == true) await ref.read(sessionProvider.notifier).signOut();
}

/// Round colored icon used for activity types.
class ActivityAvatar extends StatelessWidget {
  const ActivityAvatar({super.key, required this.icon, required this.color, this.size = 40});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
    child: Icon(icon, color: color, size: size * 0.55),
  );
}
