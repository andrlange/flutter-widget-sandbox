import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationPersistence {
  static const String _cacheKeyPrefix = 'translation_cache_';
  static const String _categoryLoadedPrefix = 'category_loaded_';
  static const String _lastUpdatePrefix = 'last_update_';

  static Future<void> saveCategoryTranslations(
      String category,
      String locale,
      Map<String, String> translations,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_cacheKeyPrefix${category}_$locale';
    await prefs.setString(key, json.encode(translations));
    await prefs.setString(
      '$_lastUpdatePrefix${category}_$locale',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<Map<String, String>?> loadCategoryTranslations(
      String category,
      String locale,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_cacheKeyPrefix${category}_$locale';
    final jsonString = prefs.getString(key);

    if (jsonString != null) {
      try {
        return Map<String, String>.from(json.decode(jsonString));
      } catch (e) {
        print('Failed to load cached translations: $e');
      }
    }

    return null;
  }

  static Future<bool> isCategoryStale(
      String category,
      String locale, {
        Duration maxAge = const Duration(days: 7),
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdateKey = '$_lastUpdatePrefix${category}_$locale';
    final lastUpdateString = prefs.getString(lastUpdateKey);

    if (lastUpdateString == null) return true;

    try {
      final lastUpdate = DateTime.parse(lastUpdateString);
      return DateTime.now().difference(lastUpdate) > maxAge;
    } catch (e) {
      return true;
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix) ||
          key.startsWith(_categoryLoadedPrefix) ||
          key.startsWith(_lastUpdatePrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
