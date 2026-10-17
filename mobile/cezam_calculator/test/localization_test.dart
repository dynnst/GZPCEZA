import 'package:cezam_calculator/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Arabic and Persian interfaces use RTL', (tester) async {
    for (final language in ['ar', 'fa']) {
      late TextDirection direction;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(builder: (context) {
            direction = Directionality.of(context);
            return Text(context.tr('calculate'));
          }),
        ),
      );
      await tester.pumpAndSettle();
      expect(direction, TextDirection.rtl);
    }
  });

  test('all supported languages contain core calculator text', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final strings = await AppLocalizations.delegate.load(locale);
      expect(strings.text('calculate'), isNot('calculate'));
      expect(strings.text('earliest_reentry'), isNot('earliest_reentry'));
      expect(strings.text('error_date_order'), isNot('error_date_order'));
      expect(strings.text('msg_login_required'), isNot('msg_login_required'));
    }
  });
}
