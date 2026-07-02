import 'package:flutter/foundation.dart';

import '../constants/app_durations.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';
import '../services/analytics/analytics_service.dart';

/// Authentication lifecycle states used to drive UI and routing.
enum AuthStatus {
  /// Session not yet restored from storage.
  unknown,

  /// A user is signed in.
  authenticated,

  /// No user is signed in.
  unauthenticated,
}

/// Exposes authentication state to the widget tree and mediates login,
/// registration, profile edits and logout through [AuthRepository].
///
/// A short artificial delay is added to auth actions so loading states are
/// exercised, mimicking real network latency.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo, this._analytics) {
    _restore();
  }

  final AuthRepository _repo;
  final AnalyticsService _analytics;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _busy = false;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isBusy => _busy;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Restores any persisted session on startup.
  void _restore() {
    _user = _repo.currentUser();
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _run(
      () => _repo.login(email: email, password: password),
      event: AnalyticsEvents.login,
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _run(
      () => _repo.register(name: name, email: email, password: password),
      event: AnalyticsEvents.register,
    );
  }

  /// Applies profile edits to the current session.
  Future<void> updateProfile({String? name, String? email}) async {
    final current = _user;
    if (current == null) return;
    final updated = current.copyWith(name: name, email: email);
    await _repo.updateProfile(updated);
    _user = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repo.logout();
    _analytics.logEvent(AnalyticsEvents.logout);
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Shared runner for auth actions: toggles [isBusy], simulates latency,
  /// captures errors, updates [status] and fires [event] on success.
  Future<bool> _run(
    Future<User> Function() action, {
    required String event,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(AppDurations.fakeNetwork);
      _user = await action();
      _status = AuthStatus.authenticated;
      _analytics.logEvent(event, params: {'email': _user?.email});
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
