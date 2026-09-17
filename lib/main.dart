import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/auth_api.dart';
import 'auth/auth_notifier.dart';
import 'auth/role_api.dart';
import 'auth/session_watcher.dart';
import 'widgets/adaptive_app_frame.dart';
import 'core/api_client.dart';
import 'repositories/api_author_repository.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_reference_repositories.dart';
import 'repositories/author_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/genre_repository.dart';
import 'repositories/publisher_repository.dart';
import 'repositories/reader_repository.dart';
import 'router.dart';
import 'services/theme_controller.dart';
import 'state/author_list_notifier.dart';
import 'state/book_list_notifier.dart';
import 'state/reference_list_notifiers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();
  final theme = ThemeController();
  await theme.load();

  final authApi = AuthApi(buildAuthDio());
  final auth = AuthNotifier(prefs, authApi);
  await auth.restore();

  final dio = buildDio(
    tokenProvider: () => auth.accessToken,
    refreshTokens: auth.refreshTokens,
    onAuthFailed: auth.logout,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: auth),
        Provider<Dio>.value(value: dio),
        Provider<RoleApi>(create: (_) => RoleApi(dio)),
        ProxyProvider<Dio, BookRepository>(
          update: (_, api, __) => ApiBookRepository(api),
        ),
        ProxyProvider<Dio, AuthorRepository>(
          update: (_, api, __) => ApiAuthorRepository(api),
        ),
        ProxyProvider<Dio, GenreRepository>(
          update: (_, api, __) => ApiGenreRepository(api),
        ),
        ProxyProvider<Dio, PublisherRepository>(
          update: (_, api, __) => ApiPublisherRepository(api),
        ),
        ProxyProvider<Dio, ReaderRepository>(
          update: (_, api, __) => ApiReaderRepository(api),
        ),
        ChangeNotifierProxyProvider<BookRepository, BookListNotifier>(
          create: (c) => BookListNotifier(c.read<BookRepository>()),
          update: (_, repo, old) => old ?? BookListNotifier(repo),
        ),
        ChangeNotifierProxyProvider<AuthorRepository, AuthorListNotifier>(
          create: (c) => AuthorListNotifier(c.read<AuthorRepository>()),
          update: (_, repo, old) => old ?? AuthorListNotifier(repo),
        ),
        ChangeNotifierProxyProvider<GenreRepository, GenreListNotifier>(
          create: (c) => GenreListNotifier(c.read<GenreRepository>()),
          update: (_, repo, old) => old ?? GenreListNotifier(repo),
        ),
        ChangeNotifierProxyProvider<PublisherRepository, PublisherListNotifier>(
          create: (c) => PublisherListNotifier(c.read<PublisherRepository>()),
          update: (_, repo, old) => old ?? PublisherListNotifier(repo),
        ),
        ChangeNotifierProxyProvider<ReaderRepository, ReaderListNotifier>(
          create: (c) => ReaderListNotifier(c.read<ReaderRepository>()),
          update: (_, repo, old) => old ?? ReaderListNotifier(repo),
        ),
      ],
      child: TmyvDenegApp(themeController: theme, auth: auth),
    ),
  );
}

class TmyvDenegApp extends StatefulWidget {
  final ThemeController themeController;
  final AuthNotifier auth;

  const TmyvDenegApp({
    super.key,
    required this.themeController,
    required this.auth,
  });

  @override
  State<TmyvDenegApp> createState() => _TmyvDenegAppState();
}

class _TmyvDenegAppState extends State<TmyvDenegApp> {
  late final router = createRouter(widget.themeController, widget.auth);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.themeController, widget.auth]),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'ООО «Тмыв денег»',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          themeMode: widget.themeController.themeMode,
          routerConfig: router,
          builder: (context, child) {
            final page = child ?? const SizedBox.shrink();
            if (!widget.auth.isAuthenticated) return page;
            return SessionWatcher(
              sessionStartedAt: widget.auth.sessionStartedAt,
              onTimeout: widget.auth.logout,
              child: AdaptiveAppFrame(child: page, router: router),
            );
          },
        );
      },
    );
  }
}
