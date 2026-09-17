import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_api.dart';
import '../models/app_user.dart';
import '../repositories/repository_errors.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kStarted = 'auth_session_started';
  static const _kDemoUiRole = 'demo_ui_role';

  final SharedPreferences _prefs;
  final AuthApi _api;

  AppUser? _user;
  String? _accessToken;
  Role? _demoUiRole;
  DateTime? _sessionStartedAt;

  AuthNotifier(this._prefs, this._api);

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null && _accessToken != null;
  DateTime? get sessionStartedAt => _sessionStartedAt;

  Role get actualRole => _user?.role ?? Role.reader;
  Role get uiRole => _demoUiRole ?? actualRole;

  bool can(Permission permission) =>
      isAuthenticated && uiRole.permissions.contains(permission);

  Future<void> restore() async {
    _demoUiRole = _readDemoRole();
    final access = _prefs.getString(_kAccess);
    final refresh = _prefs.getString(_kRefresh);
    final started = _prefs.getString(_kStarted);
    _sessionStartedAt = started == null ? null : DateTime.tryParse(started);
    if (access == null) return;

    _accessToken = access;
    try {
      _user = await _api.me(access);
    } on RepositoryUnauthorizedException {
      if (refresh == null) {
        await logout();
        return;
      }
      try {
        await refreshTokens();
      } catch (_) {
        await logout();
        return;
      }
    } catch (_) {
      // Если сервер временно недоступен, токен не удаляем.
    }
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username.trim(), password);
    await _accept(result, resetSessionStart: true);
  }

  Future<void> register({
    required String username,
    required String displayName,
    required String password,
  }) async {
    final result = await _api.register(
      username: username.trim(),
      displayName: displayName.trim(),
      password: password,
    );
    await _accept(result, resetSessionStart: true);
  }

  Future<void> refreshTokens() async {
    final refresh = _prefs.getString(_kRefresh);
    if (refresh == null || refresh.isEmpty) {
      throw const RepositoryUnauthorizedException('Сессия завершена.');
    }
    final result = await _api.refresh(refresh);
    await _accept(result, resetSessionStart: false);
  }

  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    _sessionStartedAt = null;
    await _prefs.remove(_kAccess);
    await _prefs.remove(_kRefresh);
    await _prefs.remove(_kStarted);
    notifyListeners();
  }

  Future<void> reloadDemoRoleFromStorage() async {
    _demoUiRole = _readDemoRole();
    notifyListeners();
  }

  Role? _readDemoRole() {
    final raw = _prefs.getString(_kDemoUiRole);
    if (raw == null || raw.isEmpty) return null;
    return roleFromCode(raw);
  }

  Future<void> _accept(
    AuthResult result, {
    required bool resetSessionStart,
  }) async {
    _accessToken = result.accessToken;
    _user = result.user;
    if (resetSessionStart || _sessionStartedAt == null) {
      _sessionStartedAt = DateTime.now();
    }
    await _prefs.setString(_kAccess, result.accessToken);
    await _prefs.setString(_kRefresh, result.refreshToken);
    await _prefs.setString(
      _kStarted,
      _sessionStartedAt!.toIso8601String(),
    );
    _demoUiRole = _readDemoRole();
    notifyListeners();
  }
}
