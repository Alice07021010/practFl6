import 'package:flutter_test/flutter_test.dart';
import 'package:tmyv_deneg_web/logic/calculator.dart';

void main() {
  group('calculate', () {
    test('сложение', () {
      final result = calculate('2', '+', '3') as CalcSuccess;
      expect(result.value, 5);
    });

    test('вычитание', () {
      final result = calculate('7', '-', '4') as CalcSuccess;
      expect(result.value, 3);
    });

    test('умножение', () {
      final result = calculate('6', '*', '5') as CalcSuccess;
      expect(result.value, 30);
    });

    test('деление', () {
      final result = calculate('10', '/', '4') as CalcSuccess;
      expect(result.value, 2.5);
    });

    test('деление на ноль', () {
      final result = calculate('10', '/', '0');
      expect(result, isA<CalcFailure>());
    });

    test('нечисловой ввод', () {
      final result = calculate('abc', '+', '2');
      expect(result, isA<CalcFailure>());
    });

    test('неизвестная операция', () {
      final result = calculate('2', '^', '3');
      expect(result, isA<CalcFailure>());
    });

    test('отсутствует операция', () {
      final result = calculate('2', null, '3');
      expect(result, isA<CalcFailure>());
    });
  });

  test('разумное округление результата', () {
    expect(formatNumber(10 / 3), '3.333333');
    expect(formatNumber(5.0), '5');
  });
}
