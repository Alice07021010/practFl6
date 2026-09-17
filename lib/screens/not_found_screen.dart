import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class NotFoundScreen extends StatelessWidget {
  final String location;
  final ThemeController themeController;

  const NotFoundScreen({
    super.key,
    required this.location,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ошибка 404'),
        actions: [ThemeButton(controller: themeController)],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.travel_explore, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Страница не найдена',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                SelectableText(location, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: const Text('На главную'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
