import 'package:intl/intl.dart';

/// Calendar-day key as used by the API (yyyy-MM-dd, device local time).
String dayKey(DateTime t) => DateFormat('yyyy-MM-dd').format(t.toLocal());

DateTime startOfDay(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// "09:15"
String hm(DateTime t) => DateFormat.Hm().format(t.toLocal());

/// "Kamis, 15 Okt"
String dayLabel(DateTime t) => DateFormat('EEEE, d MMM', 'id_ID').format(t.toLocal());

/// "1 j 15 m", "40 m"
String durationLabel(Duration d) {
  final mins = d.inMinutes;
  if (mins < 60) return '$mins m';
  final h = mins ~/ 60, m = mins % 60;
  return m == 0 ? '$h j' : '$h j $m m';
}

/// RFC 3339 in UTC, as the API expects.
String toApiTime(DateTime t) => t.toUtc().toIso8601String();
