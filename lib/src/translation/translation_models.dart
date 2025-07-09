class TranslationItem {

  const TranslationItem({
    required this.key,
    required this.value,
    required this.category,
    required this.locale,
    this.defaultValue = "",
    this.isCustomizable = false,
    this.maxLength = 0,
  });

  factory TranslationItem.fromJson(Map<String, dynamic> json) {
    return TranslationItem(
      key: json['key'] as String,
      value: json['value'] as String,
      category: json['category'] as String,
      locale: json['locale'] as String,
      defaultValue: json['defaultValue'] as String,
      isCustomizable: json['isCustomizable'] as bool,
      maxLength: json['maxLength'] as int,
    );
  }
  final String key;
  final String value;
  final String category;
  final String locale;
  final String defaultValue;
  final bool isCustomizable;
  final int maxLength;

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'category': category,
      'locale': locale,
      'defaultValue': defaultValue,
      'isCustomizable': isCustomizable,
      'maxLength': maxLength,
    };
  }
}

class TranslationCategory { // locale -> key -> value


  TranslationCategory({
    required this.name,
    Map<String, Map<String, String>>? translations,
  }) : translations = translations ?? {};
  final String name;
  final Map<String, Map<String, String>> translations;

  void addTranslation(String locale, String key, String value) {
    translations.putIfAbsent(locale, () => {});
    translations[locale]![key] = value;
  }

  String? getTranslation(String locale, String key) {
    return translations[locale]?[key];
  }

  int get countElements {
    int count = 0;
    for (var value in translations.values) {
      count += value.length;
    }
    return count;
  }

  @override
  String toString() {
    return 'TranslationCategory{name: $name, translations: $translations}';
  }
}

class CustomizableCategory { //  key -> value


  CustomizableCategory({
    required this.name,
    Map<String, int>? customizer,
  }) : customizer = customizer ?? {};
  final String name;
  final Map<String, int> customizer;

  void addCustomization(String key, int value) {
    customizer.putIfAbsent(key, () => value);
  }

  int? getCustomization(String category, String key) {
    return customizer[key];
  }

  void get clear => customizer.clear();

  @override
  String toString() {
    return 'CustomizableCategory{name: $name, customizer: $customizer';
  }
}
