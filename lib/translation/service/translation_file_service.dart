import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class TranslationFileService {
  static const String _translationsPath = 'assets/translations';
  final knownCategories = ['common'];
  final knownLocales = ['de', 'en'];

  // Platform-spezifische Pfade
  String? _documentsPath;
  final bool _isWeb = kIsWeb || kIsWasm;

  Future<String> get _baseDirectory async {
    if (_isWeb) {
      // Für Web verwenden wir In-Memory Storage
      return 'web_storage';
    }

    if (_documentsPath == null) {
      final directory = await getApplicationDocumentsDirectory();
      _documentsPath = '${directory.path}/translations';
    }
    return _documentsPath!;
  }

  // In-Memory Storage für Web
  final Map<String, Map<String, dynamic>> _webStorage = {};

  // Lade verfügbare Kategorien
  Future<Set<String>> getAvailableCategories() async {
    if (_isWeb) {
      return await _getAvailableCategoriesFromAssets();
    }

    try {
      final baseDir = await _baseDirectory;
      final translationsDir = Directory(baseDir);

      if (!await translationsDir.exists()) {
        // Fallback zu Assets wenn lokales Verzeichnis nicht existiert
        return await _getAvailableCategoriesFromAssets();
      }

      final files = await translationsDir.list().toList();
      final categories = <String>{};

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = file.path.split('/').last;
          if (!fileName.endsWith('_cust.json')) {
            final parts = fileName.replaceAll('.json', '').split('_');
            categories.add(parts.first);
            //if (parts.length >= 2) {
            //  final category = parts.sublist(0, parts.length - 1).join('_');
            //  categories.add(category);
            //}
          }
        }
      }

      // Kombiniere mit Asset-Kategorien
      final assetCategories = await _getAvailableCategoriesFromAssets();
      categories.addAll(assetCategories);

      return categories;
    } catch (e) {
      print('Error loading categories from filesystem, fallback to assets: $e');
      return await _getAvailableCategoriesFromAssets();
    }
  }

  // Lade verfügbare Kategorien aus Assets
  Future<Set<String>> _getAvailableCategoriesFromAssets() async {
    final categories = <String>{};

    // Da wir nicht alle Asset-Dateien scannen können, verwenden wir bekannte Kategorien
    // oder eine Manifest-Date

    for (final category in knownCategories) {
      for (final locale in knownLocales) {
        try {
          final String assetName =
              '${(kIsWeb || kIsWasm) ? '' : 'assets/'}translations/${category}_$locale.json';
          await rootBundle.loadString(assetName);
          categories.add(category);
          break; // Kategorie gefunden, nächste probieren
        } catch (e) {
          // Asset existiert nicht, continue
        }
      }
    }

    return categories;
  }

  // Lade verfügbare Locales
  Future<Set<String>> getAvailableLocales() async {
    if (_isWeb) {
      return await _getAvailableLocalesFromAssets();
    }

    try {
      final baseDir = await _baseDirectory;
      final translationsDir = Directory(baseDir);

      if (!await translationsDir.exists()) {
        return await _getAvailableLocalesFromAssets();
      }

      final files = await translationsDir.list().toList();
      final locales = <String>{};

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final fileName = file.path.split('/').last;
          if (!fileName.endsWith('_cust.json')) {
            final parts = fileName.replaceAll('.json', '').split('_');
            if (parts.length >= 2) {
              final locale = parts.last;
              locales.add(locale);
            }
          }
        }
      }

      // Kombiniere mit Asset-Locales
      final assetLocales = await _getAvailableLocalesFromAssets();
      locales.addAll(assetLocales);

      return locales;
    } catch (e) {
      print('Error loading locales from filesystem, fallback to assets: $e');
      return await _getAvailableLocalesFromAssets();
    }
  }

  // Lade verfügbare Locales aus Assets
  Future<Set<String>> _getAvailableLocalesFromAssets() async {
    final locales = <String>{};

    for (final locale in knownLocales) {
      for (final category in knownCategories) {
        try {
          await rootBundle.loadString(
            'assets/translations/${category}_$locale.json',
          );
          locales.add(locale);
          break; // Locale gefunden, nächste probieren
        } catch (e) {
          // Asset existiert nicht, continue
        }
      }
    }

    return locales;
  }

  // Erstelle oder aktualisiere eine Translation in lokalen Dateien
  Future<void> addTranslationToLocalFiles({
    required String category,
    required String key,
    required String value,
    required String locale,
    bool isCustomizable = false,
    int maxLength = 0,
  }) async {
    if (_isWeb) {
      await _addTranslationToWebStorage(
        category: category,
        key: key,
        value: value,
        locale: locale,
        isCustomizable: isCustomizable,
        maxLength: maxLength,
      );
      return;
    }

    try {
      final baseDir = await _baseDirectory;
      final translationsDir = Directory(baseDir);
      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
      }

      // 1. Aktualisiere die spezifische Locale-Datei
      await _updateLocaleFile(baseDir, category, locale, key, value);

      // 2. Wenn customizable, aktualisiere auch die _cust.json Datei
      if (isCustomizable) {
        await _updateCustomFile(baseDir, category, key, maxLength);
      }

      print('Translation added to local files: $category/$locale/$key');
    } catch (e) {
      print('Error adding translation to local files: $e');
      rethrow;
    }
  }

  // Web-Storage Implementation
  Future<void> _addTranslationToWebStorage({
    required String category,
    required String key,
    required String value,
    required String locale,
    bool isCustomizable = false,
    int maxLength = 0,
  }) async {
    // Locale Datei
    final localeKey = '${category}_$locale';
    if (!_webStorage.containsKey(localeKey)) {
      _webStorage[localeKey] = {};
    }
    _webStorage[localeKey]![key] = value;

    // Customizable Datei
    if (isCustomizable) {
      final custKey = '${category}_cust';
      if (!_webStorage.containsKey(custKey)) {
        _webStorage[custKey] = {};
      }
      _webStorage[custKey]![key] = maxLength;
    }

    print('Translation added to web storage: $category/$locale/$key');
  }

  // Füge einen neuen Key zu allen verfügbaren Locales hinzu
  Future<void> addKeyToAllLocales({
    required String category,
    required String key,
    required Map<String, String> localeValues,
    bool isCustomizable = false,
    int maxLength = 0,
  }) async {
    print(
      '🔧 addKeyToAllLocales: category=$category, key=$key, isCustomizable=$isCustomizable, maxLength=$maxLength',
    );
    print('   - localeValues: $localeValues');

    if (_isWeb) {
      await _addKeyToAllLocalesWeb(
        category: category,
        key: key,
        localeValues: localeValues,
        isCustomizable: isCustomizable,
        maxLength: maxLength,
      );
      return;
    }

    try {
      final baseDir = await _baseDirectory;
      final translationsDir = Directory(baseDir);
      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
        print('   - Created translations directory: $baseDir');
      }

      // Kombiniere verfügbare Locales und übergebene Locales
      final availableLocales = await getAvailableLocales();
      final allTargetLocales = <String>{};

      // Füge alle verfügbaren Locales hinzu
      allTargetLocales.addAll(availableLocales);

      // Füge alle Locales aus localeValues hinzu
      allTargetLocales.addAll(localeValues.keys);

      print('   - Available locales: $availableLocales');
      print('   - Target locales: $allTargetLocales');

      if (allTargetLocales.isEmpty) {
        print('   ⚠️ Warning: No target locales found!');
        return;
      }

      // Für jedes Locale eine Datei erstellen/aktualisieren
      for (final locale in allTargetLocales) {
        final value = localeValues[locale] ?? 'EMPTY';
        print('   - Processing locale: $locale with value: "$value"');

        try {
          await _updateLocaleFile(baseDir, category, locale, key, value);
          print('   ✅ Successfully updated ${category}_$locale.json');
        } catch (e) {
          print('   ❌ Error updating ${category}_$locale.json: $e');
        }
      }

      // Wenn customizable, aktualisiere die _cust.json Datei
      if (isCustomizable) {
        print('   - Processing customizable file with maxLength: $maxLength');
        try {
          await _updateCustomFile(baseDir, category, key, maxLength);
          print('   ✅ Successfully updated ${category}_cust.json');
        } catch (e) {
          print('   ❌ Error updating ${category}_cust.json: $e');
        }
      }

      print('✅ Key $key added to all locales for category $category');
    } catch (e) {
      print('❌ Error adding key to all locales: $e');
      rethrow;
    }
  }

  // Web Implementation für addKeyToAllLocales
  Future<void> _addKeyToAllLocalesWeb({
    required String category,
    required String key,
    required Map<String, String> localeValues,
    bool isCustomizable = false,
    int maxLength = 0,
  }) async {
    print('🌐 _addKeyToAllLocalesWeb: category=$category, key=$key');
    print('   - localeValues: $localeValues');
    print('   - isCustomizable: $isCustomizable, maxLength: $maxLength');

    // Kombiniere verfügbare Locales und übergebene Locales
    final availableLocales = await getAvailableLocales();
    final allTargetLocales = <String>{};

    // Füge alle verfügbaren Locales hinzu
    allTargetLocales.addAll(availableLocales);

    // Füge alle Locales aus localeValues hinzu
    allTargetLocales.addAll(localeValues.keys);

    print('   - Available locales: $availableLocales');
    print('   - Target locales: $allTargetLocales');

    if (allTargetLocales.isEmpty) {
      print('   ⚠️ Warning: No target locales found for web!');
      return;
    }

    // Für jedes Locale im Web Storage aktualisieren
    for (final locale in allTargetLocales) {
      final value = localeValues[locale] ?? 'EMPTY';
      final localeKey = '${category}_$locale';

      print('   - Processing locale: $locale with value: "$value"');

      if (!_webStorage.containsKey(localeKey)) {
        _webStorage[localeKey] = {};
        print('     - Created new web storage entry: $localeKey');
      }

      final oldValue = _webStorage[localeKey]![key];
      _webStorage[localeKey]![key] = value;
      print('     - Updated key "$key": "$oldValue" → "$value"');
    }

    // Wenn customizable, aktualisiere Web Storage
    if (isCustomizable) {
      final custKey = '${category}_cust';
      print('   - Processing customizable web storage: $custKey');

      if (!_webStorage.containsKey(custKey)) {
        _webStorage[custKey] = {};
        print('     - Created new cust web storage entry: $custKey');
      }

      final oldValue = _webStorage[custKey]![key];
      _webStorage[custKey]![key] = maxLength;
      print('     - Updated cust key "$key": $oldValue → $maxLength');
    }

    print('✅ Key $key added to all locales for category $category (Web)');
    printWebStorageStatus();
  }

  // Private Methoden für File System
  Future<void> _updateLocaleFile(
    String baseDir,
    String category,
    String locale,
    String key,
    String value,
  ) async {
    final fileName = '${category}_$locale.json';
    final filePath = '$baseDir/$fileName';
    final file = File(filePath);

    print('      📝 Updating locale file: $fileName');
    print('         - File path: $filePath');
    print('         - Key: $key, Value: $value');

    Map<String, dynamic> content = {};

    // Lade existierenden Inhalt falls vorhanden
    if (await file.exists()) {
      try {
        final existingContent = await file.readAsString();
        content = json.decode(existingContent) as Map<String, dynamic>;
        print('         - Loaded existing content: ${content.length} keys');
      } catch (e) {
        print('         - Error reading existing file $fileName: $e');
        content = {};
      }
    } else {
      // Versuche aus Assets zu laden als Fallback
      try {
        final assetContent = await rootBundle.loadString(
          'assets/translations/$fileName',
        );
        content = json.decode(assetContent) as Map<String, dynamic>;
        print('         - Loaded from assets: ${content.length} keys');
      } catch (e) {
        // Asset existiert nicht, starte mit leerem Inhalt
        print(
          '         - Asset $fileName not found, starting with empty content',
        );
        content = {};
      }
    }

    // Füge/aktualisiere den Key
    final oldValue = content[key];
    content[key] = value;
    print('         - Updated key "$key": "$oldValue" → "$value"');

    // Sortiere die Keys alphabetisch für bessere Lesbarkeit
    final sortedContent = Map.fromEntries(
      content.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    try {
      // Stelle sicher, dass das Verzeichnis existiert
      await file.parent.create(recursive: true);

      // Schreibe zurück in die Datei
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(sortedContent);
      await file.writeAsString(jsonString);

      print(
        '         ✅ Successfully wrote ${jsonString.length} characters to $fileName',
      );

      // Verifikation: Lese die Datei noch einmal um sicherzustellen dass sie korrekt geschrieben wurde
      if (await file.exists()) {
        final verifyContent = await file.readAsString();
        final verifyJson = json.decode(verifyContent) as Map<String, dynamic>;
        if (verifyJson.containsKey(key) && verifyJson[key] == value) {
          print(
            '         ✅ Verification successful: Key "$key" = "${verifyJson[key]}"',
          );
        } else {
          print(
            '         ❌ Verification failed: Key "$key" not found or wrong value',
          );
        }
      } else {
        print(
          '         ❌ Verification failed: File does not exist after writing',
        );
      }
    } catch (e) {
      print('         ❌ Error writing file $fileName: $e');
      rethrow;
    }
  }

  Future<void> _updateCustomFile(
    String baseDir,
    String category,
    String key,
    int maxLength,
  ) async {
    final fileName = '${category}_cust.json';
    final filePath = '$baseDir/$fileName';
    final file = File(filePath);

    print('      ⚙️ Updating custom file: $fileName');
    print('         - File path: $filePath');
    print('         - Key: $key, MaxLength: $maxLength');

    Map<String, dynamic> content = {};

    // Lade existierenden Inhalt falls vorhanden
    if (await file.exists()) {
      try {
        final existingContent = await file.readAsString();
        content = json.decode(existingContent) as Map<String, dynamic>;
        print('         - Loaded existing content: ${content.length} keys');
      } catch (e) {
        print('         - Error reading existing cust file $fileName: $e');
        content = {};
      }
    } else {
      // Versuche aus Assets zu laden als Fallback
      try {
        final assetContent = await rootBundle.loadString(
          'assets/translations/$fileName',
        );
        content = json.decode(assetContent) as Map<String, dynamic>;
        print('         - Loaded from assets: ${content.length} keys');
      } catch (e) {
        // Asset existiert nicht, starte mit leerem Inhalt
        print(
          '         - Asset $fileName not found, starting with empty content',
        );
        content = {};
      }
    }

    // Füge/aktualisiere den Key
    final oldValue = content[key];
    content[key] = maxLength;
    print('         - Updated key "$key": $oldValue → $maxLength');

    // Sortiere die Keys alphabetisch
    final sortedContent = Map.fromEntries(
      content.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    try {
      // Stelle sicher, dass das Verzeichnis existiert
      await file.parent.create(recursive: true);

      // Schreibe zurück in die Datei
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(sortedContent);
      await file.writeAsString(jsonString);

      print(
        '         ✅ Successfully wrote ${jsonString.length} characters to $fileName',
      );

      // Verifikation
      if (await file.exists()) {
        final verifyContent = await file.readAsString();
        final verifyJson = json.decode(verifyContent) as Map<String, dynamic>;
        if (verifyJson.containsKey(key) && verifyJson[key] == maxLength) {
          print(
            '         ✅ Verification successful: Key "$key" = ${verifyJson[key]}',
          );
        } else {
          print(
            '         ❌ Verification failed: Key "$key" not found or wrong value',
          );
        }
      } else {
        print(
          '         ❌ Verification failed: File does not exist after writing',
        );
      }
    } catch (e) {
      print('         ❌ Error writing cust file $fileName: $e');
      rethrow;
    }
  }

  // Erstelle eine neue Kategorie mit leeren Dateien für alle Locales
  Future<void> createNewCategory(String category, Set<String> locales) async {
    if (_isWeb) {
      await _createNewCategoryWeb(category, locales);
      return;
    }

    try {
      final baseDir = await _baseDirectory;
      final translationsDir = Directory(baseDir);
      if (!await translationsDir.exists()) {
        await translationsDir.create(recursive: true);
      }

      // Erstelle leere JSON-Dateien für alle Locales
      for (final locale in locales) {
        final fileName = '${category}_$locale.json';
        final file = File('$baseDir/$fileName');

        if (!await file.exists()) {
          await file.writeAsString('{\n}');
        }
      }

      // Erstelle auch eine leere _cust.json Datei
      final custFileName = '${category}_cust.json';
      final custFile = File('$baseDir/$custFileName');

      if (!await custFile.exists()) {
        await custFile.writeAsString('{\n}');
      }

      print('Created new category: $category');
    } catch (e) {
      print('Error creating new category: $e');
      rethrow;
    }
  }

  // Web Implementation für createNewCategory
  Future<void> _createNewCategoryWeb(
    String category,
    Set<String> locales,
  ) async {
    for (final locale in locales) {
      final localeKey = '${category}_$locale';
      if (!_webStorage.containsKey(localeKey)) {
        _webStorage[localeKey] = {};
      }
    }

    final custKey = '${category}_cust';
    if (!_webStorage.containsKey(custKey)) {
      _webStorage[custKey] = {};
    }

    print('Created new category: $category (Web)');
  }

  // Prüfe ob eine Kategorie existiert
  Future<bool> categoryExists(String category) async {
    final categories = await getAvailableCategories();
    return categories.contains(category);
  }

  // Lade den Inhalt einer lokalen JSON-Datei
  Future<Map<String, String>> loadLocalTranslations(
    String category,
    String locale,
  ) async {
    if (_isWeb) {
      return _loadLocalTranslationsWeb(category, locale);
    }

    try {
      final baseDir = await _baseDirectory;
      final fileName = '${category}_$locale.json';
      final file = File('$baseDir/$fileName');

      Map<String, dynamic> content = {};

      if (await file.exists()) {
        final fileContent = await file.readAsString();
        content = json.decode(fileContent);
      } else {
        // Fallback zu Assets
        try {
          final assetContent = await rootBundle.loadString(
            'assets/translations/$fileName',
          );
          content = json.decode(assetContent);
        } catch (e) {
          print('Asset $fileName not found: $e');
          return {};
        }
      }

      return content.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Error loading local translations for $category/$locale: $e');
      return {};
    }
  }

  // Web Implementation für loadLocalTranslations
  Future<Map<String, String>> _loadLocalTranslationsWeb(
    String category,
    String locale,
  ) async {
    final assetPath =
        '${(kIsWeb || kIsWasm) ? '' : 'assets/'}translations/${category}_$locale'
        '.json';
    final jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Map<String, String> translations = jsonData.map(
      (key, value) => MapEntry(key, value),
    );
    return translations;

  }

  // Lade Customizable Keys aus der _cust.json Datei
  Future<Map<String, int>> loadCustomizableKeys(String category) async {
    if (_isWeb) {
      return _loadCustomizableKeysWeb(category);
    }

    try {
      final baseDir = await _baseDirectory;
      final fileName = '${category}_cust.json';
      final file = File('$baseDir/$fileName');

      Map<String, dynamic> content = {};

      if (await file.exists()) {
        final fileContent = await file.readAsString();
        content = json.decode(fileContent);
      } else {
        // Fallback zu Assets
        try {
          final assetContent = await rootBundle.loadString(
            'assets/translations/$fileName',
          );
          content = json.decode(assetContent);
        } catch (e) {
          print('Customizable file $fileName not found: $e');
          return {};
        }
      }

      return content.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('Error loading customizable keys for $category: $e');
      return {};
    }
  }

  // Web Implementation für loadCustomizableKeys
  Future<Map<String, int>> _loadCustomizableKeysWeb(String category) async{


    final assetPath =
        '${(kIsWeb || kIsWasm) ? '' : 'assets/'}translations/${category}_cust'
        '.json';
    final jsonString = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final Map<String, int> keys = jsonData.map(
            (key, value) => MapEntry(key, value));

    return keys;
  }

  // Lösche einen Key aus allen lokalen Dateien
  Future<void> removeKeyFromAllFiles(String category, String key) async {
    if (_isWeb) {
      await _removeKeyFromAllFilesWeb(category, key);
      return;
    }

    try {
      final baseDir = await _baseDirectory;
      if (!await Directory(baseDir).exists()) {
        return;
      }

      final locales = await getAvailableLocales();

      // Entferne aus allen Locale-Dateien
      for (final locale in locales) {
        await _removeKeyFromLocaleFile(baseDir, category, locale, key);
      }

      // Entferne aus _cust.json
      await _removeKeyFromCustomFile(baseDir, category, key);

      print('Key $key removed from all files for category $category');
    } catch (e) {
      print('Error removing key from files: $e');
      rethrow;
    }
  }

  // Web Implementation für removeKeyFromAllFiles
  Future<void> _removeKeyFromAllFilesWeb(String category, String key) async {
    final locales = await getAvailableLocales();

    // Entferne aus allen Locale-Dateien
    for (final locale in locales) {
      final localeKey = '${category}_$locale';
      _webStorage[localeKey]?.remove(key);
    }

    // Entferne aus _cust.json
    final custKey = '${category}_cust';
    _webStorage[custKey]?.remove(key);

    print('Key $key removed from all web storage for category $category');
  }

  Future<void> _removeKeyFromLocaleFile(
    String baseDir,
    String category,
    String locale,
    String key,
  ) async {
    final fileName = '${category}_$locale.json';
    final file = File('$baseDir/$fileName');

    if (await file.exists()) {
      try {
        final existingContent = await file.readAsString();
        final content = json.decode(existingContent) as Map<String, dynamic>;

        content.remove(key);

        const encoder = JsonEncoder.withIndent('  ');
        await file.writeAsString(encoder.convert(content));
      } catch (e) {
        print('Error removing key from file $fileName: $e');
      }
    }
  }

  Future<void> _removeKeyFromCustomFile(
    String baseDir,
    String category,
    String key,
  ) async {
    final fileName = '${category}_cust.json';
    final file = File('$baseDir/$fileName');

    if (await file.exists()) {
      try {
        final existingContent = await file.readAsString();
        final content = json.decode(existingContent) as Map<String, dynamic>;

        content.remove(key);

        const encoder = JsonEncoder.withIndent('  ');
        await file.writeAsString(encoder.convert(content));
      } catch (e) {
        print('Error removing key from cust file $fileName: $e');
      }
    }
  }

  // Web-spezifische Methoden für Export/Import
  String exportWebStorageAsJson() {
    if (!_isWeb) return '{}';

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(_webStorage);
  }

  void importWebStorageFromJson(String jsonString) {
    if (!_isWeb) return;

    try {
      final Map<String, dynamic> imported = json.decode(jsonString);
      _webStorage.clear();

      for (final entry in imported.entries) {
        if (entry.value is Map<String, dynamic>) {
          _webStorage[entry.key] = Map<String, dynamic>.from(entry.value);
        }
      }

      print('Web storage imported successfully');
    } catch (e) {
      print('Error importing web storage: $e');
    }
  }

  // Debugging
  void printWebStorageStatus() {
    if (_isWeb) {
      print('Web Storage Status:');
      for (final entry in _webStorage.entries) {
        print('  - ${entry.key}: ${entry.value.length} entries');
      }
    }
  }
} // services/translation_file_service.dart
