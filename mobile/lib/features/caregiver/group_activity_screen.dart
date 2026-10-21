import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/labels.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../../theme.dart';
import '../common/widgets.dart';
import 'photo_picker.dart';

/// Activity types that make sense for a whole group at once; toilet and
/// health notes stay per child.
const groupTypes = ['play', 'eat', 'sleep'];

/// "Aktivitas bersama": one activity (and optional photos) logged for many
/// children in one go. Children present today are selected from the start.
class GroupActivityScreen extends ConsumerStatefulWidget {
  const GroupActivityScreen({super.key});

  @override
  ConsumerState<GroupActivityScreen> createState() => _GroupActivityScreenState();
}

class _GroupActivityScreenState extends ConsumerState<GroupActivityScreen> {
  Set<String>? _selected; // null until children and attendance are loaded
  String? _type;
  String? _detail;
  final _photos = <String>[];
  bool _saving = false;

  Map<String, String> get _detailOptions => switch (_type) {
    'play' => {for (final o in playOptions) o: o},
    'eat' => portionLabels,
    _ => const {},
  };

  Map<String, dynamic> get _details => switch (_type) {
    'play' => {'activity': _detail},
    'eat' => {'portion': _detail},
    _ => const {},
  };

  bool _present(AttendanceEntity? a) => a != null && a.checkOutAt == null;

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider).value;
    final attendance = ref.watch(todayAttendanceProvider).value;
    final asleep = ref.watch(openSleepsProvider).value ?? const {};
    if (children == null || attendance == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selected = _selected ??= {
      for (final c in children)
        if (_present(attendance[c.id])) c.id,
    };
    // Starting a nap for a child already asleep would open a second sleep.
    final skipped = _type == 'sleep' ? selected.where(asleep.containsKey).toSet() : const <String>{};
    final targets = selected.difference(skipped);
    final ready = targets.isNotEmpty && _type != null && (_detailOptions.isEmpty || _detail != null);

    return Scaffold(
      appBar: AppBar(title: const Text('Aktivitas bersama')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Anak · ${selected.length} dipilih', style: Theme.of(context).textTheme.titleMedium),
              ),
              TextButton(
                onPressed: () => setState(
                  () => _selected = {
                    for (final c in children)
                      if (_present(attendance[c.id])) c.id,
                  },
                ),
                child: const Text('Yang hadir'),
              ),
              TextButton(onPressed: () => setState(() => _selected = {}), child: const Text('Kosongkan')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in children)
                FilterChip(
                  label: Text(_present(attendance[c.id]) ? displayName(c) : '${displayName(c)} (tidak hadir)'),
                  selected: selected.contains(c.id),
                  onSelected: (on) => setState(() => on ? selected.add(c.id) : selected.remove(c.id)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Aktivitas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in groupTypes)
                ChoiceChip(
                  showCheckmark: false, // the checkmark would cover the icon
                  avatar: Icon(styleFor(t).icon, color: styleFor(t).color),
                  label: Text(styleFor(t).label),
                  selected: _type == t,
                  onSelected: (_) => setState(() {
                    _type = t;
                    _detail = null;
                  }),
                ),
            ],
          ),
          if (_detailOptions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in _detailOptions.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: _detail == e.key,
                    onSelected: (_) => setState(() => _detail = e.key),
                  ),
              ],
            ),
          ],
          if (_type == 'sleep')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                skipped.isEmpty
                    ? 'Tidur dimulai sekarang. Tandai "Bangun" per anak dari kartunya.'
                    : '${skipped.length} anak sudah tidur dan dilewati. Tandai "Bangun" per anak dari kartunya.',
                style: const TextStyle(color: AppColors.muted),
              ),
            ),
          const SizedBox(height: 24),
          Text('Foto (opsional)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            'Foto masuk ke timeline setiap anak yang dipilih.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (i, p) in _photos.indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(p), width: 96, height: 96, fit: BoxFit.cover, cacheWidth: 240),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          // Small badge, but the whole top-right quarter of
                          // the thumbnail is the tap target.
                          child: InkWell(
                            onTap: () => setState(() => _photos.removeAt(i)),
                            child: const SizedBox.square(
                              dimension: 48,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                      semanticLabel: 'Hapus foto',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_photos.length < maxGalleryPhotos)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await pickPhotos(context);
                      setState(() => _photos.addAll(picked.take(maxGalleryPhotos - _photos.length)));
                    },
                    child: Container(
                      width: 96,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.brand.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: AppColors.brand),
                          SizedBox(height: 4),
                          Text(
                            'Tambah',
                            style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: ready && !_saving ? () => _save(targets) : null,
            child: _saving
                ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(color: Colors.white))
                : Text(targets.isEmpty ? 'PILIH ANAK DULU' : 'SIMPAN UNTUK ${targets.length} ANAK'),
          ),
        ),
      ),
    );
  }

  Future<void> _save(Set<String> targets) async {
    setState(() => _saving = true);
    final actions = ref.read(caregiverActionsProvider);
    final ids = await actions.logGroupActivity(childIds: targets, type: _type!, details: _details);
    await actions.queuePhotos(paths: _photos, targets: ids);
    if (!mounted) return;
    Navigator.pop(context);
    final what = switch (_type) {
      'play' => '🎨 $_detail',
      'eat' => '🍼 Makan ${portionLabels[_detail]}',
      _ => '😴 Tidur',
    };
    final photos = _photos.isEmpty ? '' : ' · ${_photos.length} foto';
    showUndoToast('$what dicatat untuk ${ids.length} anak$photos', undo: () => actions.undoGroup(ids.values));
  }
}
