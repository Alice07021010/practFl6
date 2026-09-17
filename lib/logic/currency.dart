sealed class CurrencyResult {
  const CurrencyResult();
}

class CurrencySuccess extends CurrencyResult {
  final double value;
  const CurrencySuccess(this.value);
}

class CurrencyFailure extends CurrencyResult {
  final String message;
  const CurrencyFailure(this.message);
}

// Учебные фиксированные курсы: сколько рублей условно соответствует 1 единице.
const ratesToRub = <String, double>{
  'RUB': 1.0,
  'USD': 93.0,
  'EUR': 101.0,
  'CNY': 12.8,
  'GBP': 120.0,
  'KZT': 0.19,
};

CurrencyResult convertCurrency(
  String? rawAmount,
  String? from,
  String? to,
) {
  final amount = double.tryParse(rawAmount?.replaceAll(',', '.') ?? '');

  if (amount == null) {
    return const CurrencyFailure('В адресе передана некорректная сумма');
  }
  if (amount < 0) {
    return const CurrencyFailure('Сумма не может быть отрицательной');
  }
  if (from == null || to == null) {
    return const CurrencyFailure('Не указана валютная пара');
  }

  final fromRate = ratesToRub[from];
  final toRate = ratesToRub[to];
  if (fromRate == null || toRate == null) {
    return const CurrencyFailure('Передан неизвестный код валюты');
  }

  return CurrencySuccess(amount * fromRate / toRate);
}
