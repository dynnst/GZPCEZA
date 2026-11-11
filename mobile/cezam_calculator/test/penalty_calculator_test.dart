import 'package:cezam_calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PenaltyCalculator 180 gun penceresi ve coklu girisler', () {
    test('Polnet Norvec ornegi: 80 gun ve 19 gun kalis ile tam 9 gun ceza verir', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 3, 7), DateTime(2026, 5, 26)),
          DateRange(DateTime(2026, 8, 15), DateTime(2026, 11, 3)),
        ]),
        _data(),
      );

      expect(result.stayDays, 99);
      expect(result.ticketText, '9 Gun');
    });

    test('coklu kayitta pencere disindaki gunleri tamamen yok sayar', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 30)),
          DateRange(DateTime(2026, 3, 20), DateTime(2026, 6, 27)),
        ]),
        _data(),
      );

      expect(result.stayDays, 99);
      expect(result.ticketText, '9 Gun');
    });

    test('coklu girislerde calculateType 1 (Normal) dahi olsa 180 gun penceresi uygulanir (web AjaxController.cs uyumu)', () {
      // 2026-06-27 cikisina gore 180 gun oncesi 2025-12-29'dur. 2025-01-01'deki sefer 180 gun disinda oldugundan 0 sayilir.
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 30)),
          DateRange(DateTime(2026, 3, 20), DateTime(2026, 6, 27)),
        ], calculateType: 1),
        _data(),
      );

      expect(result.stayDays, 99);
      expect(result.ticketText, '9 Gun');
    });

    test('normal hesaplamada (calculateType: 1) 180 gun icindeki parcali seferleri eksiksiz toplar', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 9, 13), DateTime(2026, 10, 27)), // 44 gun
          DateRange(DateTime(2026, 4, 30), DateTime(2026, 6, 16)), // 47 gun
        ], calculateType: 1),
        _data(),
      );

      expect(result.stayDays, 91);
      expect(result.ticketText, '1 Gun');
    });

    test('Rusya Federasyonu coklu giris: tek sefer 60 gun, donem 90 gun kuralini uygular', () {
      // Sefer 1: 70 gun (60 gunu 10 gun asiyor)
      // Sefer 2: 15 gun
      // Toplam: 85 gun (90 gunu asmiyor). Tek sefer asimi = 10 gun. Ceza = max(10, 0) = 10 gun.
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 5, 1), DateTime(2026, 7, 10)), // 70 gun
          DateRange(DateTime(2026, 8, 1), DateTime(2026, 8, 16)), // 15 gun
        ], country: 'Rusya Federasyonu', oneTime: 60, longStay: 90),
        _data(),
      );

      expect(result.stayDays, 85);
      expect(result.ticketText, '10 Gun');
    });

    test('Beyaz Rusya: 365 gun kayan pencere ve tek sefer 30 gun kuralini uygular', () {
      // Sefer 1: 35 gun (30 gunu 5 gun asiyor)
      // Sefer 2: 20 gun
      // Toplam: 55 gun (90 gunu asmiyor). Ceza = max(5, 0) = 5 gun.
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 3, 1), DateTime(2026, 4, 5)), // 35 gun
          DateRange(DateTime(2026, 8, 1), DateTime(2026, 8, 21)), // 20 gun
        ], country: 'Beyaz Rusya', oneTime: 30, longStay: 90, day: 365),
        _data(),
      );

      expect(result.stayDays, 55);
      expect(result.ticketText, '5 Gun');
    });

    test('Ikamet tezkereli (visa: 4) teblig/bitis tarihinden cikisa kadar tum gunleri cezali sayar', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 5, 1), DateTime(2026, 5, 20)), // 19 gun ihlal
        ], visa: 4),
        _data(),
      );

      expect(result.penaltyDays, 19);
      expect(result.ticketText, '19 Gun');
      expect(result.shouldExitDate, DateTime(2026, 5, 1));
    });

    test('Turkiye\'de dogan cocuklar (visa: 5) vize hakki 0 gun ve dogumdan cikisa kadar cezali', () {
      final result = PenaltyCalculator().calculate(
        _settings([
          DateRange(DateTime(2026, 1, 1), DateTime(2026, 2, 10)), // 40 gun
        ], visa: 5),
        _data(),
      );

      expect(result.stayDays, 40);
      expect(result.allowedStayDays, 0);
      expect(result.ticketText, '2 Ay');
      expect(result.shouldExitDate, DateTime(2026, 1, 1));
    });

    test('180/90 (calculateType: 2) kurali icin ozel uvr kaydi yoksa calculateType: 1 kuralina otomatik duser', () {
      final customData = CezamData(
        generatedAt: null,
        exchange: const {'TRY': 1},
        defterPrice: 0,
        embeddedCountries: const [],
        tgvh: const [],
        uvr: const [
          UvrRule(
            country: 'FallbackTest',
            calculateType: 1, // Sadece 1 var, 2 yok
            passportType: 1,
            visaStatus: 2,
            day: 180,
            longStay: 90,
            oneTime: 90,
            visaFeeEnabled: 0,
          ),
        ],
        auh: const [
          AuhRule(
            country: 'FallbackTest',
            firstMonth: 0,
            monthStep: 0,
            dayStart: 0,
            dayStep: 0,
            currency: 'TRY',
          ),
        ],
        tkod: const [
          TkodRule(
            code: 'TEST',
            penaltyTime: 1,
            start: 1,
            finish: 999,
            idariCode: 'TEST',
            paidType: 1,
          ),
        ],
      );

      final found = customData.findUvr('FallbackTest', 1, 2, 2);
      expect(found, isNotNull);
      expect(found!.calculateType, 1);
      expect(found.day, 180);
      expect(found.longStay, 90);
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

PenaltySettings _settings(
  List<DateRange> ranges, {
  int calculateType = 2,
  String country = 'Test',
  int visa = 2,
  int oneTime = 90,
  int longStay = 90,
  int day = 180,
}) =>
    PenaltySettings(
      country: country,
      passport: 1,
      visa: visa,
      consularVisaDays: 0,
      calculateType: calculateType,
      adultType: 2,
      entryExitPairs: ranges,
      manualRule: UvrRule(
        country: country,
        calculateType: calculateType,
        passportType: 1,
        visaStatus: visa,
        day: day,
        longStay: longStay,
        oneTime: oneTime,
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
