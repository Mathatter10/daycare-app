import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/labels.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../common/widgets.dart';
import 'child_actions_sheet.dart';

/// Caregiver home: every child in the caregiver's classes as a card.
class RosterScreen extends ConsumerWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final attendance = ref.watch(todayAttendanceProvider).value ?? const {};
    final sleeping = ref.watch(openSleepsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Anak Hari Ini · ${dayLabel(DateTime.now())}', style: const TextStyle(fontSize: 18)),
        actions: [
          const SyncButton(),
          IconButton(tooltip: 'Keluar', icon: const Icon(Icons.logout), onPressed: () => confirmSignOut(context, ref)),
        ],
      ),
      body: Column(
        children: [
          const SyncBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(syncServiceProvider).syncNow(),
              child: children.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Gagal memuat data: $e')),
                data: (list) => list.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 120),
                          Icon(Icons.child_care, size: 64, color: AppColors.muted),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada anak di kelas Anda.\nTarik ke bawah untuk memuat ulang.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.95,
                        ),
                        itemCount: list.length,
                        itemBuilder: (_, i) =>
                            _ChildCard(child: list[i], attendance: attendance[list[i].id], sleep: sleeping[list[i].id]),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, this.attendance, this.sleep});

  final ChildEntity child;
  final AttendanceEntity? attendance;
  final ActivityEntity? sleep;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _status();
    final hasAllergy = child.allergies?.trim().isNotEmpty ?? false;
    final away = attendance == null || attendance!.checkOutAt != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showChildActions(context, child),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: away ? Colors.grey.shade300 : AppColors.brand.withValues(alpha: 0.15),
                    child: Text(
                      initials(child),
                      style: TextStyle(fontWeight: FontWeight.bold, color: away ? AppColors.muted : AppColors.brand),
                    ),
                  ),
                  const Spacer(),
                  if (hasAllergy)
                    const Tooltip(
                      message: 'Alergi',
                      child: Icon(Icons.warning_amber_rounded, color: AppColors.medical),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                displayName(child),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                child.className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color) _status() {
    final a = attendance;
    if (a == null) return ('Belum datang', AppColors.muted);
    if (a.checkOutAt != null) return ('Pulang ${hm(a.checkOutAt!)}', AppColors.brand);
    if (sleep != null) return ('Tidur sejak ${hm(sleep!.startedAt)}', AppColors.sleep);
    return ('Hadir sejak ${hm(a.checkInAt)}', AppColors.accent);
  }
}
