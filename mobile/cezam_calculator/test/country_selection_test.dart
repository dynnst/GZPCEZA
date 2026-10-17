import 'package:cezam_calculator/main.dart';
import 'package:cezam_calculator/country_codes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('yakindaki oncelikli ulkeler listenin basinda yer alir', () {
    final countries = countriesForSelection([
      'Fransa',
      'Almanya',
      'Yunanistan',
      'Bulgaristan',
      '\u0130ran',
      'Rusya Federasyonu',
      'G\u00fcrcistan',
    ]);

    expect(
      countries.take(5),
      [
        'Rusya Federasyonu',
        '\u0130ran',
        'Bulgaristan',
        'Yunanistan',
        'Almanya',
      ],
    );
    expect(
      countryDisplayName('Rusya Federasyonu'),
      startsWith(String.fromCharCodes([0x1F1F7, 0x1F1FA])),
    );
    expect(
      countryDisplayName('\u0130ran'),
      startsWith(String.fromCharCodes([0x1F1EE, 0x1F1F7])),
    );
  });

  test('veri paketindeki butun ulke ve bolgelerin bayrak kodu vardir', () {
    expect(countryCodes, hasLength(248));
    for (final country in countryCodes.keys) {
      expect(countryDisplayName(country), isNot(country));
    }
  });
}
