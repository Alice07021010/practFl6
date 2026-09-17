import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart' show formatNumber;
import '../logic/currency.dart';
import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class ConverterResultScreen extends StatelessWidget {
  final Map<String, String> query;
  final ThemeController themeController;

  const ConverterResultScreen({
    super.key,
    required this.query,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final rawAmount = query['amount'];
    final from = query['from'];
    final to = query['to'];
    final result = convertCurrency(rawAmount, from, to);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат конвертации'),
        actions: [ThemeButton(controller: themeController)],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Данные результата взяты из адресной строки',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        'amount=${rawAmount ?? '(нет)'}   from=${from ?? '(нет)'}   to=${to ?? '(нет)'}',
                      ),
                      const SizedBox(height: 20),
                      switch (result) {
                        CurrencySuccess(:final value) => Text(
                            '${rawAmount ?? '?'} ${from ?? '?'} = ${formatNumber(value, digits: 4)} ${to ?? '?'}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        CurrencyFailure(:final message) => Column(
                            children: [
                              const Icon(Icons.error_outline, size: 44),
                              const SizedBox(height: 8),
                              Text(
                                message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                      },
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.go('/converter'),
                        child: const Text('Вернуться к конвертеру'),
                      ),
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
    );
  }
}
