import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../../src/config/app_config.dart';
import '../../src/translation/translation_service.dart';

final GetIt locator = GetIt.instance;

class Locator {
  static Future<void> setup() async {
    // Register the translation service as a singleton
    locator.registerSingleton<ITranslationService>(
      TranslationService(
        supportedLocales: AppConfig.supportedLocales,
        baseApiUrl: AppConfig.translationApiUrl,
        apiKey: AppConfig.apikey,
        initialLocale: AppConfig.fallbackLocale,
        keySplitter: AppConfig.keySplitter,
      ),
    );

    // Initialize the translation service
    ITranslationService service = locator<ITranslationService>();
    await service.initialize();
    debugPrint('Translation service initialized...');
    await service.setLocale('de');
    await service.loadCategory('common');
    await service.setLocale('en');
    await service.loadCategory('common');
    await service.setLocale('de');

  }
}
