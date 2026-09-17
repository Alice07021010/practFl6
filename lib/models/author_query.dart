class AuthorQuery {
  final String search;
  final String? country;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;
  final bool simulateError;

  const AuthorQuery({
    this.search = '',
    this.country,
    this.sortField = 'lastName',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
    this.simulateError = false,
  });

  static const _unset = Object();

  AuthorQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
    bool? simulateError,
  }) {
    return AuthorQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? this.page,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
      simulateError: simulateError ?? this.simulateError,
    );
  }

  factory AuthorQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;
    final sort = (q['sort'] ?? 'lastName,asc').split(',');
    final sortField = {'lastName', 'country', 'birthYear'}.contains(sort.first)
        ? sort.first
        : 'lastName';
    final parsedSize = int.tryParse(q['size'] ?? '') ?? 10;
    final size = {10, 25, 50}.contains(parsedSize) ? parsedSize : 10;

    return AuthorQuery(
      search: q['search'] ?? '',
      country: (q['country']?.trim().isEmpty ?? true) ? null : q['country'],
      sortField: sortField,
      sortAscending: sort.length < 2 || sort[1] != 'desc',
      page: _positiveInt(q['page'], 1),
      size: size,
      includeDeleted: q['includeDeleted'] == '1',
      simulateError: q['fail'] == '1',
    );
  }

  Map<String, String> toQueryParameters() {
    final result = <String, String>{};
    if (search.trim().isNotEmpty) result['search'] = search.trim();
    if (country != null && country!.isNotEmpty) result['country'] = country!;
    if (sortField != 'lastName' || !sortAscending) {
      result['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) result['page'] = '$page';
    if (size != 10) result['size'] = '$size';
    if (includeDeleted) result['includeDeleted'] = '1';
    if (simulateError) result['fail'] = '1';
    return result;
  }

  static int _positiveInt(String? raw, int fallback) {
    final value = int.tryParse(raw ?? '');
    return value != null && value > 0 ? value : fallback;
  }

  @override
  bool operator ==(Object other) {
    return other is AuthorQuery &&
        other.search == search &&
        other.country == country &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted &&
        other.simulateError == simulateError;
  }

  @override
  int get hashCode => Object.hash(
        search,
        country,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
        simulateError,
      );
}
