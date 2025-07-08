import 'service/translation_models.dart';
import 'translation_models.dart';

abstract class ITranslationService {
  Future<void> initialize();

  Future<String> translate(
    String key, {
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  });

  String translateSync(
    String key, {
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  });

  Future<void> loadCategory(String category, {String? locale});

  Future<void> setLocale(String locale);

  String get currentLocale;

  List<String> get supportedLocales;

  Future<Set<String>> get availableCategories;

  Future<Set<String>> get availableLocales;

  bool isCategoryLoaded(String category);

  int countTranslations(Map<String, TranslationCategory> translations);

  Future<bool> addTranslation({
    required String category,
    required String key,
    required String value,
    required String locale,
    bool isCustomizable = false,
    int maxLength = 0,
  });

  int? getCustomizable(String category, String key);

  Map<String, TranslationCategory> get allCategories;

  Future<bool> updateTranslation(
    UpdateTranslationRequest request,
    String initialValue,
  );

  TranslationResponse? fetchFromBackendResponse(
    String category,
    String locale,
    String key,
  );

  String getInitialValue(String category, String locale, String key);

  Future<void> clearCategory(String category, String locale);

  void debugDumpCache();
}
