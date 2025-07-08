import 'package:flutter/material.dart';
import 'translation_service.dart';
import 'translation_extension.dart';

class TranslatedText extends StatelessWidget {
  final String translationKey;
  final String? category;
  final Map<String, dynamic>? parameters;
  final List<dynamic>? args;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedText(
    this.translationKey, {
    super.key,
    this.category,
    this.parameters,
    this.args,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final String syncCategory = category ?? 'common';

    final String syncTranslation = translationKey.trSync(
      category: syncCategory,
      parameters: parameters,
      args: args,
    );

    if (syncTranslation != translationKey) {
      return Text(
        syncTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return FutureBuilder<String>(
      future: translationKey.tr(
        category: category,
        parameters: parameters,
        args: args,
      ),
      builder: (context, snapshot) {
        //(!snapshot.hasData) return SizedBox.shrink();

        final String? text = (!snapshot.hasData)
            ? null
            : snapshot.data ?? translationKey;

        return text!=null ? Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ) : SizedBox.shrink();
      },
    );
  }
}

// For Widgetbook usage
class TranslationHelper {
  static Future<void> preloadCategories(List<String> categories) async {
    final service = locator<ITranslationService>();
    await Future.wait(
      categories.map((category) => service.loadCategory(category)),
    );
  }

  static Future<void> switchLanguage(String locale) async {
    final service = locator<ITranslationService>();
    await service.setLocale(locale);
  }

  static bool isCategoryLoaded(String category) {
    final service = locator<ITranslationService>();
    return service.isCategoryLoaded(category);
  }
}
