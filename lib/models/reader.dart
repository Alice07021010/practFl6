import 'library_card.dart';

class Reader {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final LibraryCard card;
  final DateTime? deletedAt;

  const Reader({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'card': card.toJson(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Reader.fromJson(Map<String, dynamic> json) => Reader(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        fullName: '${json['fullName'] ?? ''}',
        email: '${json['email'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        card: LibraryCard.fromJson(json['card'] is Map ? Map<String, dynamic>.from(json['card'] as Map) : const {}),
        deletedAt: json['deletedAt'] == null ? null : DateTime.tryParse('${json['deletedAt']}'),
      );

  Reader copyWith({String? fullName, String? email, String? phone, LibraryCard? card, DateTime? deletedAt, bool clearDeletedAt = false}) => Reader(
        id: id,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        card: card ?? this.card,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );
}
