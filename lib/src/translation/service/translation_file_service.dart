import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../translation_models.dart';

class TranslationFileService {
  Future<void> loadCategoryFromLocal({
    required Map<String, TranslationCategory> categories,
    required Map<String, CustomizableCategory> customizable,
    required String category,
    required String currentLocale,
    required String keySplitter,
  }) async {
    try {
      final assetPath =
          '${(kIsWeb || kIsWasm) ? '' : AppConfig.assetFolder}${AppConfig.translationsFolder}${category}_$currentLocale'
          '.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      categories.putIfAbsent(
        category,
        () => TranslationCategory(name: category),
      );

      jsonData.forEach((key, value) {
        if (value is String) {
          categories[category]!.addTranslation(currentLocale, key, value);
        }
      });
    } catch (e) {
      debugPrint(
        'Warning: Could not load local translations for category: $category, locale: $currentLocale',
      );
      categories.putIfAbsent(
        category,
        () => TranslationCategory(name: category),
      );
    }

    // _cust Files
    try {
      final assetPath =
          '${(kIsWeb || kIsWasm) ? '' : AppConfig.assetFolder}${AppConfig
          .translationsFolder}${category}_cust.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      customizable.putIfAbsent(
        category,
            () => CustomizableCategory(name: category),
      );
      jsonData.forEach((key, value) {
        if (value is int) {
          customizable[category]!.addCustomization(key, value);
        }
      });
    } catch (e) {
      debugPrint(
        'Warning: Could not load local customizable for category: $category',
      );
      customizable.putIfAbsent(
        category,
            () => CustomizableCategory(name: category),
      );
    }

  }

  Future<Set<String>> availableCategories() async {
    try {
      // Load the asset manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter translation files and extract category names
      final Set<String> categories = {};

      for (String assetPath in manifestMap.keys) {
        if (assetPath.startsWith(
              '${AppConfig.assetFolder}${AppConfig.translationsFolder}',
            ) &&
            assetPath.endsWith('.json')) {
          // Extract filename from path
          final fileName = assetPath.split('/').last;

          // Extract category name (everything before the last underscore)
          final category = _extractCategoryFromFileName(fileName);
          if (category != null) {
            categories.add(category);
          }
        }
      }

      return categories;
    } catch (e) {
      print('Error scanning translation categories: $e');
      return {};
    }
  }

  Future<Set<String>> availableLocals() async {
    try {
      // Load the asset manifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter translation files and extract category names
      final Set<String> locales = {};
      final Set<String> categories = await availableCategories();

      if (categories.isNotEmpty) {
        for (String assetPath in manifestMap.keys) {
          if (assetPath.startsWith(
                '${AppConfig.assetFolder}${AppConfig.translationsFolder}',
              ) &&
              assetPath.endsWith('.json')) {
            // Extract filename from path
            final fileName = assetPath.split('/').last;

            // Extract category name (everything before the last underscore)
            final locale = _extractLocaleFromFileName(fileName);
            if (locale != null && locale.toLowerCase()!= 'cust') {
              locales.add(locale);
            }
          }
        }
      }

      return locales;
    } catch (e) {
      print('Error scanning translation locals: $e');
      return {};
    }
  }

  String? _extractCategoryFromFileName(String fileName) {
    if (!fileName.endsWith('.json'.toLowerCase())) {
      return null;
    }

    // Remove .json extension
    final nameWithoutExtension = fileName.substring(0, fileName.length - 5);

    // Find the last underscore
    final lastUnderscoreIndex = nameWithoutExtension.lastIndexOf('_');

    if (lastUnderscoreIndex == -1) {
      // No underscore found, return the whole name
      return nameWithoutExtension;
    }

    // Return everything before the last underscore
    return nameWithoutExtension.substring(0, lastUnderscoreIndex);
  }

  String? _extractLocaleFromFileName(String fileName) {
    if (!fileName.endsWith('.json'.toLowerCase())) {
      return null;
    }

    // Remove .json extension
    final nameWithoutExtension = fileName.substring(0, fileName.length - 5);

    // Find the last underscore
    final lastUnderscoreIndex = nameWithoutExtension.lastIndexOf('_')+1;

    if (lastUnderscoreIndex == -1) {
      // No underscore found, return the whole name
      return nameWithoutExtension;
    }

    // Return everything before the last underscore
    return nameWithoutExtension.substring(lastUnderscoreIndex);
  }

  // Erstelle oder aktualisiere eine Translation in lokalen Dateien
  Future<bool> addTranslationToLocalFiles({
    required String category,
    required String key,
    required String value,
    required String locale,
    bool isCustomizable = false,
    int maxLength = 0,
  }) async {

    if((kIsWeb || kIsWasm)) return false;

    final Set<String> existingCategories = await availableCategories();
    if (!existingCategories.contains(category)) {
     // create the category with all locales and _cust file
      final Set<String> existingLocals = await availableLocals();
      for (var loc in existingLocals) {
        final filePath = '${(kIsWeb || kIsWasm) ? '' : AppConfig
            .assetFolder}${AppConfig.translationsFolder}${category}_$loc'
            '.json';
        final jsonMap = <String, dynamic>{};
        jsonMap[key] = loc == locale ? value : "EMPTY";
        print('Creating new file: $filePath content: $jsonMap');
       // await _saveJsonFile(filePath, jsonMap);
      }
      final filePath = '${(kIsWeb || kIsWasm) ? '' : AppConfig
          .assetFolder}${AppConfig.translationsFolder}${category}_cust.json';
      final jsonMap = <String, dynamic>{};
      if(isCustomizable) {
        jsonMap[key] = maxLength == 0 ? 1024 : maxLength;
      }

      print('Creating new file: $filePath content: $jsonMap');

    }

    // Load the asset manifest
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    return true;
  }
}
