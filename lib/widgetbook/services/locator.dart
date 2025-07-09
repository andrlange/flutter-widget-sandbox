import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
    var service = locator<ITranslationService>();
    await service.initialize();
    debugPrint('Translation service initializing...');
    await service.loadCategory('common', locale: 'de');
    await service.loadCategory('common', locale: 'en');
    await service.setLocale('de');


    //await service.clearCategory('common', 'en');
  }
}
