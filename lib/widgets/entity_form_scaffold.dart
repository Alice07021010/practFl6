import 'package:flutter/material.dart';

class EntityFormScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool dirty;
  final bool saving;
  final VoidCallback onSave;
  final Future<void> Function() onLeaveRequested;

  const EntityFormScaffold({super.key, required this.title, required this.child, required this.dirty, required this.saving, required this.onSave, required this.onLeaveRequested});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && dirty) onLeaveRequested();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(child: Padding(padding: const EdgeInsets.all(24), child: child)),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
              label: Text(saving ? 'Сохранение...' : 'Сохранить'),
            ),
          ),
        ),
      ),
    );
  }
}
