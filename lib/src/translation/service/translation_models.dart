import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

part 'translation_models.g.dart';

@JsonSerializable()
class CreateTranslationRequest extends Equatable {

  const CreateTranslationRequest({
    required this.category,
    required this.locale,
    required this.key,
    required this.value,
    required this.maxLength,
  });

  factory CreateTranslationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTranslationRequestFromJson(json);
  final String category;
  final String locale;
  final String key;
  final String value;
  final int maxLength;

  Map<String, dynamic> toJson() => _$CreateTranslationRequestToJson(this);

  @override
  List<Object?> get props => [category, locale, key, value, maxLength];
}

@JsonSerializable()
class UpdateTranslationRequest extends Equatable {

  const UpdateTranslationRequest({
    required this.category,
    required this.locale,
    required this.key,
    required this.value,
  });

  factory UpdateTranslationRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTranslationRequestFromJson(json);
  final String category;
  final String locale;
  final String key;
  final String value;

  Map<String, dynamic> toJson() => _$UpdateTranslationRequestToJson(this);

  @override
  List<Object?> get props => [category, locale, key, value];
}

@JsonSerializable()
class TranslationResponse extends Equatable {

  const TranslationResponse({
    required this.id,
    required this.category,
    required this.locale,
    required this.key,
    required this.value,
    required this.initialValue,
    required this.maxLength,
    required this.createdAt,
    required this.updatedAt,
    required this.isCustomizable,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) =>
      _$TranslationResponseFromJson(json);

  factory TranslationResponse.checkEmptyValues(TranslationResponse entity) {
    final String initialValue = entity.initialValue.isEmpty
        ? entity.value
        : entity.initialValue;

    final int maxLength = (entity.maxLength > 1024 || entity.maxLength <= 0)
        ? 1024
        : entity.maxLength;

    final dtNow = DateTime.now();
    final String createdAt = (entity.createdAt.isEmpty)
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dtNow)
        : entity.createdAt;
    final String updatedAt = (entity.updatedAt.isEmpty)
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(dtNow)
        : entity.updatedAt;

    return entity.copyWith(
      initialValue: initialValue,
      maxLength: maxLength,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  final int id;
  final String category;
  final String locale;
  final String key;
  final String value;
  final String initialValue;
  final int maxLength;
  final String createdAt;
  final String updatedAt;
  final bool isCustomizable;

  Map<String, dynamic> toJson() => _$TranslationResponseToJson(this);

  TranslationResponse copyWith({
    int? id,
    String? category,
    String? locale,
    String? key,
    String? value,
    String? initialValue,
    int? maxLength,
    String? createdAt,
    String? updatedAt,
    bool? isCustomizable,
  }) {
    return TranslationResponse(
      id: id ?? this.id,
      category: category ?? this.category,
      locale: locale ?? this.locale,
      key: key ?? this.key,
      value: value ?? this.value,
      initialValue: initialValue ?? this.initialValue,
      maxLength: maxLength ?? this.maxLength,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCustomizable: isCustomizable ?? this.isCustomizable,
    );
  }

  @override
  List<Object?> get props => [
    id,
    category,
    locale,
    key,
    value,
    initialValue,
    maxLength,
    createdAt,
    updatedAt,
  ];
}

@JsonSerializable()
class TranslationListResponse extends Equatable {

  const TranslationListResponse({
    required this.translations,
    required this.count,
  });

  factory TranslationListResponse.fromJson(Map<String, dynamic> json) =>
      _$TranslationListResponseFromJson(json);
  final List<TranslationResponse> translations;
  final int count;

  Map<String, dynamic> toJson() => _$TranslationListResponseToJson(this);

  @override
  List<Object?> get props => [translations, count];

  bool hasKey(String key) {
    for (var translation in translations) {
      if (translation.key == key) {
        return true;
      }
    }
    return false;
  }

  @override
  String toString() {
    final StringBuffer sb = StringBuffer();
    sb.write('TranslationListResponse: [');
    for (var translation in translations) {
      sb.write(
        '[${translation.category}:${translation.locale}]=>${translation.key}: '
            '${translation.value}, ',
      );
    }
    sb.write('] count: $count');
    return sb.toString();
  }
}

@JsonSerializable()
class ErrorResponse extends Equatable {

  const ErrorResponse({
    required this.status,
    required this.error,
    required this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);
  final int status;
  final String error;
  final String message;

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);

  @override
  List<Object?> get props => [status, error, message];
}

// Custom exception classes
class TranslationException implements Exception {

  const TranslationException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => 'TranslationException: $message';
}

class TranslationAlreadyExistsException extends TranslationException {
  const TranslationAlreadyExistsException(String message) : super(message, 409);
}

class TranslationNotFoundException extends TranslationException {
  const TranslationNotFoundException(String message) : super(message, 404);
}

// Local translation models
class LocalTranslation extends Equatable {

  const LocalTranslation({required this.key, required this.value});
  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class CustomizableTranslation extends Equatable {

  const CustomizableTranslation({required this.key, required this.maxLength});
  final String key;
  final int maxLength;

  @override
  List<Object?> get props => [key, maxLength];
}
