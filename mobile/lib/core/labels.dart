import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme.dart';
import 'dates.dart';

/// Option values match the API's activity details (docs/API.md).
const portionLabels = {
  'all': 'Habis semua',
  'most': 'Hampir habis',
  'half': 'Setengah porsi',
  'little': 'Sedikit',
  'none': 'Tidak mau makan',
};

const toiletLabels = {'wet': 'Pipis', 'dirty': 'BAB', 'both': 'Pipis dan BAB', 'dry': 'Popok kering'};

const playOptions = ['Bermain bebas', 'Mewarnai', 'Membaca buku', 'Musik & menari', 'Bermain di luar'];

const pickUpOptions = ['Ayah', 'Ibu', 'Kakek', 'Nenek'];

class ActivityStyle {
  const ActivityStyle(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

const activityStyles = {
  'eat': ActivityStyle('Makan', Icons.restaurant, AppColors.eat),
  'sleep': ActivityStyle('Tidur', Icons.bedtime, AppColors.sleep),
  'toilet': ActivityStyle('Toilet', Icons.baby_changing_station, AppColors.toilet),
  'play': ActivityStyle('Main', Icons.toys, AppColors.play),
  'medical': ActivityStyle('Kesehatan', Icons.medical_services, AppColors.medical),
};

ActivityStyle styleFor(String type) =>
    activityStyles[type] ?? const ActivityStyle('Aktivitas', Icons.event_note, AppColors.muted);

/// One-line description of an activity, e.g. "Setengah porsi · Bubur ayam".
String describeActivity(ActivityEntity a) {
  final d = _details(a.detailsJson);
  String text;
  switch (a.type) {
    case 'eat':
      text = [portionLabels[d['portion']], d['menu']].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    case 'sleep':
      text = a.endedAt == null
          ? 'Sedang tidur'
          : '${hm(a.startedAt)}–${hm(a.endedAt!)} (${durationLabel(a.endedAt!.difference(a.startedAt))})';
    case 'toilet':
      text = toiletLabels[d['kind']] ?? '';
    case 'play':
      text = (d['activity'] as String?) ?? '';
    case 'medical':
      text = switch (d['kind']) {
        'temperature' => 'Suhu ${(d['temperature_c'] as num?)?.toStringAsFixed(1)}°C',
        'medicine' => 'Obat: ${d['medicine']}',
        'injury' => 'Cedera ringan',
        _ => 'Catatan kesehatan',
      };
    default:
      text = '';
  }
  final notes = a.notes?.trim() ?? '';
  if (notes.isNotEmpty) text = text.isEmpty ? notes : '$text\n$notes';
  return text;
}

Map<String, dynamic> _details(String json) {
  try {
    final v = jsonDecode(json);
    return v is Map<String, dynamic> ? v : const {};
  } catch (_) {
    return const {};
  }
}

/// Nickname, else first name — what caregivers call the child.
String displayName(ChildEntity c) =>
    (c.nickname?.trim().isNotEmpty ?? false) ? c.nickname!.trim() : c.fullName.trim().split(' ').first;

String initials(ChildEntity c) {
  final parts = c.fullName.trim().split(RegExp(r'\s+'));
  final first = parts.first.isNotEmpty ? parts.first[0] : '?';
  final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (first + second).toUpperCase();
}
