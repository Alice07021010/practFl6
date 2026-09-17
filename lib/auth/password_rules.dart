class PasswordRules {
  static bool minLength(String value) => value.length >= 8;
  static bool hasDigit(String value) => RegExp(r'\d').hasMatch(value);
  static bool hasSpecial(String value) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=]').hasMatch(value);

  static bool strong(String value) =>
      minLength(value) && hasDigit(value) && hasSpecial(value);
}
