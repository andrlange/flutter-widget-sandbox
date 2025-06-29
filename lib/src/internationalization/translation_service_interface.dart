
abstract class ITranslationService {
  Future<void> initialize();
  Future<String> translate(String key, {String? category, Map<String, dynamic>? parameters, List<dynamic>? args});
  String translateSync(String key, {String? category, Map<String, dynamic>?
  parameters, List<dynamic>? args});
  Future<void> loadCategory(String category);
  Future<void> setLocale(String locale);
  String get currentLocale;
  List<String> get supportedLocales;
  bool isCategoryLoaded(String category);
}
