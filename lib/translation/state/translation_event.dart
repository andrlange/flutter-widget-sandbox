part of 'translation_bloc.dart';

// Events
sealed class TranslationEvent extends Equatable {
  const TranslationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeTranslations extends TranslationEvent {
  const InitializeTranslations();
}

class LoadTranslations extends TranslationEvent {
  final String? category;
  final String? locale;

  const LoadTranslations({this.category, this.locale});

  @override
  List<Object?> get props => [category, locale];
}

class CreateTranslationEvent extends TranslationEvent {
  final CreateTranslationRequest request;

  const CreateTranslationEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class UpdateTranslationEvent extends TranslationEvent {
  final UpdateTranslationRequest request;

  const UpdateTranslationEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class DeleteTranslationEvent extends TranslationEvent {
  final String category;
  final String locale;
  final String key;

  const DeleteTranslationEvent({
    required this.category,
    required this.locale,
    required this.key,
  });

  @override
  List<Object?> get props => [category, locale, key];
}

class FilterTranslations extends TranslationEvent {
  final String? category;
  final String? locale;

  const FilterTranslations({this.category, this.locale});

  @override
  List<Object?> get props => [category, locale];
}

class SearchTranslations extends TranslationEvent {
  final String searchTerm;

  const SearchTranslations(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class ResetSearch extends TranslationEvent {
  const ResetSearch();
}

class CreateNewTranslationKey extends TranslationEvent {
  final String category;
  final String key;
  final Map<String, String> localeValues;
  final bool isCustomizable;
  final int maxLength;
  final bool isNewCategory;
  final Set<String> targetLocales;

  const CreateNewTranslationKey({
    required this.category,
    required this.key,
    required this.localeValues,
    required this.isCustomizable,
    required this.maxLength,
    required this.isNewCategory,
    required this.targetLocales,
  });

  @override
  List<Object?> get props => [
    category,
    key,
    localeValues,
    isCustomizable,
    maxLength,
    isNewCategory,
    targetLocales,
  ];
}
