import 'dart:async';

import '../config/app_config.dart';
import 'service/translation_backend_service.dart';
import 'service/translation_file_service.dart';
import 'service/translation_models.dart';
import 'translation_models.dart';
import 'translation_service_interface.dart';

export 'translation_service_interface.dart';

class TranslationService implements ITranslationService {
  static const String _defaultCategory = AppConfig.defaultCategory;
  static const String _fallbackLocale = AppConfig.fallbackLocale;

  final TranslationFileService _fileService = TranslationFileService();
  final TranslationBackendService _backendService = TranslationBackendService(
    _fallbackLocale,
  );

  final Map<String, TranslationCategory> _categories = {};
  final Map<String, CustomizableCategory> _customizable = {};
  final Map<String, TranslationListResponse> _backendTranslations = {};
  final Map<String, List<String>> _loadedCategories = {};

  Completer<void>? _updateCacheCompleter;

  String _currentLocale = AppConfig.fallbackLocale;
  final List<String> _supportedLocales;
  final String _keySplitter;

  TranslationService({
    required List<String> supportedLocales,
    required String baseApiUrl,
    required String apiKey,
    String keySplitter = AppConfig.keySplitter,
    String? initialLocale,
  }) : _supportedLocales = supportedLocales,
       _keySplitter = keySplitter {
    _currentLocale = initialLocale ?? _fallbackLocale;
  }

  Future<void> waitForCacheUpdated() async {
    while (_updateCacheCompleter != null) {
      await _updateCacheCompleter!.future;
    }
  }

  @override
  Future<void> initialize() async {
    // Load default category
    // await loadCategory(_defaultCategory);
  }

  Future<void> startUpdateCache() async{
    await waitForCacheUpdated();
    _updateCacheCompleter = Completer<void>();
  }

  void stopUpdateCache() {
    _updateCacheCompleter?.complete();
    _updateCacheCompleter = null;
  }

  @override
  Future<void> setLocale(String locale) async {

    _currentLocale = locale;

    // Reload all loaded categories for new locale
    for(var cat in _customizable.keys) {
      await loadCategory(cat, locale: locale);
    }

    _loadedCategories.forEach((cat, locList) async{
      for(var loc in locList) {
        if(loc != locale) {
          await clearCategory(cat, loc);
          print('Reloading category: $cat, locale: $loc');
          await loadCategory(cat, locale: loc);
        }
      }
    });

  }

  @override
  Future<void> clearCategory(String category, String locale) async{
    await startUpdateCache();

    if (_categories[category] != null) {
      _categories[category]?.translations.remove(locale);
    }
    if(_backendTranslations[category]!= null) {
      _backendTranslations[category]!.translations.removeWhere((t) => t
          .locale == locale);
    }
    if(_loadedCategories[category]!= null) {
      _loadedCategories[category]!.remove(locale);
      // remove also customizable from category list
      if(_loadedCategories[category]!.isEmpty){
        if(_customizable[category]!= null) {
          _customizable[category]!.clear;
        }
      }
    }

   stopUpdateCache();
  }

  @override
  Future<void> loadCategory(String category, {String? locale}) async {
    await startUpdateCache();

    final String takeLocale = locale ?? _currentLocale;

    if (isCategoryLoaded(category, locale: takeLocale)) {
      print('Category $category, locale $takeLocale already loaded');
      return;
    }

    print('Loading Category $category, locale $takeLocale ...');
    // Fetch translations from local if not loaded yet
    await _fileService.loadCategoryFromLocal(
      categories: _categories,
      customizable: _customizable,
      category: category,
      currentLocale: takeLocale,
      keySplitter: _keySplitter,
    );

    // Fetch translations from backend if not loaded yet and update cache
    var backendResult = await _backendService
        .getTranslationsByCategoryAndLocale(category, takeLocale, false);

    await _processBackendResult(backendResult, category, locale: takeLocale);

    print('Adding LoadedCategories:Locale $category:$takeLocale');
    _loadedCategories.putIfAbsent(category, () => []);
   _loadedCategories[category]?.add(takeLocale);

    print('Updated LoadedCategories:$_loadedCategories');
    stopUpdateCache();
  }

  Future<void> _processBackendResult(
    TranslationListResponse response,
    String category, {
    String? locale,
  }) async {
    final takeLocale = locale ?? _currentLocale;
    print('Processing backend result for category: $category, locale: $takeLocale');

    if (_backendTranslations[category] == null) {
      _backendTranslations[category] = TranslationListResponse(
        translations: [],
        count: 0,
      );
    }
    for (var trans in response.translations) {
      _backendTranslations[category]?.translations.add(trans);
    }

    // 1) check if all customizable translations exists in the backend response
    _customizable[category]?.customizer.forEach((key, maxLength) async {
      if (!response.hasKey(key)) {
        // a) create new translation for backend
        final String translation =
            getTranslationFromCategory(category, takeLocale, key) ?? 'EMPTY';

        if (!AppConfig.isProductionMode) {
          // b) write new translation to the backend
          final TranslationResponse? response = await _backendService
              .createTranslation(
            category: category,
            locale: takeLocale,
            key: key,
            value: translation,
            maxLength: maxLength,
          );

          if (response == null) {
            print('Failed to create translation for $key');
          }
        }
      } else {
        for (final trans in response.translations) {

          if (_categories[trans.category]!=null && _categories[trans
              .category]!.translations[trans.locale]!=null) {
            if (_categories[trans.category]!.translations[trans.locale]!.keys
                .contains(trans.key)) {

              try {
                _categories[trans.category]!.translations[trans.locale]?.update(
                    key, (value) => trans.value);
              } catch (e) {
                print('Error updating translation: key not in map: $key');
              }
            }
          }
        }
      }
    });

    if (!AppConfig.isProductionMode) {
      // 2) check if there are customizable on the backend not defined
      final List<TranslationResponse> toDelete = [];
      for (var trans in response.translations) {
        if (!isValidDefinedTranslation(
            trans.category, trans.locale, trans.key)) {
          toDelete.add(trans);
        }
      }

      for (var trans in toDelete) {
        await _backendService.deleteTranslation(
          category: trans.category,
          locale: trans.locale,
          key: trans.key,
        );
        print('Deleted translation: $trans');
      }
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

    // Check cache first
    final cacheTranslation = translateSync(
      key,
      category: translationCategory,
      parameters: parameters,
      args: args,
    );
    if (cacheTranslation != key) {
      return cacheTranslation;
    }

    // Ensure category is loaded
    await loadCategory(translationCategory);

    return translateSync(
      key,
      category: translationCategory,
      parameters: parameters,
      args: args,
    );
  }

  @override
  String translateSync(
    String key, {
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) {

    final translationCategory = category ?? _defaultCategory;
    //print('Translating $key, category: $translationCategory, locale:
    //$_currentLocale');
    if (_categories[translationCategory] != null &&
        _categories[translationCategory]!.translations[_currentLocale] !=
            null) {
      String transLocale = _currentLocale;

      String? translation = _categories[translationCategory]?.getTranslation(
        transLocale,
        key,
      );
      // try fallback
      if (translation == null) {
        transLocale = _fallbackLocale;
        translation ??= _categories[translationCategory]?.getTranslation(
          transLocale,
          key,
        );
      }

      if (translation != null &&
          isValidDefinedTranslation(translationCategory, transLocale, key)) {
        //check if was updated in the backend
        final String valueFromBackend =
            fetchFromBackendResponse(
              translationCategory,
              transLocale,
              key,
            )?.value ??
            translation;
        if (valueFromBackend != translation) {
          translation = valueFromBackend;

          _categories[translationCategory]?.translations[transLocale]?[key] =
              translation;
        }
      }

      if (translation != null) {
        translation = _interpolateParameters(translation, parameters, args);
      }
      return translation ?? key;
    }
    return key;
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
  bool isCategoryLoaded(String category, {String? locale}) {
    final takeLocale = locale ?? _currentLocale;
    return _categories[category]?.translations[takeLocale] != null;
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

  @override
  Future<Set<String>> get availableCategories =>
      _fileService.availableCategories();

  @override
  Future<Set<String>> get availableLocales => _fileService.availableLocals();

  @override
  Future<bool> addTranslation({
    required String category,
    required String key,
    required String value,
    required String locale,
    bool isCustomizable = false,
    int maxLength = 0,
  }) {
    return _fileService.addTranslationToLocalFiles(
      category: category,
      key: key,
      value: value,
      locale: locale,
      isCustomizable: isCustomizable,
      maxLength: maxLength,
    );
  }

  @override
  Map<String, TranslationCategory> get allCategories => Map.from(_categories);

  @override
  int countTranslations(Map<String, TranslationCategory> translations) {
    int cnt = 0;
    for (String category in translations.keys) {
      if (translations[category] != null) {
        cnt += translations[category]!.countElements;
      }
    }
    return cnt;
  }

  @override
  int? getCustomizable(String category, String key) {
    return _customizable[category]?.customizer[key];
  }

  @override
  Future<bool> updateTranslation(
    UpdateTranslationRequest request,
    String initialValue,
  ) async {
    try {
      // check allowed
      if (!_customizable[request.category]!.customizer.keys.contains(
        request.key,
      )) {
        return false;
      }

      //String? actualValue = _categories[request.category]
      //    ?.translations[request.locale]?[request.key];

      // update backend
      final result = await _backendService.updateTranslation(
        category: request.category,
        locale: request.locale,
        key: request.key,
        value: request.value,
        initialValue: initialValue,
      );

      if (result != null) {
        // update cache
        _categories[request.category]?.translations[request.locale]?[request
                .key] =
            result.value;

        _backendTranslations[request.category]?.translations.removeWhere(
          (element) =>
              element.category == result.category &&
              element.key == result.key &&
              element.locale == result.locale,
        );
        _backendTranslations[request.category]?.translations.add(result);
        return true;
      }
    } catch (e) {
      print(
        'TranslationService: Failed to update translation. Translation does not exist for ${request.key} in ${request.locale} for category ${request.category}',
      );
      return false;
    }

    throw UnimplementedError();
  }

  @override
  TranslationResponse? fetchFromBackendResponse(
    String category,
    String locale,
    String key,
  ) {
    if (_backendTranslations[category] == null) {
      return null;
    }

    for (var trans in _backendTranslations[category]!.translations) {
      if (trans.category == category &&
          trans.locale == locale &&
          trans.key == key) {
        return trans;
      }
    }

    return null;
  }

  bool isValidDefinedTranslation(String category, String locale, String key) {
    return _categories[category]!.translations[locale]?.containsKey(key) ??
        false;
  }

  @override
  void debugDumpCache() {
    print('TranslationService: Categories Dump:\n$_categories\n');
    print('TranslationService: Customizable Dump:\n$_customizable\n');
    print(
      'TranslationService: BackendTranslation Dump:\n$_backendTranslations\n',
    );
    print('TranslationService: LoadedCategories Dump:\n$_loadedCategories\n');
  }

  @override
  String getInitialValue(String category, String locale, String key) {
    return _categories[category]?.translations[locale]?[key] ?? 'EMPTY';
  }
}
