import 'package:cezam_calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PenaltyCalculator 180 gun penceresi', () {
    test('coklu kayitta pencere disindaki gunleri tamamen yok sayar', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 30)),
          DateRange(DateTime(2026, 3, 20), DateTime(2026, 6, 27)),
        ]),
        _data(),
      );

      expect(result.stayDays, 100);
      expect(result.ticketText, '10 Gun');
    });

    test('tek kayitta eski gun farki mantigini korur', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 3, 20), DateTime(2026, 6, 27)),
        ]),
        _data(),
      );

      expect(result.stayDays, 99);
      expect(result.ticketText, '9 Gun');
    });

    test('33 gunluk ihlali 2 ay ve toplam 33 gun olarak korur', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 1, 1), DateTime(2026, 5, 4)),
        ]),
        _data(code: '\u00c7-113', penaltyTime: 365),
      );

      expect(result.ticketText, '2 Ay');
      expect(result.violationDays, 33);
      expect(result.hasEntryBan, isTrue);
      expect(
        result.earliestReEntryDate(DateTime(2026, 5, 4)),
        DateTime(2027, 5, 4),
      );
    });
  });
}

PenaltySettings _settings(List<DateRange> ranges) => PenaltySettings(
      country: 'Test',
      passport: 1,
      visa: 2,
      consularVisaDays: 0,
      calculateType: 2,
      adultType: 2,
      entryExitPairs: ranges,
      manualRule: const UvrRule(
        country: 'Test',
        calculateType: 2,
        passportType: 1,
        visaStatus: 2,
        day: 180,
        longStay: 90,
        oneTime: 90,
        visaFeeEnabled: 0,
      ),
      manualAuh: const AuhRule(
        country: 'Test',
        firstMonth: 0,
        monthStep: 0,
        dayStart: 0,
        dayStep: 0,
        currency: 'TRY',
      ),
      exchange: const {'TRY': 1},
      defterPrice: 0,
      visaFee: 0,
      paymentType: 1,
    );

CezamData _data({String code = 'TEST', int penaltyTime = 1}) => CezamData(
      generatedAt: null,
      exchange: const {'TRY': 1},
      defterPrice: 0,
      embeddedCountries: const [],
      tgvh: const [],
      uvr: const [],
      auh: const [],
      tkod: [
        TkodRule(
          code: code,
          penaltyTime: penaltyTime,
          start: 1,
          finish: 999,
          idariCode: 'TEST',
          paidType: 1,
        ),
      ],
    );
