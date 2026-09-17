import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final VoidCallback onReset;
  const EmptyStateView({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 60),
            const SizedBox(height: 12),
            Text('Ничего не найдено', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Попробуйте изменить поиск или фильтры.'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onReset, child: const Text('Сбросить фильтры')),
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onBackToNormal;
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onBackToNormal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text('Ошибка загрузки', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBackToNormal,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Загрузка данных…'),
        ],
      ),
    );
  }
}
