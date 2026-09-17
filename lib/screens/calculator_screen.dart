import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class CalculatorScreen extends StatefulWidget {
  final ThemeController themeController;

  const CalculatorScreen({super.key, required this.themeController});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _operation = '+';

  static const _operations = ['+', '-', '*', '/'];

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Введите число';
    if (double.tryParse(value.replaceAll(',', '.')) == null) {
      return 'Это не число';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri(
      path: '/calculator/result',
      queryParameters: {
        'a': _aController.text.replaceAll(',', '.'),
        'op': _operation,
        'b': _bController.text.replaceAll(',', '.'),
      },
    );
    context.go(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
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
                          'Калькулятор расчётных операций',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Введите два числа и выберите одну из четырёх операций. Результат откроется на отдельном адресе.',
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _aController,
                          decoration: const InputDecoration(
                            labelText: 'Первое число',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: _numberValidator,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _operation,
                          decoration: const InputDecoration(
                            labelText: 'Операция',
                          ),
                          items: _operations
                              .map(
                                (operation) => DropdownMenuItem(
                                  value: operation,
                                  child: Text(operation),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _operation = value ?? '+');
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bController,
                          decoration: const InputDecoration(
                            labelText: 'Второе число',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: _numberValidator,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.calculate),
                          label: const Text('Вычислить'),
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
}
