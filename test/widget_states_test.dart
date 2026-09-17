import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmyv_deneg_web/models/app_user.dart';
import 'package:tmyv_deneg_web/screens/login_screen.dart';
import 'package:tmyv_deneg_web/screens/register_screen.dart';
import 'package:tmyv_deneg_web/widgets/entity_table.dart';
import 'package:tmyv_deneg_web/widgets/list_state_view.dart';
import 'package:tmyv_deneg_web/widgets/permission_gate.dart';

void main() {
  testWidgets('состояние загрузки показывает индикатор', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingStateView())),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Загрузка данных…'), findsOneWidget);
  });

  testWidgets('пустой результат показывает сообщение', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: EmptyStateView(onReset: () {}))),
    );
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });

  testWidgets('ошибка показывает кнопку повтора', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorStateView(message: 'Сервер недоступен', onBackToNormal: () {}),
        ),
      ),
    );
    expect(find.text('Ошибка загрузки'), findsOneWidget);
    expect(find.text('Повторить'), findsOneWidget);
  });

  testWidgets('на узком экране EntityTable показывает карточки', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntityTable<String>(
            items: const ['Книга'],
            idOf: (_) => 1,
            columns: [TableColumnSpec(label: 'Название', build: (v) => Text(v))],
          ),
        ),
      ),
    );
    expect(find.text('Название'), findsOneWidget);
    expect(find.text('Книга'), findsOneWidget);
  });

  testWidgets('валидация входа срабатывает на пустые поля', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '');
    await tester.enterText(fields.at(1), '');
    await tester.tap(find.text('Войти'));
    await tester.pump();
    expect(find.text('Введите логин'), findsOneWidget);
    expect(find.text('Введите пароль'), findsOneWidget);
  });

  testWidgets('недоступный элемент скрывается для читателя', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PermissionGate(
            role: Role.reader,
            permission: Permission.manageUsers,
            child: Text('Управление пользователями'),
          ),
        ),
      ),
    );
    expect(find.text('Управление пользователями'), findsNothing);
  });
}
