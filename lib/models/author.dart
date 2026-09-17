class Author {
  final int id;
  final String firstName;
  final String lastName;
  final String country;
  final int birthYear;
  final int bookCount;
  final DateTime? deletedAt;

  const Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.birthYear,
    required this.bookCount,
    this.deletedAt,
  });

  String get fullName => '$lastName $firstName';
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'country': country,
        'birthYear': birthYear,
        'bookCount': bookCount,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Author.fromJson(Map<String, dynamic> json) => Author(
        id: _int(json['id']),
        firstName: '${json['firstName'] ?? ''}',
        lastName: '${json['lastName'] ?? ''}',
        country: '${json['country'] ?? ''}',
        birthYear: _int(json['birthYear']),
        bookCount: _int(json['bookCount']),
        deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse('${json['deletedAt']}'),
      );

  Author copyWith({
    String? firstName,
    String? lastName,
    String? country,
    int? birthYear,
    int? bookCount,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) => Author(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        country: country ?? this.country,
        birthYear: birthYear ?? this.birthYear,
        bookCount: bookCount ?? this.bookCount,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );
}

int _int(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
