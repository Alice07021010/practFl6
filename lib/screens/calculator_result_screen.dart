import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logic/calculator.dart';
import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class CalculatorResultScreen extends StatelessWidget {
  final Map<String, String> query;
  final ThemeController themeController;

  const CalculatorResultScreen({
    super.key,
    required this.query,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final rawA = query['a'];
    final rawOp = query['op'];
    final rawB = query['b'];
    final result = calculate(rawA, rawOp, rawB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат вычисления'),
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
                        'Параметры восстановлены из URL',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        'a=${rawA ?? '(нет)'}   op=${rawOp ?? '(нет)'}   b=${rawB ?? '(нет)'}',
                      ),
                      const SizedBox(height: 20),
                      switch (result) {
                        CalcSuccess(:final value) => _SuccessBox(
                            text: '${rawA ?? '?'} ${rawOp ?? '?'} ${rawB ?? '?'} = ${formatNumber(value)}',
                          ),
                        CalcFailure(:final message) => _ErrorBox(message: message),
                      },
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => context.go('/calculator'),
                        child: const Text('Вернуться к форме'),
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

class _SuccessBox extends StatelessWidget {
  final String text;
  const _SuccessBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Успешный результат',
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 44),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
