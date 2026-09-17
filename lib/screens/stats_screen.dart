import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/role_api.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: context.read<RoleApi>().stats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final data = snapshot.data ?? const {};
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: GridView.count(
                padding: const EdgeInsets.all(24),
                shrinkWrap: true,
                crossAxisCount: MediaQuery.sizeOf(context).width < 700 ? 1 : 3,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: data.entries
                    .map(
                      (e) => Card(
                        child: Center(
                          child: ListTile(
                            title: Text('${e.value}', textAlign: TextAlign.center),
                            subtitle: Text(e.key, textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
