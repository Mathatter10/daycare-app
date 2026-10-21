import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dates.dart';
import '../../core/labels.dart';
import '../../core/session.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../caregiver/photo_picker.dart';
import '../common/widgets.dart';

/// One day of a child's attendance, activities and photos. Activities come
/// from Isar (works offline); photos need a connection (signed URLs).
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key, required this.child, this.showSignOut = false});

  final ChildEntity child;

  /// Parents with a single child land here directly and need a way out.
  final bool showSignOut;

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  DateTime _day = startOfDay(DateTime.now());

  // Sync keeps the last 14 days on the phone.
  static const _maxDaysBack = 13;

  bool get _isToday => _day == startOfDay(DateTime.now());
  bool get _atOldest => DateTime.now().difference(_day).inDays >= _maxDaysBack;

  void _shift(int days) => setState(() => _day = startOfDay(_day.add(Duration(days: days))));

  Future<void> _refresh() async {
    ChildDay arg = (childId: widget.child.id, day: _day);
    ref.invalidate(dayMediaProvider(arg));
    await ref.read(syncServiceProvider).syncNow();
  }

  @override
  Widget build(BuildContext context) {
    final arg = (childId: widget.child.id, day: _day);
    final activities = ref.watch(dayActivitiesProvider(arg));
    final attendance = ref.watch(dayAttendanceProvider(arg)).value;
    final media = ref.watch(dayMediaProvider(arg));
    final isCaregiver = ref.watch(currentUserProvider).role == Role.caregiver;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName(widget.child)),
        actions: [
          const SyncButton(),
          if (widget.showSignOut)
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
          Material(
            color: Colors.white,
            child: Row(
              children: [
                IconButton(onPressed: _atOldest ? null : () => _shift(-1), icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Text(
                    _isToday ? 'Hari ini · ${dayLabel(_day)}' : dayLabel(_day),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(onPressed: _isToday ? null : () => _shift(1), icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _AttendanceCard(attendance: attendance),
                  const SizedBox(height: 12),
                  _MediaStrip(media: media),
                  ...activities.when(
                    loading: () => [const Center(child: CircularProgressIndicator())],
                    error: (e, _) => [Text('Gagal memuat: $e')],
                    data: (list) => list.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'Belum ada aktivitas.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          ]
                        : [for (final a in list) _ActivityTile(activity: a, canDelete: isCaregiver)],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({this.attendance});

  final AttendanceEntity? attendance;

  @override
  Widget build(BuildContext context) {
    final a = attendance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: a == null
            ? const Row(
                children: [
                  Icon(Icons.home_outlined, color: AppColors.muted),
                  SizedBox(width: 12),
                  Text('Belum check-in', style: TextStyle(color: AppColors.muted)),
                ],
              )
            : Row(
                children: [
                  Expanded(child: _timeCol('Tiba', hm(a.checkInAt), AppColors.accent)),
                  Expanded(
                    child: _timeCol(
                      a.pickedUpBy == null ? 'Pulang' : 'Dijemput ${a.pickedUpBy}',
                      a.checkOutAt == null ? '—' : hm(a.checkOutAt!),
                      AppColors.brand,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _timeCol(String label, String time, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      Text(
        time,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
      ),
    ],
  );
}

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.activity, required this.canDelete});

  final ActivityEntity activity;
  final bool canDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = styleFor(activity.type);
    final description = describeActivity(activity);
    final tile = Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: ActivityAvatar(icon: style.icon, color: style.color),
        title: Text(style.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (description.isNotEmpty) description,
            if (activity.caregiverName != null) 'oleh ${activity.caregiverName}',
          ].join('\n'),
        ),
        isThreeLine: description.contains('\n'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(hm(activity.startedAt), style: const TextStyle(fontWeight: FontWeight.w600)),
            if (activity.pending)
              const Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.muted)
            else if (canDelete)
              const Icon(Icons.add_a_photo_outlined, size: 16, color: AppColors.brand),
          ],
        ),
        // Caregivers: tap to add photos linked to this activity.
        onTap: canDelete ? () => _addPhotos(context, ref) : null,
      ),
    );
    if (!canDelete) return tile;
    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.medical,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hapus aktivitas?'),
          content: Text('${style.label} pukul ${hm(activity.startedAt)} akan dihapus.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
          ],
        ),
      ),
      onDismissed: (_) => ref.read(caregiverActionsProvider).deleteActivity(activity.id),
      child: tile,
    );
  }

  Future<void> _addPhotos(BuildContext context, WidgetRef ref) async {
    final actions = ref.read(caregiverActionsProvider);
    final paths = await pickPhotos(context);
    if (paths.isEmpty) return;
    await actions.queuePhotos(paths: paths, targets: {activity.childId: activity.id});
    showUndoToast('📷 ${paths.length} foto ${styleFor(activity.type).label} akan dikirim');
  }
}

class _MediaStrip extends StatelessWidget {
  const _MediaStrip({required this.media});

  final AsyncValue<List<Map<String, dynamic>>> media;

  @override
  Widget build(BuildContext context) {
    return media.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Text('📷 Foto tampil saat online.', style: TextStyle(color: AppColors.muted)),
      ),
      data: (items) {
        final photos = items.where((m) => m['kind'] == 'photo' && m['thumbnail_url'] != null).toList();
        if (photos.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final m = photos[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _PhotoViewer(media: m))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      // Signed URLs change every hour; cache by media id.
                      imageUrl: m['thumbnail_url'] as String,
                      cacheKey: 'thumb-${m['id']}',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(width: 110, color: Colors.grey.shade200),
                      errorWidget: (_, _, _) =>
                          Container(width: 110, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({required this.media});

  final Map<String, dynamic> media;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
    body: Center(
      child: InteractiveViewer(
        child: CachedNetworkImage(
          imageUrl: media['url'] as String,
          cacheKey: 'full-${media['id']}',
          placeholder: (_, _) => const CircularProgressIndicator(),
        ),
      ),
    ),
  );
}
