class Book {
  final int id;
  final String title;
  final String isbn;
  final int year;
  final int pages;
  final int publisherId;
  final List<int> authorIds;
  final List<int> genreIds;
  final int copiesTotal;
  final int copiesAvailable;
  final DateTime? deletedAt;

  const Book({
    required this.id,
    required this.title,
    required this.isbn,
    required this.year,
    required this.pages,
    required this.publisherId,
    required this.authorIds,
    required this.genreIds,
    required this.copiesTotal,
    required this.copiesAvailable,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isbn': isbn,
        'year': year,
        'pages': pages,
        'publisherId': publisherId,
        'authorIds': authorIds,
        'genreIds': genreIds,
        'copiesTotal': copiesTotal,
        'copiesAvailable': copiesAvailable,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: _asInt(json['id']),
        title: '${json['title'] ?? ''}',
        isbn: '${json['isbn'] ?? ''}',
        year: _asInt(json['year']),
        pages: _asInt(json['pages']),
        publisherId: _asInt(json['publisherId'] ?? (json['publisher'] is Map ? (json['publisher'] as Map)['id'] : 0)),
        authorIds: _asIntList(json['authorIds'] ?? (json['authors'] is List ? (json['authors'] as List).map((e) => e is Map ? e['id'] : null).toList() : const [])),
        genreIds: _asIntList(json['genreIds'] ?? (json['genres'] is List ? (json['genres'] as List).map((e) => e is Map ? e['id'] : null).toList() : const [])),
        copiesTotal: _asInt(json['copiesTotal']),
        copiesAvailable: _asInt(json['copiesAvailable']),
        deletedAt: _asDate(json['deletedAt']),
      );

  Book copyWith({
    String? title,
    String? isbn,
    int? year,
    int? pages,
    int? publisherId,
    List<int>? authorIds,
    List<int>? genreIds,
    int? copiesTotal,
    int? copiesAvailable,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => Book(
        id: id,
        title: title ?? this.title,
        isbn: isbn ?? this.isbn,
        year: year ?? this.year,
        pages: pages ?? this.pages,
        publisherId: publisherId ?? this.publisherId,
        authorIds: authorIds ?? this.authorIds,
        genreIds: genreIds ?? this.genreIds,
        copiesTotal: copiesTotal ?? this.copiesTotal,
        copiesAvailable: copiesAvailable ?? this.copiesAvailable,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );
}

int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
List<int> _asIntList(dynamic value) => value is List ? value.map(_asInt).where((e) => e != 0).toList() : <int>[];
DateTime? _asDate(dynamic value) => value == null || '$value'.isEmpty ? null : DateTime.tryParse('$value');
