import 'package:flutter_test/flutter_test.dart';
import 'package:tmyv_deneg_web/logic/currency.dart';

void main() {
  group('convertCurrency', () {
    test('одинаковая валюта не меняет сумму', () {
      final result = convertCurrency('125', 'RUB', 'RUB') as CurrencySuccess;
      expect(result.value, 125);
    });

    test('RUB в USD считается по константе', () {
      final result = convertCurrency('930', 'RUB', 'USD') as CurrencySuccess;
      expect(result.value, 10);
    });

    test('нечисловая сумма даёт ошибку', () {
      expect(convertCurrency('x', 'RUB', 'USD'), isA<CurrencyFailure>());
    });

    test('отрицательная сумма даёт ошибку', () {
      expect(convertCurrency('-1', 'RUB', 'USD'), isA<CurrencyFailure>());
    });

    test('неизвестная валюта даёт ошибку', () {
      expect(convertCurrency('10', 'AAA', 'USD'), isA<CurrencyFailure>());
    });

    test('отсутствующая валютная пара даёт ошибку', () {
      expect(convertCurrency('10', null, 'USD'), isA<CurrencyFailure>());
    });
  });
}
