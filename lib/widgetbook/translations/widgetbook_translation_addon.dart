import 'package:widgetbook/widgetbook.dart';
import 'package:flutter/material.dart';
import '/src/translation/translation_extension.dart';
import '/src/translation/translated_text.dart';
import '/src/translation/translation_service.dart';

class TranslationAddon extends WidgetbookAddon<String> {
  TranslationAddon({
    required List<String> locales,
    String? initialLocale,
  }) : super(
    name: 'Translation',
  );

  @override
  Widget buildUseCase(
      BuildContext context,
      Widget child,
      String setting,
      ) {
    return FutureBuilder(
      future: _switchLanguage(setting),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return child;
      },
    );
  }

  Future<void> _switchLanguage(String locale) async {
    print('try to switch language to $locale');
    await TranslationHelper.switchLanguage(locale);
  }

  @override
  // TODO: implement fields
  List<Field> get fields => throw UnimplementedError();

  @override
  String valueFromQueryGroup(Map<String, String> group) {
    // TODO: implement valueFromQueryGroup
    throw UnimplementedError();
  }
}

// Enhanced translation service with sync support
class EnhancedTranslationService extends TranslationService {
  final Map<String, String> _syncCache = {};

  EnhancedTranslationService({
    required super.supportedLocales,
    required super.baseApiUrl,
    required super.apiKey,
    super.initialLocale,
  });

  String translateSync(String key, {String? category, Map<String, dynamic>? parameters, List<dynamic>? args}) {
    final translationCategory = category ?? 'common';
    final cacheKey = '${translationCategory}_$currentLocale\_$key';

    if (_syncCache.containsKey(cacheKey)) {
      return _interpolateParametersSync(_syncCache[cacheKey]!, parameters, args);
    }

    // Try to get from loaded categories using the protected method
    final translation = getTranslationFromCategory(translationCategory, currentLocale, key) ??
        getTranslationFromCategory(translationCategory, 'de', key) ??
        key;

    _syncCache[cacheKey] = translation;
    return _interpolateParametersSync(translation, parameters, args);
  }

  String _interpolateParametersSync(String text, Map<String, dynamic>? parameters, List<dynamic>? args) {
    String result = text;

    // Handle positional arguments first
    if (args != null && args.isNotEmpty) {
      int argIndex = 0;
      while (result.contains('{}') && argIndex < args.length) {
        result = result.replaceFirst('{}', args[argIndex].toString());
        argIndex++;
      }
    }

    // Handle named parameters
    if (parameters != null && parameters.isNotEmpty) {
      parameters.forEach((key, value) {
        result = result.replaceAll('{$key}', value.toString());
      });
    }

    return result;
  }
}

// Translation manager for Widgetbook
class WidgetbookTranslationManager {

  static Future<void> preloadAllCategories() async {
    final categories = ['common'];
    await TranslationHelper.preloadCategories(categories);
  }
}

// Sync extension for Widgetbook
extension SyncTranslation on String {
  String trSync({String? category, Map<String, dynamic>? parameters, List<dynamic>? args}) {
    final service = locator<ITranslationService>();
    if (service is EnhancedTranslationService) {
      return service.translateSync(this, category: category, parameters: parameters, args: args);
    }
    return this; // Fallback
  }
}