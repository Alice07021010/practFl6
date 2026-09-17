import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_notifier.dart';
import '../models/app_user.dart';

class AdaptiveAppFrame extends StatelessWidget {
  final Widget child;
  final GoRouter router;

  const AdaptiveAppFrame({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final items = _items(auth);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final content = Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width >= 1600
                  ? 1500
                  : double.infinity,
            ),
            child: child,
          ),
        );

        // Телефон
        if (width < 600) {
          final bottomItems =
              items.take(5).toList();

          return Scaffold(
            body: content,
            bottomNavigationBar:
                NavigationBar(
              selectedIndex: 0,
              onDestinationSelected:
                  (index) {
                router.go(
                  bottomItems[index].route,
                );
              },
              destinations: [
                for (final item
                    in bottomItems)
                  NavigationDestination(
                    icon:
                        Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        // Планшет / компьютер
        final extended = width >= 1100;

        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: 0,
                onDestinationSelected:
                    (index) {
                  router.go(
                    items[index].route,
                  );
                },
                labelType: extended
                    ? NavigationRailLabelType
                        .none
                    : NavigationRailLabelType
                        .selected,
                destinations: [
                  for (final item in items)
                    NavigationRailDestination(
                      icon:
                          Icon(item.icon),
                      label:
                          Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(
                width: 1,
              ),
              Expanded(
                child: content,
              ),
            ],
          ),
        );
      },
    );
  }

  List<_NavItem> _items(
    AuthNotifier auth,
  ) {
    final result = <_NavItem>[
      const _NavItem(
        'Главная',
        Icons.home_outlined,
        '/',
      ),

      if (auth.can(
        Permission.viewCatalog,
      ))
        const _NavItem(
          'Книги',
          Icons.menu_book_outlined,
          '/books',
        ),

      if (auth.can(
        Permission.viewOwnLoans,
      ))
        const _NavItem(
          'Мои выдачи',
          Icons.bookmark_outline,
          '/my-loans',
        ),

      if (auth.can(
        Permission.manageLoans,
      ))
        const _NavItem(
          'Выдачи',
          Icons
              .assignment_turned_in_outlined,
          '/loans',
        ),

      if (auth.can(
        Permission.manageReaders,
      ))
        const _NavItem(
          'Читатели',
          Icons.badge_outlined,
          '/readers',
        ),

      if (auth.can(
        Permission.manageReferences,
      ))
        const _NavItem(
          'Авторы',
          Icons.people_alt_outlined,
          '/authors',
        ),

      if (auth.can(
        Permission.manageUsers,
      ))
        const _NavItem(
          'Пользователи',
          Icons
              .admin_panel_settings_outlined,
          '/admin/users',
        ),

      if (auth.can(
        Permission.viewStats,
      ))
        const _NavItem(
          'Статистика',
          Icons.query_stats_outlined,
          '/admin/stats',
        ),
    ];

    return result;
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem(
    this.label,
    this.icon,
    this.route,
  );
}