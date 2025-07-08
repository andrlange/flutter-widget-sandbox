import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:widgetbook_example/src/translation/service/translation_file_service.dart';
import '../../src/translation/service/translation_backend_service.dart';
import '../../src/translation/service/translation_models.dart';
//part 'translation_backend_service.g.dart';



class TranslationBackendService {
  late final TranslationApiClient _apiClient;
  late final Dio _dio;
  late final TranslationFileService _fileService;

  // Vollständiger Cache für alle Translations
  final Map<String, TranslationResponse> _translationCache = {};
  final Map<String, Map<String, String>> _localTranslations = {};
  final Map<String, Map<String, CustomizableTranslation>> _customizableKeysByCategory = {};

  // Verfügbare Kategorien und Locales
  Set<String> _availableCategories = {};
  Set<String> _availableLocales = {};

  // Cache Status
  bool _isInitialized = false;
  bool _isLoading = false;

  TranslationBackendService() {
    _dio = Dio();
    _setupDio();
    _apiClient = TranslationApiClient(_dio);
    //_fileService = TranslationFileService();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Logging Interceptor für Development
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print(object),
    ));

    // Error Handling Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        final exception = _handleDioError(error);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: exception,
        ));
      },
    ));
  }

  TranslationException _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case 409:
        return TranslationAlreadyExistsException(
          error.response?.data['message'] ?? 'Translation bereits vorhanden',
        );
      case 404:
        return TranslationNotFoundException(
          error.response?.data['message'] ?? 'Translation nicht gefunden',
        );
      case 400:
        return TranslationException(
          error.response?.data['message'] ?? 'Ungültige Anfrage',
          400,
        );
      case 500:
        return TranslationException(
          'Server Fehler: ${error.response?.data['message'] ?? 'Unbekannter Fehler'}',
          500,
        );
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return const TranslationException('Verbindung zum Server fehlgeschlagen');
        }
        return TranslationException(
          'Unbekannter Fehler: ${error.message}',
        );
    }
  }

  // Vollständige Initialisierung der lokalen Übersetzungen und Backend-Sync
  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _isLoading = true;

    try {
      print('🚀 Starte Translation Service Initialisierung...');

      // Schritt 1: Lade verfügbare Kategorien und Locales aus dem Dateisystem
      await _loadAvailableCategoriesAndLocales();

      // Schritt 2: Lade alle lokalen Translation-Dateien
      await _loadAllLocalTranslations();

      // Schritt 3: Lade alle Customizable Keys aus _cust Dateien
      await _loadAllCustomizableKeys();

      // Schritt 4: Lade alle Translations aus dem Backend basierend auf lokalen Keys
      //await _loadAllBackendTranslations();

      // Schritt 5: Initialisiere fehlende customizable Translations im Backend
      //await _initializeMissingCustomizableTranslations();

      _isInitialized = true;
      print('✅ Translation Service erfolgreich initialisiert');
      print('📊 Cache Status:');
      print('   - Kategorien: ${_availableCategories.length}');
      print('   - Locales: ${_availableLocales.length}');
      print('   - Cached Translations: ${_translationCache.length}');
      print('   - Customizable Keys: ${_getAllCustomizableKeys().length}');

    } catch (e) {
      print('❌ Fehler bei der Initialisierung: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // Schritt 1: Lade verfügbare Kategorien und Locales aus Dateisystem
  Future<void> _loadAvailableCategoriesAndLocales() async {
    print('📂 Lade verfügbare Kategorien und Locales aus Dateisystem...');

    _availableCategories = {}; //await _fileService.getAvailableCategories();
    _availableLocales = {};//await _fileService.getAvailableLocales();

    print('   - Gefundene Kategorien: $_availableCategories');
    print('   - Gefundene Locales: $_availableLocales');
  }

  // Schritt 2: Lade alle lokalen Translation-Dateien
  Future<void> _loadAllLocalTranslations() async {
    print('📄 Lade alle lokalen Translation-Dateien...');

    _localTranslations.clear();

    for (final category in _availableCategories) {
      for (final locale in _availableLocales) {
        try {
          //final translations = await _fileService.loadLocalTranslations(category, locale);
          final cacheKey = '${category}_$locale';
         // _localTranslations[cacheKey] = translations;

         // print('   - Geladen: $cacheKey (${translations.length} Keys)');
        } catch (e) {
          print('   - Fehler beim Laden von ${category}_$locale: $e');
        }
      }
    }
  }

  // Schritt 3: Lade alle Customizable Keys aus _cust Dateien
  Future<void> _loadAllCustomizableKeys() async {
    print('⚙️ Lade alle Customizable Keys...');

    _customizableKeysByCategory.clear();

    for (final category in _availableCategories) {
      try {
        //final customizableKeysData = await _fileService.loadCustomizableKeys(category);
       // final customizableKeys = <String, CustomizableTranslation>{};
       //
       // for (final entry in customizableKeysData.entries) {
       //   customizableKeys[entry.key] = CustomizableTranslation(
       //     key: entry.key,
       //     maxLength: entry.value,
       //   );
       // }

     //   _customizableKeysByCategory[category] = customizableKeys;
     //   print('   - $category: ${customizableKeys.length} customizable Keys');
      } catch (e) {
        print('   - Fehler beim Laden von ${category}_cust.json: $e');
        _customizableKeysByCategory[category] = {};
      }
    }
  }

  // Schritt 4: Lade alle Translations aus dem Backend
  Future<void> _loadAllBackendTranslations() async {
    print('🌐 Lade alle Translations aus dem Backend...');

    _translationCache.clear();
    int loadedCount = 0;
    int errorCount = 0;

    // Sammle alle Keys aus allen lokalen Dateien
    final Set<String> allKeys = {};
    for (final translations in _localTranslations.values) {
      allKeys.addAll(translations.keys);
    }

    print('   - Gefundene Keys in lokalen Dateien: ${allKeys.length}');

    // Lade für jeden Key und jede Kombination aus Backend
    for (final category in _availableCategories) {
      for (final locale in _availableLocales) {
        final localKey = '${category}_$locale';
        final localTranslations = _localTranslations[localKey] ?? {};

        for (final key in localTranslations.keys) {
          try {
            final translation = await _apiClient.getTranslation(category, locale, key, false);
            final cacheKey = _buildCacheKey(category, locale, key);
            _translationCache[cacheKey] = translation;
            loadedCount++;
          } catch (e) {
            // Translation existiert nicht im Backend - das ist normal
            if (e is DioException && e.response?.statusCode == 404) {
              // Ignoriere 404 Fehler
            } else {
              print('   - Fehler beim Laden von $category/$locale/$key: $e');
              errorCount++;
            }
          }
        }
      }
    }

    print('   - Erfolgreich geladen: $loadedCount Translations');
    if (errorCount > 0) {
      print('   - Fehler: $errorCount');
    }
  }

  // Schritt 5: Initialisiere fehlende customizable Translations
  Future<void> _initializeMissingCustomizableTranslations() async {
    print('🔧 Initialisiere fehlende customizable Translations...');

    int createdCount = 0;

    for (final categoryEntry in _customizableKeysByCategory.entries) {
      final category = categoryEntry.key;
      final customizableKeys = categoryEntry.value;

      for (final customizable in customizableKeys.values) {
        for (final locale in _availableLocales) {
          final cacheKey = _buildCacheKey(category, locale, customizable.key);

          // Prüfe ob Translation im Cache (Backend) existiert
          if (!_translationCache.containsKey(cacheKey)) {
            // Hole Wert aus lokalen Dateien
            final localKey = '${category}_$locale';
            final localValue = _localTranslations[localKey]?[customizable.key] ?? 'EMPTY';

            try {
              final translation = await _apiClient.createTranslation(
                CreateTranslationRequest(
                  category: category,
                  locale: locale,
                  key: customizable.key,
                  value: localValue,
                  maxLength: customizable.maxLength,
                ),
              );

              _translationCache[cacheKey] = translation;
              createdCount++;
              print('   - Erstellt: $category/$locale/${customizable.key}');
            } catch (e) {
              print('   - Fehler beim Erstellen von ${customizable.key}: $e');
            }
          }
        }
      }
    }

    if (createdCount > 0) {
      print('   - $createdCount neue Translations erstellt');
    } else {
      print('   - Alle customizable Translations existieren bereits');
    }
  }

  // Cache Helper Methoden
  String _buildCacheKey(String category, String locale, String key) {
    return '$category|$locale|$key';
  }

  Set<String> _getAllCustomizableKeys() {
    final Set<String> allKeys = {};
    for (final customizableKeys in _customizableKeysByCategory.values) {
      allKeys.addAll(customizableKeys.keys);
    }
    return allKeys;
  }

  bool _isKeyCustomizable(String category, String key) {
    return _customizableKeysByCategory[category]?.containsKey(key) ?? false;
  }

  int? _getMaxLengthForKey(String category, String key) {
    return _customizableKeysByCategory[category]?[key]?.maxLength;
  }

  // Öffentliche Cache-Zugriffsmethoden
  List<TranslationResponse> getAllCachedTranslations() {
    return _translationCache.values.toList();
  }

  List<TranslationResponse> getCachedTranslationsByCategory(String category) {
    return _translationCache.values
        .where((t) => t.category == category)
        .toList();
  }

  List<TranslationResponse> getCachedTranslationsByLocale(String locale) {
    return _translationCache.values
        .where((t) => t.locale == locale)
        .toList();
  }

  List<TranslationResponse> getCachedCustomizableTranslations() {
    return _translationCache.values
        .where((t) => _isKeyCustomizable(t.category, t.key))
        .toList();
  }

  TranslationResponse? getCachedTranslation(String category, String locale, String key) {
    final cacheKey = _buildCacheKey(category, locale, key);
    return _translationCache[cacheKey];
  }

  // Cache Update Methoden
  void _updateTranslationInCache(TranslationResponse translation) {
    final cacheKey = _buildCacheKey(translation.category, translation.locale, translation.key);
    _translationCache[cacheKey] = translation;
  }

  void _removeTranslationFromCache(String category, String locale, String key) {
    final cacheKey = _buildCacheKey(category, locale, key);
    _translationCache.remove(cacheKey);
  }

  void _addTranslationToCache(TranslationResponse translation) {
    final cacheKey = _buildCacheKey(translation.category, translation.locale, translation.key);
    _translationCache[cacheKey] = translation;
  }

  // API Methods mit Cache-Integration
  Future<TranslationResponse> createTranslation(
      CreateTranslationRequest request,
      ) async {
    try {
      final response = await _apiClient.createTranslation(request);
      _addTranslationToCache(response);
      return response;
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  Future<TranslationResponse> updateTranslation(
      UpdateTranslationRequest request,
      ) async {
    try {
      final response = await _apiClient.updateTranslation(request);
      _updateTranslationInCache(response);
      return response;
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  Future<void> deleteTranslation(
      String category,
      String locale,
      String key,
      ) async {
    try {
      await _apiClient.deleteTranslation(category, locale, key);
      _removeTranslationFromCache(category, locale, key);
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  Future<TranslationResponse> getTranslation(
      String category,
      String locale,
      String key, [
        bool initialValue = false,
      ]) async {
    // Versuche zuerst aus Cache wenn initialValue nicht gewünscht
    if (!initialValue) {
      final cached = getCachedTranslation(category, locale, key);
      if (cached != null) {
        return cached;
      }
    }

    try {
      final response = await _apiClient.getTranslation(category, locale, key, initialValue);
      _updateTranslationInCache(response);
      return response;
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  Future<TranslationListResponse> getTranslationsByCategoryAndLocale(
      String category,
      String locale, [
        bool initialValue = false,
      ]) async {
    // Verwende Cache wenn möglich
    if (!initialValue && _isInitialized) {
      final cachedTranslations = _translationCache.values
          .where((t) => t.category == category && t.locale == locale)
          .toList();

      return TranslationListResponse(
        translations: cachedTranslations,
        count: cachedTranslations.length,
      );
    }

    try {
      final response = await _apiClient.getTranslationsByCategoryAndLocale(
        category,
        locale,
        initialValue,
      );

      // Aktualisiere Cache mit neuen Daten
      for (final translation in response.translations) {
        _updateTranslationInCache(translation);
      }

      return response;
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  Future<TranslationListResponse> getTranslationsByLocale(
      String locale, [
        bool initialValue = false,
      ]) async {
    // Verwende Cache wenn möglich
    if (!initialValue && _isInitialized) {
      final cachedTranslations = _translationCache.values
          .where((t) => t.locale == locale)
          .toList();

      return TranslationListResponse(
        translations: cachedTranslations,
        count: cachedTranslations.length,
      );
    }

    try {
      final response = await _apiClient.getTranslationsByLocale(locale, initialValue);

      // Aktualisiere Cache mit neuen Daten
      for (final translation in response.translations) {
        _updateTranslationInCache(translation);
      }

      return response;
    } on DioException catch (e) {
      throw e.error as TranslationException;
    }
  }

  // Hilfsmethoden
  Set<String> get availableCategories => _availableCategories;
  Set<String> get availableLocales => _availableLocales;

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  bool isCustomizable(String key) => _getAllCustomizableKeys().contains(key);

  int? getMaxLength(String category, String key) => _getMaxLengthForKey(category, key);

  // Filtere nur customizable Translations aus Cache
  Future<TranslationListResponse> getCustomizableTranslations(
      String? category,
      String? locale,
      ) async {
    if (!_isInitialized) {
      throw const TranslationException('Service not initialized');
    }

    List<TranslationResponse> customizableTranslations =
    getAllCachedTranslations();
    //getCachedCustomizableTranslations();

    // Anwenden der Filter
    if (category != null && category.isNotEmpty) {
      customizableTranslations = customizableTranslations
          .where((t) => t.category == category)
          .toList();
    }

    if (locale != null && locale.isNotEmpty) {
      customizableTranslations = customizableTranslations
          .where((t) => t.locale == locale)
          .toList();
    }

    return TranslationListResponse(
      translations: customizableTranslations,
      count: customizableTranslations.length,
    );
  }

  // Neue Methode für das Erstellen von Translation Keys mit lokalen Dateien
  Future<void> createNewTranslationKey({
    required String category,
    required String key,
    required Map<String, String> localeValues,
    required bool isCustomizable,
    required int maxLength,
    required bool isNewCategory,
    required Set<String> targetLocales,
  }) async {
    print('🚀 createNewTranslationKey started:');
    print('   - category: $category');
    print('   - key: $key');
    print('   - localeValues: $localeValues');
    print('   - isCustomizable: $isCustomizable');
    print('   - maxLength: $maxLength');
    print('   - isNewCategory: $isNewCategory');
    print('   - targetLocales: $targetLocales');

    try {
      // 1. Erstelle neue Kategorie falls notwendig
      if (isNewCategory) {
        print('📁 Creating new category: $category');
        //await _fileService.createNewCategory(category, targetLocales);
        _availableCategories.add(category);

        // Initialisiere leere customizable Keys Map für neue Kategorie
        if (!_customizableKeysByCategory.containsKey(category)) {
          _customizableKeysByCategory[category] = {};
        }
        print('✅ New category created: $category');
      }

      // 2. Füge zu lokalen Dateien hinzu
      print('📝 Adding key to local files...');
     // await _fileService.addKeyToAllLocales(
     //   category: category,
     //   key: key,
     //   localeValues: localeValues,
     //   isCustomizable: isCustomizable,
     //   maxLength: maxLength,
     // );
      print('✅ Key added to local files');

      // 3. Aktualisiere interne Caches
      print('🔄 Updating internal caches...');
      _availableLocales.addAll(targetLocales);

      if (isCustomizable) {
        if (!_customizableKeysByCategory.containsKey(category)) {
          _customizableKeysByCategory[category] = {};
        }
        _customizableKeysByCategory[category]![key] = CustomizableTranslation(
          key: key,
          maxLength: maxLength,
        );
        print('   - Added to customizable keys: $category.$key');
      }

      // 4. Aktualisiere lokale Translation Caches
      for (final localeEntry in localeValues.entries) {
        final cacheKey = '${category}_${localeEntry.key}';
        if (_localTranslations[cacheKey] == null) {
          _localTranslations[cacheKey] = {};
        }
        _localTranslations[cacheKey]![key] = localeEntry.value;
        print('   - Updated local cache: $cacheKey.$key = "${localeEntry.value}"');
      }

      print('✅ Translation Key $key erfolgreich erstellt für Kategorie $category');

      // Debug: Zeige aktuellen Cache-Status
      print('📊 Current cache status:');
      print('   - Available categories: $_availableCategories');
      print('   - Available locales: $_availableLocales');
      print('   - Local translations entries: ${_localTranslations.length}');
      print('   - Customizable keys total: ${_getAllCustomizableKeys().length}');

    } catch (e) {
      print('❌ Fehler beim Erstellen des Translation Keys: $e');
      print('   Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Lösche einen Key aus Backend und lokalen Dateien
  Future<void> deleteTranslationKeyCompletely(
      String category,
      String key,
      ) async {
    try {
      // 1. Lösche aus Backend für alle Locales
      for (final locale in _availableLocales) {
        try {
          await deleteTranslation(category, locale, key);
        } catch (e) {
          print('Fehler beim Löschen von $key aus Backend für $locale: $e');
          // Continue mit anderen Locales
        }
      }

      // 2. Lösche aus lokalen Dateien
     // await _fileService.removeKeyFromAllFiles(category, key);

      // 3. Aktualisiere interne Caches
      _customizableKeysByCategory[category]?.remove(key);

      for (final cacheKey in _localTranslations.keys) {
        _localTranslations[cacheKey]?.remove(key);
      }

      // 4. Entferne aus Translation Cache
      for (final locale in _availableLocales) {
        _removeTranslationFromCache(category, locale, key);
      }

      print('Translation Key $key vollständig gelöscht');
    } catch (e) {
      print('Fehler beim vollständigen Löschen des Keys: $e');
      rethrow;
    }
  }

  // Refresh lokale Kategorien und Locales aus dem Dateisystem
  Future<void> refreshAvailableFromFileSystem() async {
    try {
      //final categoriesFromFiles = await _fileService.getAvailableCategories();
      //final localesFromFiles = await _fileService.getAvailableLocales();

      //_availableCategories.addAll(categoriesFromFiles);
      //_availableLocales.addAll(localesFromFiles);

      print('Verfügbare Kategorien und Locales aus Dateisystem aktualisiert');
    } catch (e) {
      print('Fehler beim Aktualisieren aus Dateisystem: $e');
    }
  }

  // Cache Status und Debug-Informationen
  Map<String, dynamic> getCacheStats() {
    return {
      'isInitialized': _isInitialized,
      'isLoading': _isLoading,
      'categoriesCount': _availableCategories.length,
      'localesCount': _availableLocales.length,
      'translationsCacheCount': _translationCache.length,
      'customizableKeysCount': _getAllCustomizableKeys().length,
      'categories': _availableCategories.toList(),
      'locales': _availableLocales.toList(),
    };
  }

  // Manueller Cache-Refresh (falls Backend-Daten sich extern geändert haben)
  Future<void> refreshBackendCache() async {
    if (!_isInitialized) {
      return;
    }

    print('🔄 Aktualisiere Backend-Cache...');

    try {
      _translationCache.clear();
      await _loadAllBackendTranslations();
      print('✅ Backend-Cache erfolgreich aktualisiert');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren des Backend-Cache: $e');
    }
  }
}