import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/role_api.dart';
import '../models/loan.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  late Future<List<Loan>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = context.read<RoleApi>().myLoans();
  }

  Future<void> _renew(Loan loan) async {
    try {
      await context.read<RoleApi>().renew(loan.id);
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Срок выдачи продлён.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои выдачи')),
      body: FutureBuilder<List<Loan>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final items = snapshot.data ?? const [];
          if (items.isEmpty) return const Center(child: Text('Выдач пока нет'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final loan = items[index];
              return Card(
                child: ListTile(
                  title: Text(loan.bookTitle),
                  subtitle: Text(
                    'Выдано: ${loan.issuedAt.toLocal().toString().substring(0, 10)}\n'
                    'Вернуть до: ${loan.dueAt.toLocal().toString().substring(0, 10)}',
                  ),
                  trailing: loan.isOpen
                      ? FilledButton(
                          onPressed: () => _renew(loan),
                          child: const Text('Продлить'),
                        )
                      : const Chip(label: Text('Возвращена')),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
