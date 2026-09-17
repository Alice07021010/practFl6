class Loan {
  final int id;
  final int bookId;
  final String bookTitle;
  final int readerId;
  final String readerName;
  final DateTime issuedAt;
  final DateTime dueAt;
  final DateTime? returnedAt;

  const Loan({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.readerId,
    required this.readerName,
    required this.issuedAt,
    required this.dueAt,
    this.returnedAt,
  });

  bool get isOpen => returnedAt == null;

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'] as int? ?? 0,
        bookId: json['bookId'] as int? ?? 0,
        bookTitle: json['bookTitle'] as String? ?? '',
        readerId: json['readerId'] as int? ?? 0,
        readerName: json['readerName'] as String? ?? '',
        issuedAt: DateTime.tryParse(json['issuedAt'] as String? ?? '') ?? DateTime.now(),
        dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '') ?? DateTime.now(),
        returnedAt: json['returnedAt'] == null
            ? null
            : DateTime.tryParse(json['returnedAt'] as String),
      );
}
