import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPair {
  final String from;
  final String to;

  const CurrencyPair(this.from, this.to);
}

class CurrencyPreferences {
  static const _fromKey = 'currency_from';
  static const _toKey = 'currency_to';

  Future<CurrencyPair> load() async {
    final prefs = await SharedPreferences.getInstance();
    return CurrencyPair(
      prefs.getString(_fromKey) ?? 'RUB',
      prefs.getString(_toKey) ?? 'USD',
    );
  }

  Future<void> save(String from, String to) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fromKey, from);
    await prefs.setString(_toKey, to);
  }
}
