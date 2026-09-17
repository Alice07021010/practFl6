import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/role_api.dart';
import '../models/app_user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _future = context.read<RoleApi>().users();

  Future<void> _change(AppUser user, Role role) async {
    try {
      await context.read<RoleApi>().changeRole(user.id, role);
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
      appBar: AppBar(title: const Text('Пользователи и роли')),
      body: FutureBuilder<List<AppUser>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final users = snapshot.data ?? const [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                child: ListTile(
                  title: Text(user.displayName),
                  subtitle: Text('@${user.username}'),
                  trailing: DropdownButton<Role>(
                    value: user.role,
                    onChanged: (role) {
                      if (role != null) _change(user, role);
                    },
                    items: Role.values
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.label),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
