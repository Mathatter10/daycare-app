import 'package:daycare_app/core/dates.dart';
import 'package:daycare_app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Color _labelColor(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).text.style!.color!;

void main() {
  testWidgets('chip labels are readable (not white on the white chip)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: Column(
            children: [
              ActionChip(label: const Text('Habis semua'), onPressed: () {}),
              ChoiceChip(label: const Text('Suhu'), selected: true, onSelected: (_) {}),
              ChoiceChip(label: const Text('Obat'), selected: false, onSelected: (_) {}),
            ],
          ),
        ),
      ),
    );
    for (final label in ['Habis semua', 'Suhu', 'Obat']) {
      expect(_labelColor(tester, label), isNot(Colors.white), reason: label);
    }
  });

  test('durationLabel never shows "0 m"', () {
    expect(durationLabel(const Duration(seconds: 20)), '< 1 m');
    expect(durationLabel(const Duration(minutes: 40)), '40 m');
    expect(durationLabel(const Duration(minutes: 75)), '1 j 15 m');
    expect(durationLabel(const Duration(hours: 2)), '2 j');
  });
}
