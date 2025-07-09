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

  const LoadTranslations({this.category, this.locale});
  final String? category;
  final String? locale;

  @override
  List<Object?> get props => [category, locale];
}

class CreateTranslationEvent extends TranslationEvent {

  const CreateTranslationEvent(this.request);
  final CreateTranslationRequest request;

  @override
  List<Object?> get props => [request];
}

class UpdateTranslationEvent extends TranslationEvent {

  const UpdateTranslationEvent(this.request);
  final UpdateTranslationRequest request;

  @override
  List<Object?> get props => [request];
}

class DeleteTranslationEvent extends TranslationEvent {

  const DeleteTranslationEvent({
    required this.category,
    required this.locale,
    required this.key,
  });
  final String category;
  final String locale;
  final String key;

  @override
  List<Object?> get props => [category, locale, key];
}

class FilterTranslations extends TranslationEvent {

  const FilterTranslations({this.category, this.locale});
  final String? category;
  final String? locale;

  @override
  List<Object?> get props => [category, locale];
}

class SearchTranslations extends TranslationEvent {

  const SearchTranslations(this.searchTerm);
  final String searchTerm;

  @override
  List<Object?> get props => [searchTerm];
}

class ResetSearch extends TranslationEvent {
  const ResetSearch();
}

class CreateNewTranslationKey extends TranslationEvent {

  const CreateNewTranslationKey({
    required this.category,
    required this.key,
    required this.localeValues,
    required this.isCustomizable,
    required this.maxLength,
    required this.isNewCategory,
    required this.targetLocales,
  });
  final String category;
  final String key;
  final Map<String, String> localeValues;
  final bool isCustomizable;
  final int maxLength;
  final bool isNewCategory;
  final Set<String> targetLocales;

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
