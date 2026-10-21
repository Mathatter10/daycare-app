import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/labels.dart';
import '../../data/caregiver_actions.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../common/widgets.dart';
import '../timeline/timeline_screen.dart';
import 'camera_screen.dart';
import 'medical_sheet.dart';

/// Tap 1 of the "log in under 3 taps" flow: the child's quick actions.
Future<void> showChildActions(BuildContext context, ChildEntity child) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _ChildActionsSheet(child: child),
);

class _ChildActionsSheet extends ConsumerWidget {
  const _ChildActionsSheet({required this.child});

  final ChildEntity child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(todayAttendanceProvider).value?[child.id];
    final sleep = ref.watch(openSleepsProvider).value?[child.id];
    final actions = ref.read(caregiverActionsProvider);
    final name = displayName(child);
    final checkedIn = attendance != null;
    final checkedOut = attendance?.checkOutAt != null;

    void close() => Navigator.pop(context);

    Future<void> logAndClose(String type, String message, {Map<String, dynamic> details = const {}}) async {
      final id = await actions.logActivity(childId: child.id, type: type, details: details);
      close();
      showUndoToast(message, undo: () => actions.deleteActivity(id));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(child.fullName, style: Theme.of(context).textTheme.titleMedium),
            Text(
              checkedOut
                  ? 'Sudah pulang ${hm(attendance!.checkOutAt!)}'
                  : checkedIn
                  ? 'Hadir sejak ${hm(attendance.checkInAt)}'
                  : 'Belum check-in hari ini',
              style: const TextStyle(color: AppColors.muted),
            ),
            if (child.allergies?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  '⚠ Alergi: ${child.allergies}',
                  style: const TextStyle(color: AppColors.medical, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.05,
              children: [
                _ActionTile(
                  style: styleFor('eat'),
                  onTap: () => _showOptions(
                    context,
                    title: 'Makan · $name',
                    options: portionLabels,
                    onPick: (v) async {
                      close();
                      final id = await actions.logActivity(childId: child.id, type: 'eat', details: {'portion': v});
                      showUndoToast('🍼 Makan dicatat: ${portionLabels[v]}', undo: () => actions.deleteActivity(id));
                    },
                  ),
                ),
                _ActionTile(
                  style: sleep == null
                      ? styleFor('sleep')
                      : const ActivityStyle('Bangun', Icons.wb_sunny, AppColors.eat),
                  onTap: () async {
                    if (sleep == null) {
                      await logAndClose('sleep', '😴 $name mulai tidur ${hm(DateTime.now())}');
                    } else {
                      await actions.endSleep(sleep);
                      close();
                      showUndoToast(
                        '🌤️ $name bangun · tidur ${durationLabel(DateTime.now().difference(sleep.startedAt))}',
                      );
                    }
                  },
                ),
                _ActionTile(
                  style: styleFor('toilet'),
                  onTap: () => _showOptions(
                    context,
                    title: 'Toilet · $name',
                    options: toiletLabels,
                    onPick: (v) async {
                      close();
                      final id = await actions.logActivity(childId: child.id, type: 'toilet', details: {'kind': v});
                      showUndoToast('🧻 Toilet dicatat: ${toiletLabels[v]}', undo: () => actions.deleteActivity(id));
                    },
                  ),
                ),
                _ActionTile(
                  style: styleFor('play'),
                  onTap: () => _showOptions(
                    context,
                    title: 'Main · $name',
                    options: {for (final o in playOptions) o: o},
                    onPick: (v) async {
                      close();
                      final id = await actions.logActivity(childId: child.id, type: 'play', details: {'activity': v});
                      showUndoToast('🎨 $v dicatat', undo: () => actions.deleteActivity(id));
                    },
                  ),
                ),
                _ActionTile(
                  style: styleFor('medical'),
                  onTap: () => showMedicalSheet(context, child, onDone: close),
                ),
                _ActionTile(
                  style: const ActivityStyle('Foto', Icons.photo_camera, AppColors.brand),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    close();
                    final path = await nav.push<String>(MaterialPageRoute(builder: (_) => const CameraScreen()));
                    if (path == null) return;
                    await actions.queuePhoto(childId: child.id, capturedPath: path);
                    showUndoToast('📷 Foto $name akan dikirim');
                  },
                ),
                _ActionTile(
                  style: const ActivityStyle('Timeline', Icons.view_timeline, AppColors.muted),
                  onTap: () {
                    final nav = Navigator.of(context);
                    close();
                    nav.push(MaterialPageRoute(builder: (_) => TimelineScreen(child: child)));
                  },
                ),
                if (checkedIn && !checkedOut)
                  _ActionTile(
                    style: const ActivityStyle('Check-out', Icons.logout, AppColors.brand),
                    onTap: () => _showCheckOut(context, actions, child, onDone: close),
                  ),
              ],
            ),
            if (!checkedIn) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                icon: const Icon(Icons.login),
                label: const Text('CHECK-IN SEKARANG'),
                onPressed: () async {
                  await actions.checkIn(child.id);
                  close();
                  showUndoToast('✅ $name check-in ${hm(DateTime.now())}');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.style, required this.onTap});

  final ActivityStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: style.color.withValues(alpha: 0.08),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ActivityAvatar(icon: style.icon, color: style.color, size: 44),
          const SizedBox(height: 6),
          Text(
            style.label,
            style: TextStyle(fontWeight: FontWeight.w600, color: style.color),
          ),
        ],
      ),
    ),
  );
}

/// Tap 3: one big chip per option; picking one saves immediately. Opens on
/// top of the actions sheet; [onPick] closes that one.
Future<void> _showOptions(
  BuildContext context, {
  required String title,
  required Map<String, String> options,
  required Future<void> Function(String value) onPick,
}) => showModalBottomSheet<void>(
  context: context,
  builder: (ctx) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in options.entries)
                ActionChip(
                  label: Text(e.value),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await onPick(e.key);
                  },
                ),
            ],
          ),
        ],
      ),
    ),
  ),
);

Future<void> _showCheckOut(
  BuildContext context,
  CaregiverActions actions,
  ChildEntity child, {
  required VoidCallback onDone,
}) async {
  final other = TextEditingController();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Dijemput oleh siapa?', style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final who in pickUpOptions)
                ActionChip(
                  label: Text(who),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    onDone();
                    await actions.checkOut(child.id, who);
                    showUndoToast('👋 ${displayName(child)} dijemput $who');
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: other,
            decoration: const InputDecoration(labelText: 'Lainnya (nama)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final who = other.text.trim();
              if (who.isEmpty) return;
              Navigator.pop(ctx);
              onDone();
              await actions.checkOut(child.id, who);
              showUndoToast('👋 ${displayName(child)} dijemput $who');
            },
            child: const Text('SIMPAN & KIRIM'),
          ),
        ],
      ),
    ),
  );
  other.dispose();
}
