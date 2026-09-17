import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth/auth_notifier.dart';
import 'models/app_user.dart';
import 'models/author_query.dart';
import 'models/book_query.dart';
import 'models/genre.dart';
import 'models/publisher.dart';
import 'models/reader.dart';
import 'models/simple_query.dart';
import 'screens/author_detail_screen.dart';
import 'screens/author_form_screen.dart';
import 'screens/authors_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/books_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/genre_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loans_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_loans_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/publisher_form_screen.dart';
import 'screens/reader_form_screen.dart';
import 'screens/reference_detail_screen.dart';
import 'screens/reference_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/users_screen.dart';
import 'services/theme_controller.dart';
import 'state/reference_list_notifiers.dart';
import 'widgets/entity_table.dart';

GoRouter createRouter(ThemeController themeController, AuthNotifier auth) {
  String? require(Permission permission) => auth.can(permission) ? null : '/forbidden';

  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final target = state.matchedLocation;
      final public = target == '/login' || target == '/register';
      if (!auth.isAuthenticated && !public) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }
      if (auth.isAuthenticated && public) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(themeController: themeController),
      ),
      GoRoute(
        path: '/books',
        redirect: (context, state) => require(Permission.viewCatalog),
        builder: (context, state) => BooksScreen(
          query: BookQuery.fromUri(state.uri),
          themeController: themeController,
        ),
        routes: [
          GoRoute(
            path: 'new',
            redirect: (context, state) => require(Permission.manageBooks),
            builder: (context, state) => const BookFormScreen(),
          ),
          GoRoute(
            path: ':id/edit',
            redirect: (context, state) => require(Permission.manageBooks),
            builder: (context, state) => BookFormScreen(
              id: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => BookDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
              themeController: themeController,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/authors',
        redirect: (context, state) => require(Permission.manageReferences),
        builder: (context, state) => AuthorsScreen(
          query: AuthorQuery.fromUri(state.uri),
          themeController: themeController,
        ),
        routes: [
          GoRoute(path: 'new', builder: (context, state) => const AuthorFormScreen()),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) => AuthorFormScreen(
              id: int.tryParse(state.pathParameters['id'] ?? ''),
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => AuthorDetailScreen(
              id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
              themeController: themeController,
            ),
          ),
        ],
      ),
      _genre(require),
      _publisher(require),
      _reader(require),
      GoRoute(
        path: '/my-loans',
        redirect: (context, state) => require(Permission.viewOwnLoans),
        builder: (context, state) => const MyLoansScreen(),
      ),
      GoRoute(
        path: '/loans',
        redirect: (context, state) => require(Permission.manageLoans),
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        redirect: (context, state) => require(Permission.manageUsers),
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/admin/stats',
        redirect: (context, state) => require(Permission.viewStats),
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(
      location: state.uri.toString(),
      themeController: themeController,
    ),
  );
}

RouteBase _genre(String? Function(Permission) require) => GoRoute(
      path: '/genres',
      redirect: (context, state) => require(Permission.manageReferences),
      builder: (context, state) {
        final notifier = context.read<GenreListNotifier>();
        return ReferenceListScreen<Genre>(
          title: 'Жанры',
          route: '/genres',
          createRoute: '/genres/new',
          query: SimpleQuery.fromUri(state.uri),
          notifier: notifier,
          idOf: (e) => e.id,
          isDeleted: (e) => e.isDeleted,
          primary: (e) => e.name,
          columns: [
            TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
            TableColumnSpec(label: 'Описание', build: (e) => Text(e.description)),
          ],
        );
      },
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const GenreFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => GenreFormScreen(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => ReferenceDetailScreen(
            type: 'жанр',
            id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          ),
        ),
      ],
    );

RouteBase _publisher(String? Function(Permission) require) => GoRoute(
      path: '/publishers',
      redirect: (context, state) => require(Permission.manageReferences),
      builder: (context, state) {
        final notifier = context.read<PublisherListNotifier>();
        return ReferenceListScreen<Publisher>(
          title: 'Издательства',
          route: '/publishers',
          createRoute: '/publishers/new',
          query: SimpleQuery.fromUri(state.uri),
          notifier: notifier,
          idOf: (e) => e.id,
          isDeleted: (e) => e.isDeleted,
          primary: (e) => e.name,
          columns: [
            TableColumnSpec(label: 'Название', sortField: 'name', build: (e) => Text(e.name)),
            TableColumnSpec(label: 'Страна', sortField: 'country', build: (e) => Text(e.country)),
          ],
        );
      },
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const PublisherFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => PublisherFormScreen(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => ReferenceDetailScreen(
            type: 'издательство',
            id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          ),
        ),
      ],
    );

RouteBase _reader(String? Function(Permission) require) => GoRoute(
      path: '/readers',
      redirect: (context, state) => require(Permission.manageReaders),
      builder: (context, state) {
        final notifier = context.read<ReaderListNotifier>();
        return ReferenceListScreen<Reader>(
          title: 'Читатели',
          route: '/readers',
          createRoute: '/readers/new',
          query: SimpleQuery.fromUri(state.uri, defaultSort: 'fullName'),
          notifier: notifier,
          idOf: (e) => e.id,
          isDeleted: (e) => e.isDeleted,
          primary: (e) => e.fullName,
          defaultSort: 'fullName',
          columns: [
            TableColumnSpec(label: 'ФИО', sortField: 'fullName', build: (e) => Text(e.fullName)),
            TableColumnSpec(label: 'E-mail', sortField: 'email', build: (e) => Text(e.email)),
            TableColumnSpec(label: 'Билет', build: (e) => Text(e.card.number)),
          ],
        );
      },
      routes: [
        GoRoute(path: 'new', builder: (context, state) => const ReaderFormScreen()),
        GoRoute(
          path: ':id/edit',
          builder: (context, state) => ReaderFormScreen(
            id: int.tryParse(state.pathParameters['id'] ?? ''),
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) => ReferenceDetailScreen(
            type: 'читатель',
            id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          ),
        ),
      ],
    );
