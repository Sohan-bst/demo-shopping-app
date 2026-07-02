import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/storage_service.dart';

/// Handles (fake) authentication and session persistence.
///
/// There is no real backend: [login] and [register] simply validate that some
/// input was provided, fabricate a [User], and persist it locally so the
/// session survives app restarts. Repositories isolate this data-access logic
/// from the UI/state layer.
class AuthRepository {
  AuthRepository(this._storage);

  final StorageService _storage;
  static const _uuid = Uuid();

  /// Returns the persisted user, or null if no one is signed in.
  User? currentUser() {
    final raw = _storage.getString(StorageService.keyUser);
    if (raw == null) return null;
    try {
      return User.fromJson(raw);
    } catch (_) {
      // Corrupt/legacy payload — treat as signed out.
      return null;
    }
  }

  /// "Signs in" with the given credentials.
  ///
  /// Any syntactically valid, non-empty credentials succeed. The display name
  /// is derived from the email local-part for a realistic feel.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = User(
      id: _uuid.v4(),
      name: _nameFromEmail(email),
      email: email.trim(),
      avatarSeed: email.trim().toLowerCase(),
      memberSince: DateTime.now(),
    );
    await _persist(user);
    return user;
  }

  /// Creates a new (fake) account and signs the user in.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = User(
      id: _uuid.v4(),
      name: name.trim(),
      email: email.trim(),
      avatarSeed: email.trim().toLowerCase(),
      memberSince: DateTime.now(),
    );
    await _persist(user);
    return user;
  }

  /// Persists profile edits for the current session.
  Future<void> updateProfile(User user) => _persist(user);

  /// Clears the persisted session.
  Future<void> logout() async {
    await _storage.remove(StorageService.keyUser);
  }

  Future<void> _persist(User user) =>
      _storage.setString(StorageService.keyUser, user.toJson());

  /// Turns `ada.lovelace@x.com` into `Ada Lovelace`.
  String _nameFromEmail(String email) {
    final local = email.trim().split('@').first;
    final words = local
        .split(RegExp(r'[._\-]+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .toList();
    return words.isEmpty ? 'Nova Shopper' : words.join(' ');
  }
}
