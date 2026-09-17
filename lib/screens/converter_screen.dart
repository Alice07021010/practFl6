import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/currency.dart';
import '../services/currency_preferences.dart';
import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class ConverterScreen extends StatefulWidget {
  final ThemeController themeController;

  const ConverterScreen({super.key, required this.themeController});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _preferences = CurrencyPreferences();
  String _from = 'RUB';
  String _to = 'USD';

  @override
  void initState() {
    super.initState();
    _restorePair();
  }

  Future<void> _restorePair() async {
    final pair = await _preferences.load();
    if (!mounted) return;
    setState(() {
      if (ratesToRub.containsKey(pair.from)) _from = pair.from;
      if (ratesToRub.containsKey(pair.to)) _to = pair.to;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String? _amountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите сумму';
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) return 'Это не число';
    if (amount < 0) return 'Сумма не может быть отрицательной';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await _preferences.save(_from, _to);
    if (!mounted) return;

    final uri = Uri(
      path: '/converter/result',
      queryParameters: {
        'amount': _amountController.text.replaceAll(',', '.'),
        'from': _from,
        'to': _to,
      },
    );
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final currencies = ratesToRub.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Конвертер валют'),
        actions: [ThemeButton(controller: widget.themeController)],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Валютный конвертер банка',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Используются фиксированные учебные курсы из кода. Последняя валютная пара сохраняется.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _amountController,
                          decoration: const InputDecoration(labelText: 'Сумма'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: _amountValidator,
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 430;
                            final from = _currencyField(
                              label: 'Из валюты',
                              value: _from,
                              currencies: currencies,
                              onChanged: (value) => setState(() => _from = value),
                            );
                            final to = _currencyField(
                              label: 'В валюту',
                              value: _to,
                              currencies: currencies,
                              onChanged: (value) => setState(() => _to = value),
                            );

                            if (narrow) {
                              return Column(
                                children: [from, const SizedBox(height: 16), to],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: from),
                                const SizedBox(width: 16),
                                Expanded(child: to),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.currency_exchange),
                          label: const Text('Конвертировать'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('На главную'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _currencyField({
    required String label,
    required String value,
    required List<String> currencies,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: currencies
          .map(
            (currency) => DropdownMenuItem(
              value: currency,
              child: Text(currency),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
