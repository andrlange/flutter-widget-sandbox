import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../config/app_config.dart';
import 'translation_models.dart';

part 'translation_backend_service.g.dart';

@RestApi(baseUrl: AppConfig.translationApiUrl)
abstract class TranslationApiClient {
  factory TranslationApiClient(Dio dio, {String baseUrl}) =
      _TranslationApiClient;

  @POST("")
  Future<TranslationResponse> createTranslation(
    @Body() CreateTranslationRequest request,
  );

  @PUT("")
  Future<TranslationResponse> updateTranslation(
    @Body() UpdateTranslationRequest request,
  );

  @DELETE('')
  Future<void> deleteTranslation(
    @Query('category') String category,
    @Query('locale') String locale,
    @Query("key") String key,
  );

  @GET('/single')
  Future<TranslationResponse> getTranslation(
    @Query('category') String category,
    @Query('locale') String locale,
    @Query('key') String key,
    @Query('initialValue') bool initialValue,
  );

  @GET('/category')
  Future<TranslationListResponse> getTranslationsByCategoryAndLocale(
    @Query('category') String category,
    @Query('locale') String locale,
    @Query('initialValue') bool initialValue,
  );

  @GET('/locale')
  Future<TranslationListResponse> getTranslationsByLocale(
    @Query('locale') String locale,
    @Query('initialValue') bool initialValue,
  );
}

class TranslationBackendService {

  TranslationBackendService(this._fallbackLocale) {
    _dio = Dio();
    _setupDio();
    _apiClient = TranslationApiClient(_dio);
  }
  late final TranslationApiClient _apiClient;
  late final Dio _dio;
  final String _fallbackLocale;

  void _setupDio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': AppConfig.apikey,
      },
    );

    // Logging Interceptor für Development
    if(AppConfig.enableDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => print(object),
        ),
      );
    }

    // Error Handling Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = _handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
            ),
          );
        },
      ),
    );
  }

  TranslationException _handleDioError(DioException error) {
    final errorMessage =  (error.response != null) ? error.response?.data['message'] as String: null;

    switch (error.response?.statusCode) {
      case 409:
        return TranslationAlreadyExistsException(
          errorMessage ?? 'Translation bereits '
          'vorhanden',
        );
      case 404:
        return TranslationNotFoundException(
          errorMessage ?? 'Translation nicht gefunden',
        );
      case 400:
        return TranslationException(
          errorMessage ?? 'Ungültige Anfrage',
          400,
        );
      case 500:
        return TranslationException(
          'Server Fehler: ${error.response?.data['message'] ?? 'Unbekannter Fehler'}',
          500,
        );
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return const TranslationException(
            'Verbindung zum Server fehlgeschlagen',
          );
        }
        return TranslationException('Unbekannter Fehler: ${error.message}');
    }
  }

  Future<TranslationListResponse> getTranslationsByCategoryAndLocale(
    String category,
    String locale,
    bool initialValue,
  ) async {
    try {
      final response = await _apiClient.getTranslationsByCategoryAndLocale(
        category,
        locale,
        initialValue,
      );
      return response;
    } on TranslationException catch (e) {
      print(
        'TranslationBackendService: Error getting translations by '
        'category and locale: ${e.message}',
      );
    }

    return TranslationListResponse(translations: [], count: 0);
  }

  Future<TranslationResponse?> createTranslation({
    required String category,
    required String locale,
    required String key,
    required String value,
    required int maxLength,
  }) async {
    final request = CreateTranslationRequest(
      category: category,
      locale: locale,
      key: key,
      value: value,
      maxLength: maxLength,
    );

    try {
      final response = await _apiClient.createTranslation(request);
      return response;
    } catch (e) {
      print('TranslationBackendService: Error creating translation: ${e}');
    }

    return null;
  }

  Future<TranslationResponse?> updateTranslation({
    required String category,
    required String locale,
    required String key,
    required String value,
    required String initialValue,
  }) async {
    final request = UpdateTranslationRequest(
      category: category,
      locale: locale,
      key: key,
      value: value,
    );

    try {
      // check if translation already exists
      await _apiClient.getTranslation(category, locale, key, false);
    } catch (e) {
      print('TranslationBackendService: Translation not found, create new one');
      try {
        final fallBack = await _apiClient.getTranslation(
          category,
          _fallbackLocale,
          key,
          false,
        );
        await createTranslation(
          category: category,
          locale: locale,
          key: key,
          value: initialValue,
          maxLength: fallBack.maxLength,
        );

        final newTranslation =await _apiClient.updateTranslation(request);

        return newTranslation;
      } catch (e) {
        print('TranslationBackendService: Error creating translation');
        return null;
      }
    }

    try {
      final response = await _apiClient.updateTranslation(request);
      return response;
    } catch (e) {}

    return null;
  }

  Future<void> deleteTranslation({
    required String category,
    required String locale,
    required String key,
  }) async {
    try {
      await _apiClient.deleteTranslation(category, locale, key);
    } catch (e) {
      print('TranslationBackendService: Error updating translation: ${e}');
    }
  }
}
