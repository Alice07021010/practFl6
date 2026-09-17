class LibraryCard {
  final String number;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const LibraryCard({required this.number, required this.issuedAt, required this.expiresAt});

  Map<String, dynamic> toJson() => {
        'number': number,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory LibraryCard.fromJson(Map<String, dynamic> json) => LibraryCard(
        number: '${json['number'] ?? ''}',
        issuedAt: DateTime.tryParse('${json['issuedAt'] ?? ''}') ?? DateTime(2026, 1, 1),
        expiresAt: DateTime.tryParse('${json['expiresAt'] ?? ''}') ?? DateTime(2027, 1, 1),
      );
}
