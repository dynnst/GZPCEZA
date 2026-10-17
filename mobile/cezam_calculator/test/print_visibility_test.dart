import 'package:cezam_calculator/app_localizations.dart';
import 'package:cezam_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('print button is hidden for non-admin users', (tester) async {
    await tester.pumpWidget(_app(showPrint: false));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.print), findsNothing);
    expect(find.text('Yazdır / PDF'), findsNothing);
  });

  testWidgets('print button is visible for admin users', (tester) async {
    await tester.pumpWidget(_app(showPrint: true));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.print, skipOffstage: false), findsOneWidget);
    expect(find.text('Yazdır / PDF', skipOffstage: false), findsOneWidget);
  });
}

Widget _app({required bool showPrint}) => MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: SingleChildScrollView(
          child: ResultCard(
            result: _result,
            onPrint: () {},
            showPrint: showPrint,
          ),
        ),
      ),
    );

final _result = PenaltyResult(
  stayDays: 100,
  allowedStayDays: 90,
  penaltyMonths: 0,
  penaltyDays: 10,
  ticketText: '10 Gun',
  referenceExitDate: DateTime(2026, 6, 29),
  shouldExitDate: DateTime(2026, 6, 19),
  penaltyAmount: 0,
  currency: 'TRY',
  exchangeRate: 1,
  penaltyTry: 0,
  visaFee: 0,
  defter: 0,
  administrativeFine: 0,
  total: 0,
  tahditCode: '---',
  idariTahditCode: '---',
  tahditPenaltyDays: 0,
);
