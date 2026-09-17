import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_notifier.dart';
import '../models/app_user.dart';
import '../models/book.dart';
import '../models/book_query.dart';
import '../models/genre.dart';
import '../models/publisher.dart';
import '../repositories/genre_repository.dart';
import '../repositories/publisher_repository.dart';
import '../services/theme_controller.dart';
import '../state/book_list_notifier.dart';
import '../state/load_status.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_state_view.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/theme_button.dart';

class BooksScreen extends StatefulWidget {
  final BookQuery query;
  final ThemeController themeController;

  const BooksScreen({
    super.key,
    required this.query,
    required this.themeController,
  });

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  late final TextEditingController search;
  late final TextEditingController yearFrom;
  late final TextEditingController yearTo;

  Timer? searchTimer;
  Timer? yearTimer;

  List<Genre> genres = [];
  List<Publisher> publishers = [];

  @override
  void initState() {
    super.initState();

    search = TextEditingController(
      text: widget.query.search,
    );

    yearFrom = TextEditingController(
      text: widget.query.yearFrom?.toString() ?? '',
    );

    yearTo = TextEditingController(
      text: widget.query.yearTo?.toString() ?? '',
    );

    _loadReferences();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<BookListNotifier>()
            .applyQuery(widget.query);
      }
    });
  }

  Future<void> _loadReferences() async {
    final result = await Future.wait([
      context.read<GenreRepository>().allActive(),
      context.read<PublisherRepository>().allActive(),
    ]);

    if (!mounted) return;

    setState(() {
      genres = result[0] as List<Genre>;
      publishers = result[1] as List<Publisher>;
    });
  }

  @override
  void didUpdateWidget(covariant BooksScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query) {
      search.text = widget.query.search;

      yearFrom.text =
          widget.query.yearFrom?.toString() ?? '';

      yearTo.text =
          widget.query.yearTo?.toString() ?? '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<BookListNotifier>()
              .applyQuery(widget.query);
        }
      });
    }
  }

  @override
  void dispose() {
    searchTimer?.cancel();
    yearTimer?.cancel();

    search.dispose();
    yearFrom.dispose();
    yearTo.dispose();

    super.dispose();
  }

  void go(BookQuery query) {
    context.go(
      Uri(
        path: '/books',
        queryParameters: query.toQueryParameters(),
      ).toString(),
    );
  }

  void onSearch(String value) {
    searchTimer?.cancel();

    searchTimer = Timer(
      const Duration(milliseconds: 350),
      () {
        go(
          widget.query.copyWith(
            search: value,
            page: 1,
            serverFail: null,
            serverDelay: widget.query.serverDelay,
          ),
        );
      },
    );
  }

  void years() {
    yearTimer?.cancel();

    yearTimer = Timer(
      const Duration(milliseconds: 400),
      () {
        go(
          widget.query.copyWith(
            yearFrom: int.tryParse(yearFrom.text),
            yearTo: int.tryParse(yearTo.text),
            page: 1,
            serverFail: null,
            serverDelay: widget.query.serverDelay,
          ),
        );
      },
    );
  }

  String genreNames(Book book) {
    return book.genreIds
        .map(
          (id) =>
              genres
                  .where((genre) => genre.id == id)
                  .map((genre) => genre.name)
                  .firstOrNull ??
              '#$id',
        )
        .join(', ');
  }

  String publisherName(int id) {
    return publishers
            .where((publisher) => publisher.id == id)
            .map((publisher) => publisher.name)
            .firstOrNull ??
        '—';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BookListNotifier>();
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог книг'),
        actions: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
          ThemeButton(
            controller: widget.themeController,
          ),
        ],
      ),
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
                      width: 280,
                      child: TextField(
                        controller: search,
                        onChanged: onSearch,
                        decoration: const InputDecoration(
                          labelText:
                              'Поиск по названию или ISBN',
                          prefixIcon:
                              Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      child:
                          DropdownButtonFormField<int?>(
                        value: widget.query.genreId,
                        decoration:
                            const InputDecoration(
                          labelText: 'Жанр',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Все жанры'),
                          ),
                          ...genres.map(
                            (genre) =>
                                DropdownMenuItem<int?>(
                              value: genre.id,
                              child: Text(
                                genre.name,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          go(
                            widget.query.copyWith(
                              genreId: value,
                              page: 1,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      child:
                          DropdownButtonFormField<int?>(
                        value: widget.query.publisherId,
                        decoration:
                            const InputDecoration(
                          labelText: 'Издательство',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child:
                                Text('Все издательства'),
                          ),
                          ...publishers.map(
                            (publisher) =>
                                DropdownMenuItem<int?>(
                              value: publisher.id,
                              child: Text(
                                publisher.name,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          go(
                            widget.query.copyWith(
                              publisherId: value,
                              page: 1,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: yearFrom,
                        onChanged: (_) => years(),
                        decoration:
                            const InputDecoration(
                          labelText: 'Год от',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: yearTo,
                        onChanged: (_) => years(),
                        decoration:
                            const InputDecoration(
                          labelText: 'Год до',
                        ),
                      ),
                    ),
                    FilterChip(
                      label: const Text(
                        'Показывать удалённые',
                      ),
                      selected:
                          widget.query.includeDeleted,
                      onSelected: (value) {
                        go(
                          widget.query.copyWith(
                            includeDeleted: value,
                            page: 1,
                          ),
                        );
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        go(const BookQuery());
                      },
                      icon: const Icon(
                        Icons.filter_alt_off,
                      ),
                      label: const Text('Сбросить'),
                    ),
                    if (auth.can(
                      Permission.manageBooks,
                    ))
                      FilledButton.icon(
                        onPressed: () {
                          context.go('/books/new');
                        },
                        icon:
                            const Icon(Icons.add),
                        label: const Text(
                          'Добавить книгу',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (notifier.hasSelection &&
                auth.can(Permission.manageBooks))
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Выбрано: ${notifier.selected.length}',
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            _deleteSelected(
                          notifier,
                        ),
                        icon: const Icon(
                          Icons.delete_sweep,
                        ),
                        label: const Text(
                          'Удалить выбранные',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _body(notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BookListNotifier notifier) {
    switch (notifier.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const LoadingStateView();

      case LoadStatus.error:
        return ErrorStateView(
          message: notifier.error ?? 'Ошибка',
          onBackToNormal: () {
            go(
              widget.query.copyWith(
                serverFail: null,
                serverDelay:
                    widget.query.serverDelay,
                page: 1,
              ),
            );
          },
        );

      case LoadStatus.success:
        if (notifier.result.items.isEmpty) {
          return EmptyStateView(
            onReset: () {
              go(const BookQuery());
            },
          );
        }

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  if (box.maxWidth < 600) {
                    return _cards(notifier);
                  }

                  return SingleChildScrollView(
                    child: _table(notifier),
                  );
                },
              ),
            ),
            PaginationBar(
              page: notifier.result.page,
              totalPages:
                  notifier.result.totalPages,
              total: notifier.result.total,
              size: notifier.result.size,
              onPageChanged: (page) {
                go(
                  widget.query.copyWith(
                    page: page,
                  ),
                );
              },
              onSizeChanged: (size) {
                go(
                  widget.query.copyWith(
                    size: size,
                    page: 1,
                  ),
                );
              },
            ),
          ],
        );
    }
  }

  Widget _table(BookListNotifier notifier) {
    final auth = context.read<AuthNotifier>();

    return EntityTable<Book>(
      items: notifier.result.items,
      idOf: (book) => book.id,
      selected: notifier.selected,
      onToggleSelect:
          auth.can(Permission.manageBooks)
              ? notifier.toggleSelection
              : null,
      isDeleted: (book) => book.isDeleted,
      sortField: widget.query.sortField,
      sortAscending:
          widget.query.sortAscending,
      onSort: (field) {
        go(
          widget.query.copyWith(
            sortField: field,
            sortAscending:
                field == widget.query.sortField
                    ? !widget.query.sortAscending
                    : true,
            page: 1,
          ),
        );
      },
      columns: [
        TableColumnSpec(
          label: 'Название',
          sortField: 'title',
          build: (book) => Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: book.isDeleted
                ? const TextStyle(
                    decoration:
                        TextDecoration.lineThrough,
                  )
                : null,
          ),
        ),
        TableColumnSpec(
          label: 'ISBN',
          build: (book) =>
              Text(book.isbn),
        ),
        TableColumnSpec(
          label: 'Год',
          sortField: 'year',
          numeric: true,
          build: (book) =>
              Text('${book.year}'),
        ),
        TableColumnSpec(
          label: 'Страниц',
          sortField: 'pages',
          numeric: true,
          build: (book) =>
              Text('${book.pages}'),
        ),
        TableColumnSpec(
          label: 'Жанры',
          build: (book) =>
              Text(genreNames(book)),
        ),
        TableColumnSpec(
          label: 'Издательство',
          build: (book) =>
              Text(publisherName(
            book.publisherId,
          )),
        ),
        TableColumnSpec(
          label: 'Доступно',
          numeric: true,
          build: (book) => Text(
            '${book.copiesAvailable}/${book.copiesTotal}',
          ),
        ),
      ],
      actions: (book) =>
          actions(notifier, book),
    );
  }

  Widget _cards(BookListNotifier notifier) {
    return ListView.builder(
      itemCount: notifier.result.items.length,
      itemBuilder: (context, index) {
        final book =
            notifier.result.items[index];

        return Card(
          child: ListTile(
            title: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${genreNames(book)} · '
              '${publisherName(book.publisherId)}\n'
              'ISBN ${book.isbn} · ${book.year}',
            ),
            trailing: Wrap(
              children:
                  actions(notifier, book),
            ),
          ),
        );
      },
    );
  }

  List<Widget> actions(
    BookListNotifier notifier,
    Book book,
  ) {
    final auth = context.read<AuthNotifier>();

    return [
      IconButton(
        onPressed: () {
          context.go('/books/${book.id}');
        },
        icon: const Icon(
          Icons.open_in_new,
        ),
      ),
      if (auth.can(Permission.manageBooks))
        IconButton(
          onPressed: () {
            context.go(
              '/books/${book.id}/edit',
            );
          },
          icon: const Icon(
            Icons.edit_outlined,
          ),
        ),
      if (auth.can(Permission.manageBooks) &&
          !book.isDeleted)
        IconButton(
          onPressed: () {
            _delete(
              notifier,
              book,
              false,
            );
          },
          icon: const Icon(
            Icons.archive_outlined,
          ),
        ),
      if (auth.can(
            Permission.restoreRecords,
          ) &&
          book.isDeleted)
        IconButton(
          onPressed: () {
            notifier.restore(book.id);
          },
          icon: const Icon(
            Icons.restore,
          ),
        ),
      if (auth.can(Permission.hardDelete))
        IconButton(
          onPressed: () {
            _delete(
              notifier,
              book,
              true,
            );
          },
          icon: const Icon(
            Icons.delete_forever,
          ),
        ),
    ];
  }

  Future<bool> confirm(
    String title,
    String text,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) =>
              AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child:
                    const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: const Text(
                  'Подтвердить',
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteSelected(
    BookListNotifier notifier,
  ) async {
    final ok = await confirm(
      'Удалить выбранные книги?',
      'Будет выполнено логическое удаление '
          '${notifier.selected.length} записей.',
    );

    if (ok) {
      await notifier.deleteSelected();
    }
  }

  Future<void> _delete(
    BookListNotifier notifier,
    Book book,
    bool hard,
  ) async {
    final ok = await confirm(
      hard
          ? 'Удалить навсегда?'
          : 'Логически удалить?',
      hard
          ? 'Книга «${book.title}» будет удалена без восстановления.'
          : 'Книга «${book.title}» останется в хранилище и её можно будет восстановить.',
    );

    if (!ok) return;

    if (hard) {
      await notifier.hardDelete(book.id);
    } else {
      await notifier.softDelete(book.id);
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull =>
      isEmpty ? null : first;
}