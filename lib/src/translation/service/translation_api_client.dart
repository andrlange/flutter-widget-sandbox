import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../config/app_config.dart';
import 'translation_models.dart';

part 'translation_api_client.g.dart';

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


