import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranslationApiService {
  TranslationApiService({
    required this.baseUrl,
    required this.apiKey,
    this.timeout = const Duration(seconds: 10),
  });

  final String baseUrl;
  final String apiKey;
  final Duration timeout;

  Future<Map<String, String>?> translateBatch({
    required List<String> keys,
    required String fromLocale,
    required String toLocale,
    String? category,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/translate/batch'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'keys': keys,
              'from_locale': fromLocale,
              'to_locale': toLocale,
              'category': category,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, String>.from(
          data['translations'] as Map<String, String> ?? {},
        );
      }
    } catch (e) {
      print('Batch translation failed: $e');
    }

    return null;
  }

  Future<String?> translateSingle({
    required String key,
    required String fromLocale,
    required String toLocale,
    String? category,
    String? context,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/translate'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'key': key,
              'from_locale': fromLocale,
              'to_locale': toLocale,
              'category': category,
              'context': context,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translation'] as String?;
      }
    } catch (e) {
      print('Single translation failed for key: $key, error: $e');
    }

    return null;
  }

  Future<bool> reportMissingTranslation({
    required String key,
    required String locale,
    String? category,
    String? suggestedTranslation,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/report-missing'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'key': key,
              'locale': locale,
              'category': category,
              'suggested_translation': suggestedTranslation,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Failed to report missing translation: $e');
      return false;
    }
  }
}
