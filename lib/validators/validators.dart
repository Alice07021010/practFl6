String? requiredText(String? value, {String message = 'Обязательное поле'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? textLength(String? value, {int min = 2, int max = 120}) {
  final req = requiredText(value);
  if (req != null) return req;
  final n = value!.trim().length;
  if (n < min) return 'Минимум $min символа';
  if (n > max) return 'Максимум $max символов';
  return null;
}

String? intRange(String? value, {required int min, required int max}) {
  final v = int.tryParse(value?.trim() ?? '');
  if (v == null) return 'Введите целое число';
  if (v < min || v > max) return 'Допустимо от $min до $max';
  return null;
}

String? positiveInt(String? value, {bool allowZero = false}) {
  final v = int.tryParse(value?.trim() ?? '');
  if (v == null) return 'Введите целое число';
  if (allowZero ? v < 0 : v <= 0) return allowZero ? 'Число не может быть отрицательным' : 'Число должно быть больше нуля';
  return null;
}

String? emailValidator(String? value) {
  final req = requiredText(value);
  if (req != null) return req;
  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim());
  return ok ? null : 'Неверный формат электронной почты';
}

String? isbnValidator(String? value) {
  final req = requiredText(value);
  if (req != null) return req;
  return RegExp(r'^[0-9\-]{10,20}$').hasMatch(value!.trim()) ? null : 'ISBN должен содержать цифры и дефисы';
}
