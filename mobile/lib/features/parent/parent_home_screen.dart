import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/labels.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../common/widgets.dart';
import '../timeline/timeline_screen.dart';

/// Parent home: straight to the timeline for one child, a list for more.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(childrenProvider);
    final attendance = ref.watch(todayAttendanceProvider).value ?? const {};

    return children.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Gagal memuat: $e'))),
      data: (list) {
        if (list.length == 1) return TimelineScreen(child: list.first, showSignOut: true);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Anak Saya'),
            actions: [
              const SyncButton(),
              IconButton(
                tooltip: 'Keluar',
                icon: const Icon(Icons.logout),
                onPressed: () => confirmSignOut(context, ref),
              ),
            ],
          ),
          body: Column(
            children: [
              const SyncBanner(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(syncServiceProvider).syncNow(),
                  child: list.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Text(
                              'Belum ada data anak.\nTarik ke bawah untuk memuat ulang.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, i) {
                            final c = list[i];
                            final a = attendance[c.id];
                            final status = a == null
                                ? 'Belum tiba hari ini'
                                : a.checkOutAt != null
                                ? 'Sudah dijemput ${hm(a.checkOutAt!)}'
                                : 'Di daycare sejak ${hm(a.checkInAt)}';
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.brand.withValues(alpha: 0.15),
                                  child: Text(
                                    initials(c),
                                    style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(c.fullName, style: Theme.of(context).textTheme.titleMedium),
                                subtitle: Text('${c.className}\n$status'),
                                isThreeLine: true,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TimelineScreen(child: c)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
