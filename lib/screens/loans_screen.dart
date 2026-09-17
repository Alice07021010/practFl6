import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/role_api.dart';
import '../models/loan.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  late Future<List<Loan>> _future;
  final _bookId = TextEditingController();
  final _readerId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<RoleApi>().allLoans();

  @override
  void dispose() {
    _bookId.dispose();
    _readerId.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    final bookId = int.tryParse(_bookId.text);
    final readerId = int.tryParse(_readerId.text);
    if (bookId == null || readerId == null) return;
    try {
      await context.read<RoleApi>().issue(bookId: bookId, readerId: readerId);
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выдача оформлена.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _close(int id) async {
    try {
      await context.read<RoleApi>().closeLoan(id);
      if (mounted) setState(_reload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выдачи книг')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _bookId,
                        decoration: const InputDecoration(labelText: 'ID книги'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _readerId,
                        decoration: const InputDecoration(labelText: 'ID читателя'),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _issue,
                      icon: const Icon(Icons.add),
                      label: const Text('Оформить выдачу'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Loan>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? const [];
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final loan = items[index];
                      return Card(
                        child: ListTile(
                          title: Text(loan.bookTitle),
                          subtitle: Text('${loan.readerName} · до ${loan.dueAt.toLocal().toString().substring(0, 10)}'),
                          trailing: loan.isOpen
                              ? FilledButton.tonal(
                                  onPressed: () => _close(loan.id),
                                  child: const Text('Закрыть'),
                                )
                              : const Text('Закрыта'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
