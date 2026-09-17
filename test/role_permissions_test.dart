import 'package:flutter_test/flutter_test.dart';
import 'package:tmyv_deneg_web/models/app_user.dart';

void main() {
  group('Права ролей', () {
    test('читатель видит каталог', () {
      expect(Role.reader.permissions.contains(Permission.viewCatalog), isTrue);
    });

    test('читатель не управляет пользователями', () {
      expect(Role.reader.permissions.contains(Permission.manageUsers), isFalse);
    });

    test('библиотекарь управляет выдачами', () {
      expect(Role.librarian.permissions.contains(Permission.manageLoans), isTrue);
    });

    test('библиотекарь не видит админскую статистику', () {
      expect(Role.librarian.permissions.contains(Permission.viewStats), isFalse);
    });

    test('администратор может физически удалять', () {
      expect(Role.admin.permissions.contains(Permission.hardDelete), isTrue);
    });

    test('администратор управляет ролями пользователей', () {
      expect(Role.admin.permissions.contains(Permission.manageUsers), isTrue);
    });
  });
}
