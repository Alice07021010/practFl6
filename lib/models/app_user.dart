enum Role { reader, librarian, admin }

enum Permission {
  viewCatalog,
  viewOwnLoans,
  renewOwnLoan,
  manageBooks,
  manageReferences,
  manageReaders,
  manageLoans,
  manageUsers,
  viewStats,
  hardDelete,
  restoreRecords,
}

extension RoleX on Role {
  String get code => name;

  String get label => switch (this) {
        Role.reader => 'Читатель',
        Role.librarian => 'Библиотекарь',
        Role.admin => 'Администратор',
      };

  Set<Permission> get permissions => switch (this) {
        Role.reader => {
            Permission.viewCatalog,
            Permission.viewOwnLoans,
            Permission.renewOwnLoan,
          },
        Role.librarian => {
            Permission.viewCatalog,
            Permission.manageBooks,
            Permission.manageReferences,
            Permission.manageReaders,
            Permission.manageLoans,
          },
        Role.admin => {
            Permission.viewCatalog,
            Permission.manageBooks,
            Permission.manageReferences,
            Permission.manageReaders,
            Permission.manageLoans,
            Permission.manageUsers,
            Permission.viewStats,
            Permission.hardDelete,
            Permission.restoreRecords,
          },
      };
}

Role roleFromCode(String? value) => switch (value) {
      'librarian' => Role.librarian,
      'admin' => Role.admin,
      _ => Role.reader,
    };

class AppUser {
  final int id;
  final String username;
  final String displayName;
  final Role role;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        role: roleFromCode(json['role'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'role': role.code,
      };
}

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json['accessToken'] as String? ?? '',
        refreshToken: json['refreshToken'] as String? ?? '',
        user: AppUser.fromJson(
          Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
        ),
      );
}
