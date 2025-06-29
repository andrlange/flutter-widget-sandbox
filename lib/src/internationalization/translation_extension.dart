import '../../widgetbook/services/service_locator.dart';
export '../../widgetbook/services/service_locator.dart';
import 'translation_service.dart';

extension TranslationExtensions on String {
  Future<String> tr({
    String? category,
    Map<String, dynamic>? parameters,
    List<dynamic>? args,
  }) async {
    return await getIt<ITranslationService>().translate(
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
    final service = getIt<ITranslationService>();
    final translationCategory = category ?? 'common';


    // This is a simplified sync version - only works for already loaded translations
    if (service.isCategoryLoaded(translationCategory)) {
      // You'd need to add a sync method to your service for this to work
      return service.translateSync(this); // Fallback to key for now
    }

    return this; // Return key as fallback
  }
}