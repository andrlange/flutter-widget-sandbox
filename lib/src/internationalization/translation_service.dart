import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'translation_models.dart';
import 'translation_service_interface.dart';
export 'translation_service_interface.dart';

class TranslationService implements ITranslationService {
  static const String _defaultCategory = 'common';
  static const String _fallbackLocale = 'de';

  final Map<String, TranslationCategory> _categories = {};
  final Map<String, String> _cache = {}; // cacheKey -> translation

  String _currentLocale = 'de';
  final List<String> _supportedLocales;
  final String _baseApiUrl;
  final String _apiKey;

  TranslationService({
    required List<String> supportedLocales,
    required String baseApiUrl,
    required String apiKey,
    String? initialLocale,
  }) : _supportedLocales = supportedLocales,
       _baseApiUrl = baseApiUrl,
       _apiKey = apiKey {
    _currentLocale = initialLocale ?? _fallbackLocale;
  }

  @override
  Future<void> initialize() async {
    // Load default category
    await loadCategory(_defaultCategory);
  }

  @override
  Future<void> setLocale(String locale) async {
    if (!_supportedLocales.contains(locale)) {
      throw ArgumentError('Unsupported locale: $locale');
    }

    final oldLocale = _currentLocale;
    _currentLocale = locale;

    // Clear cache when locale changes
    //debugPrint('TranslationService: Clearing cache for locale: $oldLocale');
    //_cache.clear();

    // Reload all loaded categories for new locale
    final loadedCategories = _categories.keys
        .where((cat) => _categories[cat]!.isLoaded)
        .toList();

    for (final category in loadedCategories) {
      await _loadCategoryFromLocal(category);
    }
  }

  @override
  Future<void> loadCategory(String category) async {
    if (_categories[category]?.isLoaded == true) {
      return; // Already loaded
    }

    await _loadCategoryFromLocal(category);
    _categories[category]?.isLoaded = true;
  }

  Future<void> _loadCategoryFromLocal(String category) async {
    try {
      final assetPath = '${(kIsWeb ||
          kIsWasm) ? '' : 'assets/'}translations/${category}_$_currentLocale'
          '.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _categories.putIfAbsent(
        category,
        () => TranslationCategory(name: category),
      );

      jsonData.forEach((key, value) {
        if (value is String) {
          _categories[category]!.addTranslation(_currentLocale, key, value);
          final String cacheKey = '${category}_${_currentLocale}_$key';
          _cache.putIfAbsent(cacheKey, () => value);
        }
      });

    } catch (e) {
      debugPrint(
        'Warning: Could not load local translations for category: $category, locale: $_currentLocale',
      );
      _categories.putIfAbsent(
        category,
        () => TranslationCategory(name: category),
      );
    }
  }

  @override
  Future<String> translate(
    String key, {
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) async {
    final translationCategory = category ?? _defaultCategory;
    final cacheKey = '${translationCategory}_${_currentLocale}_$key';

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      return _interpolateParameters(_cache[cacheKey]!, parameters, args);
    }

    // Ensure category is loaded
    await loadCategory(translationCategory);
    // Check cache first
    if (_cache.containsKey(cacheKey)) {

      final String result = _interpolateParameters(
        _cache[cacheKey]!,
        parameters,
        args,
      );
      return result;
    }

    // Try to get from local translations
    String? translation = _categories[translationCategory]?.getTranslation(
      _currentLocale,
      key,
    );

    // If not found, try fallback locale
    if (translation == null && _currentLocale != _fallbackLocale) {
      translation = _categories[translationCategory]?.getTranslation(
        _fallbackLocale,
        key,
      );
    }

    // If still not found, try API
    translation ??= await _fetchFromApi(key, translationCategory);

    // If still not found, return key as fallback
    translation ??= key;

    // Cache the result
    _cache[cacheKey] = translation;

    return _interpolateParameters(translation, parameters, args);
  }

  @override
  String translateSync(
    String key, {
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) {
    final translationCategory = category ?? _defaultCategory;
    final cacheKey = '${translationCategory}_${_currentLocale}_$key';
    if (_cache.containsKey(cacheKey)) {
      return _interpolateParameters(_cache[cacheKey]!, parameters, args);
    } else {
      debugPrint(
        'TranslationService: Translation not found in cache, cacheKey: '
            '$cacheKey cache: $_cache',
      );
      return key;
    }

  }

  Future<String?> _fetchFromApi(String key, String category) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseApiUrl/translate'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translation = data['translation'] as String?;

        if (translation != null) {
          // Store in local category for future use
          _categories[category]?.addTranslation(
            _currentLocale,
            key,
            translation,
          );
        }

        return translation;
      }
    } catch (e) {
      debugPrint('API translation failed for key: $key, error: $e');
    }

    return null;
  }

  String _interpolateParameters(
    String text,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  ) {
    String result = text;

    // Handle positional arguments first (replace {} with values in order)
    if (args != null && args.isNotEmpty) {
      int argIndex = 0;
      while (result.contains('{}') && argIndex < args.length) {
        result = result.replaceFirst('{}', args[argIndex].toString());
        argIndex++;
      }
    }

    // Handle named parameters (replace {name} with values from map)
    if (parameters != null && parameters.isNotEmpty) {
      parameters.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
    }

    return result;
  }

  @override
  String get currentLocale => _currentLocale;

  @override
  List<String> get supportedLocales => List.unmodifiable(_supportedLocales);

  @override
  bool isCategoryLoaded(String category) {
    return _categories[category]?.isLoaded == true;
  }

  // Protected method for subclasses to access translations
  String? getTranslationFromCategory(
    String category,
    String locale,
    String key,
  ) {
    return _categories[category]?.getTranslation(locale, key);
  }

  // Protected method for subclasses to add translations
  void addTranslationToCategory(
    String category,
    String locale,
    String key,
    String translation,
  ) {
    _categories.putIfAbsent(
      category,
      () => TranslationCategory(name: category),
    );
    _categories[category]!.addTranslation(locale, key, translation);
  }

  // Protected method for subclasses to get category translations
  Map<String, String> getCategoryTranslations(String category, String locale) {
    return _categories[category]?.translations[locale] ?? {};
  }
}
