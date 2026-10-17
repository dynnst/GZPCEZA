import 'package:cezam_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('manuel kural ve tutarlar sistem ayarlarinda yer alir',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: SystemSettingsPage(initialData: _data())),
    );

    expect(find.text('Manuel'), findsOneWidget);
    await tester.tap(find.text('Manuel'));
    await tester.pumpAndSettle();

    expect(find.text('Bir seferde kal\u0131\u015f (g\u00fcn)'), findsOneWidget);
    expect(find.text('Manuel Ceza Tutar\u0131'), findsOneWidget);
  });
}

CezamData _data() => CezamData(
      generatedAt: null,
      exchange: const {'USD': 1, 'EUR': 1, 'GBP': 1, 'TRY': 1},
      defterPrice: 0,
      embeddedCountries: const ['Test'],
      tgvh: const [],
      uvr: const [],
      auh: const [],
      tkod: const [],
    );
