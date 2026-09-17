class FieldValidationException implements Exception {
  final String field;
  final String message;
  const FieldValidationException(this.field, this.message);
  @override
  String toString() => message;
}

class RepositoryConflictException implements Exception {
  final String message;
  const RepositoryConflictException(this.message);
  @override
  String toString() => message;
}

class LinkedRecordsException extends RepositoryConflictException {
  final int count;
  const LinkedRecordsException(String message, this.count) : super(message);
}

class RepositoryNetworkException implements Exception {
  final String message;
  const RepositoryNetworkException(this.message);
  @override
  String toString() => message;
}

class RepositoryUnauthorizedException implements Exception {
  final String message;
  const RepositoryUnauthorizedException([this.message = 'Требуется вход в систему.']);
  @override
  String toString() => message;
}

class RepositoryForbiddenException implements Exception {
  final String message;
  const RepositoryForbiddenException([this.message = 'Недостаточно прав для действия.']);
  @override
  String toString() => message;
}

class RepositoryNotFoundException implements Exception {
  final String message;
  const RepositoryNotFoundException([this.message = 'Запись не найдена.']);
  @override
  String toString() => message;
}
