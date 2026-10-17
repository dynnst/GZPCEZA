import 'package:cezam_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('CEZAM calculator opens in Turkish', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CezamApp());
    await tester.pumpAndSettle();

    expect(find.text('Vize İhlal'), findsOneWidget);
    expect(find.text('Tarih ve Tür'), findsOneWidget);
  });

  testWidgets('language selector changes and persists the interface language',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CezamApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🇬🇧 English'));
    await tester.pumpAndSettle();

    expect(find.text('Visa Overstay'), findsOneWidget);
    expect(find.text('Dates and Type'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('appLanguage'), 'en');
  });
}
