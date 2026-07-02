import 'package:shared_preferences/shared_preferences.dart';

/// Thin, typed wrapper around [SharedPreferences].
///
/// All local persistence in the app goes through this single service so that
/// storage keys live in one place and the rest of the codebase never touches
/// `SharedPreferences` directly. This keeps persistence swappable and testable.
///
/// Call [StorageService.init] once during app startup before using [instance].
class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static StorageService? _instance;

  /// The initialized singleton. Throws if [init] hasn't been awaited yet.
  static StorageService get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'StorageService.init() must be awaited before use.',
      );
    }
    return i;
  }

  /// Loads SharedPreferences and caches the singleton. Safe to call twice.
  static Future<StorageService> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = StorageService._(prefs);
    return _instance!;
  }

  // ---- Storage keys ------------------------------------------------------
  // Namespaced to avoid collisions and make stored data easy to inspect.
  static const String keyUser = 'nova.user';
  static const String keyThemeMode = 'nova.settings.themeMode';
  static const String keyCart = 'nova.cart';
  static const String keyWishlist = 'nova.wishlist';
  static const String keyOrders = 'nova.orders';
  static const String keySeeded = 'nova.seeded';

  // ---- Generic accessors -------------------------------------------------
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Reads a list of strings (e.g. JSON-encoded cart lines / orders).
  List<String> getStringList(String key) => _prefs.getStringList(key) ?? const [];

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  bool contains(String key) => _prefs.containsKey(key);

  /// Wipes all demo data. Used by the "Reset Demo Data" setting.
  Future<bool> clearAll() => _prefs.clear();
}
