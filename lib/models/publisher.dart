class Publisher {
  final int id;
  final String name;
  final String country;
  final DateTime? deletedAt;

  const Publisher({required this.id, required this.name, required this.country, this.deletedAt});
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Publisher.fromJson(Map<String, dynamic> json) => Publisher(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        name: '${json['name'] ?? ''}',
        country: '${json['country'] ?? ''}',
        deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse('${json['deletedAt']}'),
      );

  Publisher copyWith({String? name, String? country, DateTime? deletedAt, bool clearDeletedAt = false}) => Publisher(
        id: id,
        name: name ?? this.name,
        country: country ?? this.country,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );
}
