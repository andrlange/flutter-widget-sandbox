class TranslationItem {
  final String key;
  final String value;
  final String category;
  final String locale;

  const TranslationItem({
    required this.key,
    required this.value,
    required this.category,
    required this.locale,
  });

  factory TranslationItem.fromJson(Map<String, dynamic> json) {
    return TranslationItem(
      key: json['key'] as String,
      value: json['value'] as String,
      category: json['category'] as String,
      locale: json['locale'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'category': category,
      'locale': locale,
    };
  }
}

class TranslationCategory {
  final String name;
  final Map<String, Map<String, String>> translations; // locale -> key -> value
  bool isLoaded;

  TranslationCategory({
    required this.name,
    Map<String, Map<String, String>>? translations,
    this.isLoaded = false,
  }) : translations = translations ?? {};

  void addTranslation(String locale, String key, String value) {
    translations.putIfAbsent(locale, () => {});
    translations[locale]![key] = value;
  }

  String? getTranslation(String locale, String key) {
    return translations[locale]?[key];
  }
}