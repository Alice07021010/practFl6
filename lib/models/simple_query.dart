class SimpleQuery {
  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool simulateError;

  const SimpleQuery({
    this.search = '',
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.simulateError = false,
  });

  SimpleQuery copyWith({String? search, String? sortField, bool? sortAscending, int? page, int? size, bool? includeDeleted, bool? simulateError}) => SimpleQuery(
        search: search ?? this.search,
        sortField: sortField ?? this.sortField,
        sortAscending: sortAscending ?? this.sortAscending,
        page: page ?? this.page,
        size: size ?? this.size,
        includeDeleted: includeDeleted ?? this.includeDeleted,
        simulateError: simulateError ?? this.simulateError,
      );

  factory SimpleQuery.fromUri(Uri uri, {String defaultSort = 'name'}) {
    final q = uri.queryParameters;
    final sort = (q['sort'] ?? '$defaultSort,asc').split(',');
    final parsedSize = int.tryParse(q['size'] ?? '') ?? 10;
    return SimpleQuery(
      search: q['search'] ?? '',
      sortField: sort.first.isEmpty ? defaultSort : sort.first,
      sortAscending: sort.length < 2 || sort[1] != 'desc',
      page: _positive(q['page'], 1),
      size: {10, 25, 50}.contains(parsedSize) ? parsedSize : 10,
      includeDeleted: q['includeDeleted'] == '1',
      simulateError: q['fail'] == '1',
    );
  }

  Map<String, String> toQueryParameters({String defaultSort = 'name'}) {
    final out = <String, String>{};
    if (search.trim().isNotEmpty) out['search'] = search.trim();
    if (sortField != defaultSort || !sortAscending) out['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    if (page != 1) out['page'] = '$page';
    if (size != 10) out['size'] = '$size';
    if (includeDeleted) out['includeDeleted'] = '1';
    if (simulateError) out['fail'] = '1';
    return out;
  }

  static int _positive(String? raw, int fallback) {
    final v = int.tryParse(raw ?? '');
    return v != null && v > 0 ? v : fallback;
  }

  @override
  bool operator ==(Object other) => other is SimpleQuery && other.search == search && other.sortField == sortField && other.sortAscending == sortAscending && other.page == page && other.size == size && other.includeDeleted == includeDeleted && other.simulateError == simulateError;
  @override
  int get hashCode => Object.hash(search, sortField, sortAscending, page, size, includeDeleted, simulateError);
}
