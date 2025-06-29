import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../../src/internationalization/translation_service.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    // Register the translation service as a singleton
    getIt.registerLazySingleton<ITranslationService>(
          () => TranslationService(
        supportedLocales: ['de', 'en'],
        baseApiUrl: 'https://your-api-endpoint.com/api',
        apiKey: 'your-api-key',
        initialLocale: 'de',
      ),
    );

    // Initialize the translation service
    ITranslationService service =  getIt<ITranslationService>();
    await service.initialize();
    debugPrint('Translation service initialized...');
    await service.setLocale('de');
    await service.loadCategory('common');
    await service.setLocale('en');
    await service.loadCategory('common');
    debugPrint('Common category loaded...');

  }
}