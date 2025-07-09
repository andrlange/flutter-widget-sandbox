part of 'translation_bloc.dart';

// States
sealed class TranslationState extends Equatable {
  const TranslationState();

  @override
  List<Object?> get props => [];
}

class TranslationInitial extends TranslationState {
  const TranslationInitial();
}

class TranslationLoading extends TranslationState {
  const TranslationLoading();
}

class TranslationInitializing extends TranslationState {
  const TranslationInitializing();
}

class TranslationLoaded extends TranslationState {

  const TranslationLoaded({
    required this.translations,
    required this.filteredTranslations,
    required this.categories,
    required this.locales,
    this.selectedCategory,
    this.selectedLocale,
    this.searchTerm = '',
    required this.totalCount,
  });
  final List<TranslationResponse> translations;
  final List<TranslationResponse> filteredTranslations;
  final Set<String> categories;
  final Set<String> locales;
  final String? selectedCategory;
  final String? selectedLocale;
  final String searchTerm;
  final int totalCount;

  TranslationLoaded copyWith({
    List<TranslationResponse>? translations,
    List<TranslationResponse>? filteredTranslations,
    Set<String>? categories,
    Set<String>? locales,
    String? selectedCategory,
    String? selectedLocale,
    String? searchTerm,
    int? totalCount,
  }) {
    return TranslationLoaded(
      translations: translations ?? this.translations,
      filteredTranslations: filteredTranslations ?? this.filteredTranslations,
      categories: categories ?? this.categories,
      locales: locales ?? this.locales,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      searchTerm: searchTerm ?? this.searchTerm,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  @override
  List<Object?> get props => [
    translations,
    filteredTranslations,
    categories,
    locales,
    selectedCategory,
    selectedLocale,
    searchTerm,
    totalCount,
  ];
}

class TranslationError extends TranslationState {

  const TranslationError(this.message, [this.exception]);
  final String message;
  final TranslationException? exception;

  @override
  List<Object?> get props => [message, exception];
}

class TranslationOperationSuccess extends TranslationState {

  const TranslationOperationSuccess(this.message, [this.translation]);
  final String message;
  final TranslationResponse? translation;

  @override
  List<Object?> get props => [message, translation];
}
