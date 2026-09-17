import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/auth_notifier.dart';
import '../models/app_user.dart';
import '../models/simple_query.dart';
import '../state/load_status.dart';
import '../state/reference_list_notifiers.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_state_view.dart';
import '../widgets/pagination_bar.dart';

class ReferenceListScreen<T> extends StatefulWidget {
  final String title;
  final String route;
  final String createRoute;
  final SimpleQuery query;
  final BaseReferenceNotifier<T> notifier;
  final int Function(T) idOf;
  final bool Function(T) isDeleted;
  final String Function(T) primary;
  final List<TableColumnSpec<T>> columns;
  final String defaultSort;

  const ReferenceListScreen({
    super.key,
    required this.title,
    required this.route,
    required this.createRoute,
    required this.query,
    required this.notifier,
    required this.idOf,
    required this.isDeleted,
    required this.primary,
    required this.columns,
    this.defaultSort = 'name',
  });

  @override
  State<ReferenceListScreen<T>> createState() =>
      _ReferenceListScreenState<T>();
}

class _ReferenceListScreenState<T>
    extends State<ReferenceListScreen<T>> {
  late final TextEditingController search;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    search = TextEditingController(
      text: widget.query.search,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.notifier.applyQuery(widget.query);
      }
    });
  }

  @override
  void didUpdateWidget(
    covariant ReferenceListScreen<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.query != widget.query) {
      search.text = widget.query.search;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.notifier.applyQuery(widget.query);
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    search.dispose();
    super.dispose();
  }

  void go(SimpleQuery query) {
    context.go(
      Uri(
        path: widget.route,
        queryParameters: query.toQueryParameters(
          defaultSort: widget.defaultSort,
        ),
      ).toString(),
    );
  }

  void searchChanged(String value) {
    timer?.cancel();

    timer = Timer(
      const Duration(milliseconds: 350),
      () {
        if (mounted) {
          go(
            widget.query.copyWith(
              search: value,
              page: 1,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier;

    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(
                  Icons.home_outlined,
                ),
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
                          width: 300,
                          child: TextField(
                            controller: search,
                            onChanged: searchChanged,
                            decoration:
                                const InputDecoration(
                              labelText: 'Поиск',
                              prefixIcon:
                                  Icon(Icons.search),
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
                            go(
                              SimpleQuery(
                                sortField:
                                    widget.defaultSort,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.filter_alt_off,
                          ),
                          label:
                              const Text('Сбросить'),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            context.go(
                              widget.createRoute,
                            );
                          },
                          icon:
                              const Icon(Icons.add),
                          label:
                              const Text('Добавить'),
                        ),
                      ],
                    ),
                  ),
                ),

                if (notifier.hasSelection)
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
      },
    );
  }

  Widget _body(
    BaseReferenceNotifier<T> notifier,
  ) {
    switch (notifier.status) {
      case LoadStatus.idle:
      case LoadStatus.loading:
        return const LoadingStateView();

      case LoadStatus.error:
        return ErrorStateView(
          message: notifier.error ?? 'Ошибка',
          onBackToNormal: () {
            go(
              SimpleQuery(
                sortField: widget.defaultSort,
              ),
            );
          },
        );

      case LoadStatus.success:
        if (notifier.result.items.isEmpty) {
          return EmptyStateView(
            onReset: () {
              go(
                SimpleQuery(
                  sortField: widget.defaultSort,
                ),
              );
            },
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: EntityTable<T>(
                  items: notifier.result.items,
                  idOf: widget.idOf,
                  selected: notifier.selected,
                  onToggleSelect:
                      notifier.toggleSelection,
                  isDeleted: widget.isDeleted,
                  sortField:
                      widget.query.sortField,
                  sortAscending:
                      widget.query.sortAscending,
                  onSort: (field) {
                    go(
                      widget.query.copyWith(
                        sortField: field,
                        sortAscending:
                            field ==
                                    widget.query.sortField
                                ? !widget.query
                                    .sortAscending
                                : true,
                        page: 1,
                      ),
                    );
                  },
                  columns: widget.columns,
                  actions: (item) {
                    final auth =
                        context.read<AuthNotifier>();

                    return [
                      IconButton(
                        onPressed: () {
                          context.go(
                            '${widget.route}/${widget.idOf(item)}',
                          );
                        },
                        icon: const Icon(
                          Icons.open_in_new,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          context.go(
                            '${widget.route}/${widget.idOf(item)}/edit',
                          );
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                        ),
                      ),

                      if (!widget.isDeleted(item))
                        IconButton(
                          onPressed: () {
                            _delete(
                              notifier,
                              item,
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
                          widget.isDeleted(item))
                        IconButton(
                          onPressed: () {
                            notifier.restore(
                              widget.idOf(item),
                            );
                          },
                          icon: const Icon(
                            Icons.restore,
                          ),
                        ),

                      if (auth.can(
                        Permission.hardDelete,
                      ))
                        IconButton(
                          onPressed: () {
                            _delete(
                              notifier,
                              item,
                              true,
                            );
                          },
                          icon: const Icon(
                            Icons.delete_forever,
                          ),
                        ),
                    ];
                  },
                ),
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

  Future<bool> confirm(
    String title,
    String text,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
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
    BaseReferenceNotifier<T> notifier,
  ) async {
    final confirmed = await confirm(
      'Удалить выбранные?',
      'Будет выполнено логическое удаление '
          '${notifier.selected.length} записей.',
    );

    if (!confirmed) return;

    try {
      await notifier.deleteSelected();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
          ),
        );
      }
    }
  }

  Future<void> _delete(
    BaseReferenceNotifier<T> notifier,
    T item,
    bool hard,
  ) async {
    final confirmed = await confirm(
      hard
          ? 'Удалить навсегда?'
          : 'Логически удалить?',
      hard
          ? 'Запись «${widget.primary(item)}» нельзя будет восстановить.'
          : 'Запись «${widget.primary(item)}» можно будет восстановить.',
    );

    if (!confirmed) return;

    try {
      if (hard) {
        await notifier.hardDelete(
          widget.idOf(item),
        );
      } else {
        await notifier.softDelete(
          widget.idOf(item),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
          ),
        );
      }
    }
  }
}