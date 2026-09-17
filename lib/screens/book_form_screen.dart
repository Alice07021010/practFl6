import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/author.dart';
import '../models/book.dart';
import '../models/genre.dart';
import '../models/publisher.dart';
import '../repositories/author_repository.dart';
import '../repositories/genre_repository.dart';
import '../repositories/publisher_repository.dart';
import '../repositories/repository_errors.dart';
import '../state/book_list_notifier.dart';
import '../validators/validators.dart';
import '../widgets/entity_form_scaffold.dart';

class BookFormScreen extends StatefulWidget {
  final int? id;

  const BookFormScreen({super.key, this.id});

  bool get isEditing => id != null;

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _isbn = TextEditingController();
  final _year = TextEditingController();
  final _pages = TextEditingController();
  final _total = TextEditingController();
  final _available = TextEditingController();

  int? _publisherId;
  List<int> _authorIds = [];
  List<int> _genreIds = [];
  List<Publisher> _publishers = [];
  List<Author> _authors = [];
  List<Genre> _genres = [];

  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _isbnServerError;
  Book? _original;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rs = await Future.wait([
      context.read<PublisherRepository>().allActive(),
      context.read<AuthorRepository>().allActive(),
      context.read<GenreRepository>().allActive(),
    ]);

    _publishers = rs[0] as List<Publisher>;
    _authors = rs[1] as List<Author>;
    _genres = rs[2] as List<Genre>;

    if (widget.id != null) {
      _original = await context.read<BookListNotifier>().findById(widget.id!);
      final b = _original;
      if (b != null) {
        _title.text = b.title;
        _isbn.text = b.isbn;
        _year.text = '${b.year}';
        _pages.text = '${b.pages}';
        _total.text = '${b.copiesTotal}';
        _available.text = '${b.copiesAvailable}';
        _publisherId = b.publisherId;
        _authorIds = [...b.authorIds];
        _genreIds = [...b.genreIds];
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  void _mark() {
    if (!_dirty) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    for (final c in [_title, _isbn, _year, _pages, _total, _available]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _leave() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Есть несохранённые изменения'),
            content: const Text('Выйти без сохранения?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Остаться'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Выйти'),
              ),
            ],
          ),
        ) ??
        false;

    if (ok && mounted) {
      setState(() => _dirty = false);
      context.pop();
    }
  }

  Book _build() => Book(
        id: _original?.id ?? 0,
        title: _title.text.trim(),
        isbn: _isbn.text.trim(),
        year: int.tryParse(_year.text) ?? 0,
        pages: int.tryParse(_pages.text) ?? 0,
        publisherId: _publisherId ?? 0,
        authorIds: _authorIds,
        genreIds: _genreIds,
        copiesTotal: int.tryParse(_total.text) ?? 0,
        copiesAvailable: int.tryParse(_available.text) ?? 0,
        deletedAt: _original?.deletedAt,
      );

  Future<void> _save() async {
    setState(() => _isbnServerError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      if (widget.isEditing) {
        await context.read<BookListNotifier>().update(_build());
      } else {
        await context.read<BookListNotifier>().create(_build());
      }

      if (!mounted) return;
      setState(() => _dirty = false);
      context.go('/books');
    } on FieldValidationException catch (e) {
      if (e.field == 'isbn') {
        setState(() => _isbnServerError = e.message);
        _formKey.currentState!.validate();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return EntityFormScaffold(
      title: widget.isEditing ? 'Редактирование книги' : 'Новая книга',
      dirty: _dirty,
      saving: _saving,
      onSave: _save,
      onLeaveRequested: _leave,
      child: Form(
        key: _formKey,
        onChanged: _mark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Название'),
              validator: (v) => textLength(v, min: 2, max: 120),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isbn,
              decoration: const InputDecoration(labelText: 'ISBN'),
              validator: (v) => _isbnServerError ?? isbnValidator(v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _year,
                    decoration: const InputDecoration(labelText: 'Год'),
                    validator: (v) => intRange(v, min: 1450, max: 2100),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _pages,
                    decoration: const InputDecoration(labelText: 'Страниц'),
                    validator: (v) => intRange(v, min: 1, max: 10000),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _publisherId,
              decoration: const InputDecoration(labelText: 'Издательство'),
              items: _publishers
                  .map(
                    (p) => DropdownMenuItem<int>(
                      value: p.id,
                      child: Text(p.name),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _publisherId = v;
                  final allowed = _availableGenres.map((g) => g.id).toSet();
                  _genreIds = _genreIds.where(allowed.contains).toList();
                });
                _mark();
              },
              validator: (v) => v == null ? 'Выберите издательство' : null,
            ),
            const SizedBox(height: 16),
            _multi<Author>(
              'Авторы',
              _authors,
              _authorIds,
              (a) => a.id,
              (a) => a.fullName,
              (v) => _authorIds = v,
            ),
            const SizedBox(height: 16),
            Text(
              'Доступные жанры зависят от выбранного издательства.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            _multi<Genre>(
              'Жанры',
              _availableGenres,
              _genreIds,
              (g) => g.id,
              (g) => g.name,
              (v) => _genreIds = v,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _total,
                    decoration:
                        const InputDecoration(labelText: 'Всего экземпляров'),
                    validator: (v) => positiveInt(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _available,
                    decoration: const InputDecoration(labelText: 'Доступно'),
                    validator: (v) {
                      final e = positiveInt(v, allowZero: true);
                      if (e != null) return e;

                      final available = int.tryParse(v ?? '') ?? 0;
                      final total = int.tryParse(_total.text) ?? 0;
                      return available > total
                          ? 'Доступно не может быть больше общего количества'
                          : null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Genre> get _availableGenres {
    if (_publisherId == null) return _genres;

    const profiles = <int, Set<int>>{
      1: {1, 2, 5},
      2: {3, 4, 6},
      3: {1, 5, 6},
      4: {2, 3, 4},
    };

    final allowed = profiles[_publisherId];
    if (allowed == null) return _genres;
    return _genres.where((g) => allowed.contains(g.id)).toList();
  }

  Widget _multi<T>(
    String label,
    List<T> values,
    List<int> selected,
    int Function(T) eId,
    String Function(T) eName,
    void Function(List<int>) setValue,
  ) {
    return FormField<List<int>>(
      key: ValueKey('$label-${selected.join(',')}'),
      initialValue: selected,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Выберите хотя бы одно значение' : null,
      builder: (field) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: field.errorText,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((e) {
            final id = eId(e);
            final isSelected = field.value!.contains(id);
            return FilterChip(
              label: Text(eName(e)),
              selected: isSelected,
              onSelected: (_) {
                final next = [...field.value!];
                if (isSelected) {
                  next.remove(id);
                } else {
                  next.add(id);
                }
                field.didChange(next);
                setState(() => setValue(next));
                _mark();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
