import 'package:daycare_app/core/api_client.dart';
import 'package:daycare_app/core/dates.dart';
import 'package:daycare_app/core/labels.dart';
import 'package:daycare_app/data/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

ActivityEntity _a(String type, String details, {DateTime? start, DateTime? end, String? notes}) => ActivityEntity()
  ..id = 'x'
  ..childId = 'c'
  ..type = type
  ..startedAt = start ?? DateTime(2026, 10, 15, 9, 15)
  ..endedAt = end
  ..detailsJson = details
  ..notes = notes;

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  test('describeActivity matches the parent-facing wording', () {
    expect(describeActivity(_a('eat', '{"portion":"half","menu":"Bubur ayam"}')), 'Setengah porsi · Bubur ayam');
    expect(describeActivity(_a('toilet', '{"kind":"both"}')), 'Pipis dan BAB');
    expect(describeActivity(_a('sleep', '{}')), 'Sedang tidur');
    expect(
      describeActivity(_a('sleep', '{}', start: DateTime(2026, 10, 15, 9, 15), end: DateTime(2026, 10, 15, 10, 30))),
      '09:15–10:30 (1 j 15 m)',
    );
    expect(describeActivity(_a('medical', '{"kind":"temperature","temperature_c":37.8}')), 'Suhu 37.8°C');
    expect(describeActivity(_a('play', '{}', notes: 'Main balok')), 'Main balok');
    expect(describeActivity(_a('eat', 'not json')), '');
  });

  test('displayName prefers nickname, else first name', () {
    final c = ChildEntity()
      ..id = 'c'
      ..fullName = 'Citra Ayu Lestari'
      ..dateOfBirth = '2024-01-01'
      ..className = 'X';
    expect(displayName(c), 'Citra');
    expect(initials(c), 'CA');
    expect(displayName(c..nickname = 'Caca'), 'Caca');
  });

  test('durationLabel and dayKey', () {
    expect(durationLabel(const Duration(minutes: 40)), '40 m');
    expect(durationLabel(const Duration(minutes: 120)), '2 j');
    expect(dayKey(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
  });

  test('ApiException decides what to retry', () {
    expect(ApiException('offline').isRetryable, isTrue);
    expect(ApiException('busy', status: 503).isRetryable, isTrue);
    expect(ApiException('slow down', status: 429).isRetryable, isTrue);
    expect(ApiException('bad', status: 422).isRetryable, isFalse);
    expect(ApiException('gone', status: 404).isRetryable, isFalse);
  });
}
