import 'package:flutter/material.dart';

import '../services/storage_service.dart';

/// Holds the app's [ThemeMode] and persists the user's choice.
///
/// Defaults to [ThemeMode.system] and is toggled from the Settings screen.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) {
    _load();
  }

  final StorageService _storage;
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// True when the effective theme is dark (treats "system" as light for the
  /// purposes of the settings toggle's initial value).
  bool get isDark => _mode == ThemeMode.dark;

  void _load() {
    final raw = _storage.getString(StorageService.keyThemeMode);
    _mode = _decode(raw);
    notifyListeners();
  }

  /// Sets an explicit theme mode and persists it.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    await _storage.setString(StorageService.keyThemeMode, _encode(mode));
  }

  /// Convenience toggle between light and dark (used by the settings switch).
  Future<void> toggleDark(bool enabled) =>
      setMode(enabled ? ThemeMode.dark : ThemeMode.light);

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
