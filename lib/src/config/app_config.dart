class AppConfig {
  static const bool isProductionMode = false;
  static const bool enableDebugMode = false;
  static bool addTranslationEnabled = false;

  static const String baseUrlBackend = 'http://localhost:8080/api';
  static const String pathUrlTranslations = '/translations';
  static const String pathUrlDesign = '/design';
  static const String apikey =
      'api-key-tenant-001-secret-12345'; // Replace with your actual API key

  static const translationApiUrl = "$baseUrlBackend$pathUrlTranslations";
  static const designApiUrl = "$baseUrlBackend$pathUrlDesign";


  static const String defaultCategory = 'common';
  static const String fallbackLocale = 'de';
  static const String keySplitter = '.';
  static const List<String> supportedLocales = ['de', 'en'];
  static const String assetFolder = 'assets/';
  static const String translationsFolder = 'translations/';


}
