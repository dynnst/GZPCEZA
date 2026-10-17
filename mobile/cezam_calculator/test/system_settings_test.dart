import 'dart:convert';

import 'package:cezam_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('system settings show names instead of numeric type codes',
      (tester) async {
    final data = CezamData(
      generatedAt: null,
      exchange: const {'USD': 1, 'EUR': 1, 'GBP': 1, 'TRY': 1},
      defterPrice: 0,
      embeddedCountries: const ['Almanya'],
      tgvh: const [],
      uvr: const [],
      auh: const [],
      tkod: const [],
    );

    await tester
        .pumpWidget(MaterialApp(home: SystemSettingsPage(initialData: data)));

    expect(find.text('Normal Hesaplama'), findsOneWidget);
    expect(find.text('Vizesiz'), findsOneWidget);
    expect(find.text('Tip 1'), findsNothing);
    expect(find.text('Vize kodu 2'), findsNothing);
  });

  test('birth date determines child status at the 18 year boundary', () {
    final today = DateTime(2026, 6, 27);

    expect(isChildOn(DateTime(2008, 6, 28), today), isTrue);
    expect(isChildOn(DateTime(2008, 6, 27), today), isFalse);
    expect(isChildOn(DateTime(2008, 6, 26), today), isFalse);
  });

  test('system settings survive a local JSON round trip', () {
    final data = CezamData(
      generatedAt: '2026-06-27T10:00:00',
      exchange: const {'USD': 42.5, 'EUR': 49.25, 'GBP': 57, 'TRY': 1},
      defterPrice: 1250,
      embeddedCountries: const ['Almanya'],
      tgvh: const [TgvhRule(year: '2026', price: 9376.40)],
      uvr: const [
        UvrRule(
          country: 'Almanya',
          calculateType: 1,
          passportType: 1,
          visaStatus: 2,
          day: 180,
          longStay: 90,
          oneTime: 60,
          visaFeeEnabled: 1,
        ),
      ],
      auh: const [
        AuhRule(
          country: 'Almanya',
          firstMonth: 25,
          monthStep: 5,
          dayStart: 10,
          dayStep: 1,
          currency: 'USD',
        ),
      ],
      tkod: const [
        TkodRule(
          code: 'C-101',
          penaltyTime: 90,
          start: 11,
          finish: 89,
          idariCode: 'N-120',
          paidType: 0,
        ),
      ],
    );

    final restored = CezamData.fromJson(
      jsonDecode(jsonEncode(data.toJson())) as Map<String, dynamic>,
    );

    expect(restored.findUvr('Almanya', 1, 2, 1)?.oneTime, 60);
    expect(restored.findAuh('Almanya')?.firstMonth, 25);
    expect(restored.exchange['USD'], 42.5);
    expect(restored.defterPrice, 1250);
    expect(restored.findTkod(30, 0)?.code, 'C-101');
  });

  test('system settings JSON contains no passenger personal data fields', () {
    final encoded = jsonEncode(CezamData.empty().toJson()).toLowerCase();

    for (final forbiddenKey in [
      'passportno',
      'birthdate',
      'entrydate',
      'exitdate',
      'passengername',
      'calculationresult',
    ]) {
      expect(encoded, isNot(contains(forbiddenKey)));
    }
  });
}
