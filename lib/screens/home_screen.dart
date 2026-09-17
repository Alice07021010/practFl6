import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_notifier.dart';
import '../core/config.dart';
import '../models/app_user.dart';
import '../services/theme_controller.dart';
import '../widgets/theme_button.dart';

class HomeScreen extends StatelessWidget {
  final ThemeController themeController;

  const HomeScreen({
    super.key,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    final width =
        MediaQuery.sizeOf(context).width;

    final isMobile = width < 600;

    final items = <
        ({
          String title,
          IconData icon,
          String route,
          Permission permission
        })>[
      (
        title: 'Каталог книг',
        icon: Icons.menu_book_outlined,
        route: '/books',
        permission: Permission.viewCatalog,
      ),
      (
        title: 'Мои выдачи',
        icon: Icons.bookmark_outline,
        route: '/my-loans',
        permission: Permission.viewOwnLoans,
      ),
      (
        title: 'Выдачи книг',
        icon:
            Icons.assignment_turned_in_outlined,
        route: '/loans',
        permission: Permission.manageLoans,
      ),
      (
        title: 'Авторы',
        icon: Icons.people_alt_outlined,
        route: '/authors',
        permission:
            Permission.manageReferences,
      ),
      (
        title: 'Жанры',
        icon: Icons.category_outlined,
        route: '/genres',
        permission:
            Permission.manageReferences,
      ),
      (
        title: 'Издательства',
        icon: Icons.apartment_outlined,
        route: '/publishers',
        permission:
            Permission.manageReferences,
      ),
      (
        title: 'Читатели',
        icon: Icons.badge_outlined,
        route: '/readers',
        permission:
            Permission.manageReaders,
      ),
      (
        title: 'Пользователи и роли',
        icon: Icons
            .admin_panel_settings_outlined,
        route: '/admin/users',
        permission: Permission.manageUsers,
      ),
      (
        title: 'Статистика',
        icon: Icons.query_stats_outlined,
        route: '/admin/stats',
        permission: Permission.viewStats,
      ),
    ]
        .where(
          (item) =>
              auth.can(item.permission),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMobile
              ? 'Тмыв денег'
              : 'ООО «Тмыв денег»',
        ),
        actions: [
          ThemeButton(
            controller: themeController,
          ),

          if (!isMobile) ...[
            const SizedBox(width: 6),
            Text(
              auth.user?.displayName ?? '',
            ),
            const SizedBox(width: 10),
            Chip(
              label: Text(
                auth.uiRole.label,
              ),
            ),
          ],

          IconButton(
            onPressed: auth.logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 1100,
          ),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ООО «Тмыв денег»',
                  textAlign:
                      TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Практическая работа №6 · адаптивный интерфейс',
                  textAlign:
                      TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Сервер: $apiBaseUrl',
                  textAlign:
                      TextAlign.center,
                ),
                const SizedBox(height: 22),

                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisCount:
                      width < 700 ? 1 : 2,
                  childAspectRatio:
                      width < 700 ? 2.1 : 2.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: items
                      .map(
                        (item) => Card(
                          child: InkWell(
                            onTap: () {
                              context.go(
                                item.route,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets
                                      .all(18),
                              child: Row(
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 38,
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: Theme
                                              .of(
                                                context,
                                              )
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  const Icon(
                                    Icons
                                        .chevron_right,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    child: Text(
                      'Текущая роль: ${auth.actualRole.label}. '
                      'Интерфейс автоматически перестраивается '
                      'в зависимости от размера экрана.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}