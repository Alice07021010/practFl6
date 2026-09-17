class Genre {
  final int id;
  final String name;
  final String description;
  final DateTime? deletedAt;

  const Genre({required this.id, required this.name, required this.description, this.deletedAt});
  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        name: '${json['name'] ?? ''}',
        description: '${json['description'] ?? ''}',
        deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse('${json['deletedAt']}'),
      );

  Genre copyWith({String? name, String? description, DateTime? deletedAt, bool clearDeletedAt = false}) => Genre(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );
}
