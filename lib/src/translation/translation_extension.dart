import '../../widgetbook/services/locator.dart';
export '../../widgetbook/services/locator.dart';
import 'translation_service.dart';

extension TranslationExtensions on String {
  Future<String> tr({
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) async {
    return await locator<ITranslationService>().translate(
      this,
      category: category,
      parameters: parameters,
      args: args,
    );
  }
}


// For synchronous access (use carefully, only for pre-loaded translations)
extension SyncTranslationExtensions on String {
  String trSync({
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) {
    final service = locator<ITranslationService>();
    final translationCategory = category ?? 'common';

    if (service.isCategoryLoaded(translationCategory)) {
      return service.translateSync(this,category: translationCategory,
          parameters: parameters, args: args);
    }

    return this; // Return key as fallback
  }
}