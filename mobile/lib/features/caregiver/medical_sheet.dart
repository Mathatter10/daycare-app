import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/labels.dart';
import '../../data/models.dart';
import '../../providers.dart';
import '../../theme.dart';

/// Opens on top of the actions sheet; [onDone] closes that one after saving.
Future<void> showMedicalSheet(BuildContext context, ChildEntity child, {required VoidCallback onDone}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicalSheet(child: child, onDone: onDone),
    );

const _kinds = {'temperature': 'Suhu', 'medicine': 'Obat', 'injury': 'Cedera', 'other': 'Lainnya'};

/// Health note. Temperature uses +/- buttons so no keyboard is needed.
class _MedicalSheet extends ConsumerStatefulWidget {
  const _MedicalSheet({required this.child, required this.onDone});

  final ChildEntity child;
  final VoidCallback onDone;

  @override
  ConsumerState<_MedicalSheet> createState() => _MedicalSheetState();
}

class _MedicalSheetState extends ConsumerState<_MedicalSheet> {
  String _kind = 'temperature';
  double _temp = 36.5;
  final _medicine = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _medicine.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _step(double delta) => setState(() => _temp = (((_temp + delta) * 10).round() / 10).clamp(34.0, 43.0));

  bool get _valid => switch (_kind) {
    'medicine' => _medicine.text.trim().isNotEmpty,
    'injury' || 'other' => _notes.text.trim().isNotEmpty,
    _ => true,
  };

  Future<void> _save() async {
    final details = <String, dynamic>{'kind': _kind};
    if (_kind == 'temperature') details['temperature_c'] = _temp;
    if (_kind == 'medicine') details['medicine'] = _medicine.text.trim();
    final actions = ref.read(caregiverActionsProvider);
    final id = await actions.logActivity(
      childId: widget.child.id,
      type: 'medical',
      details: details,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    Navigator.pop(context);
    widget.onDone();
    rootMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text('💊 Catatan kesehatan ${displayName(widget.child)} disimpan'),
        action: SnackBarAction(label: 'BATALKAN', onPressed: () => actions.deleteActivity(id)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fever = _temp >= 37.5;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Kesehatan · ${displayName(widget.child)}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final e in _kinds.entries)
                ChoiceChip(
                  label: Text(e.value),
                  selected: _kind == e.key,
                  onSelected: (_) => setState(() => _kind = e.key),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_kind == 'temperature')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(iconSize: 32, onPressed: () => _step(-0.1), icon: const Icon(Icons.remove)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '${_temp.toStringAsFixed(1)}°C',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: fever ? AppColors.medical : null,
                    ),
                  ),
                ),
                IconButton.filledTonal(iconSize: 32, onPressed: () => _step(0.1), icon: const Icon(Icons.add)),
              ],
            ),
          if (_kind == 'medicine')
            TextField(
              controller: _medicine,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Nama obat & dosis', border: OutlineInputBorder()),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            onChanged: (_) => setState(() {}),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: _kind == 'injury' || _kind == 'other' ? 'Keterangan (wajib)' : 'Catatan (opsional)',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: _valid ? _save : null,
            child: const Text('SIMPAN & KIRIM'),
          ),
        ],
      ),
    );
  }
}
