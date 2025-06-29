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
    return FutureBuilder<String>(
      future: translationKey.tr(
        category: category,
        parameters: parameters,
        args: args,
      ),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return const SizedBox.shrink();

        final text = snapshot.data ?? translationKey;

        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

// For Widgetbook usage
class TranslationHelper {
  static Future<void> preloadCategories(List<String> categories) async {
    final service = getIt<ITranslationService>();
    await Future.wait(
      categories.map((category) => service.loadCategory(category)),
    );
  }

  static Future<void> switchLanguage(String locale) async {
    final service = getIt<ITranslationService>();
    await service.setLocale(locale);
  }

  static bool isCategoryLoaded(String category) {
    final service = getIt<ITranslationService>();
    return service.isCategoryLoaded(category);
  }
}