import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '/src/translation/translation_service.dart';
import '../../src/translation/service/translation_models.dart';
import '../../src/translation/translation_models.dart';
import '../../widgetbook/services/locator.dart';

part 'translation_event.dart';
part 'translation_state.dart';

class TranslationBloc extends Bloc<TranslationEvent, TranslationState> {
  final ITranslationService _service = locator<ITranslationService>();

  String? _selectCategory;
  String? _searchQuery;
  String? _selectedLocale;

  TranslationBloc() : super(const TranslationInitial()) {
    on<InitializeTranslations>(_onInitializeTranslations);
    on<LoadTranslations>(_onLoadTranslations);
    on<CreateTranslationEvent>(_onCreateTranslation);
    on<UpdateTranslationEvent>(_onUpdateTranslation);
    on<DeleteTranslationEvent>(_onDeleteTranslation);
    on<FilterTranslations>(_onFilterTranslations);
    on<SearchTranslations>(_onSearchTranslations);
    on<ResetSearch>(_onResetSearch);
    on<CreateNewTranslationKey>(_onCreateNewTranslationKey);
  }

  Future<void> _onInitializeTranslations(
    InitializeTranslations event,
    Emitter<TranslationState> emit,
  ) async {
    emit(const TranslationInitializing());

    try {
      //await _backendService.initialize();
      add(const LoadTranslations());
    } catch (e) {
      emit(
        TranslationError(
          'Fehler bei der Initialisierung: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  Future<void> _onLoadTranslations(
    LoadTranslations event,
    Emitter<TranslationState> emit,
  ) async {
    emit(const TranslationLoading());

    try {
      final translations = _service.allCategories;

      final categories = await _service.availableCategories;
      final locales = await _service.availableLocales;

      final filteredTranslations = _applyFilters(
        translations,
        event.category,
        event.locale,
        '',
      );

      emit(
        TranslationLoaded(
          translations: _transform(translations),
          filteredTranslations: _transform(filteredTranslations),
          categories: categories,
          locales: locales,
          selectedCategory: event.category,
          selectedLocale: event.locale,
          totalCount: _service.countTranslations(translations),
        ),
      );
    } catch (e) {
      emit(
        TranslationError(
          'Fehler beim Laden der Übersetzungen: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  Future<void> _onCreateTranslation(
    CreateTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      // final response = await _backendService.createTranslation(event.request);

      emit(
        const TranslationOperationSuccess(
          'Übersetzung erfolgreich erstellt',
          // response,
        ),
      );

      // Reload translations
      if (state is TranslationLoaded) {
        final currentState = state as TranslationLoaded;
        add(
          LoadTranslations(
            category: currentState.selectedCategory,
            locale: currentState.selectedLocale,
          ),
        );
      }
    } catch (e) {
      emit(
        TranslationError(
          'Fehler beim Erstellen der Übersetzung: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  Future<void> _onUpdateTranslation(
    UpdateTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    print('Update Translation Event: ${event.request}');
    try {
      final String initialValue = _service.getInitialValue(event.request
          .category, event.request.locale, event.request.key);
      if (await _service.updateTranslation(event.request, initialValue)) {
        emit(
          const TranslationOperationSuccess(
            'Übersetzung erfolgreich aktualisiert',
            // response,
          ),
        );


        final translations = _service.allCategories;

        final categories = await _service.availableCategories;
        final locales = await _service.availableLocales;

        final filteredTranslations = _applyFilters(
          translations,
         _selectCategory,
          _selectedLocale,
          '',
        );

        emit(
          TranslationLoaded(
            translations: _transform(translations),
            filteredTranslations: _transform(filteredTranslations),
            categories: categories,
            locales: locales,
            selectedCategory: _selectCategory,
            selectedLocale: _selectedLocale,
            totalCount: _service.countTranslations(translations),
          ),
        );


      }
    } catch (e) {
      emit(
        TranslationError(
          'Fehler beim Aktualisieren der Übersetzung: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  Future<void> _onDeleteTranslation(
    DeleteTranslationEvent event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      //await _backendService.deleteTranslation(
      //  event.category,
      //  event.locale,
      //  event.key,
      //);
      //
      // Remove translation from current state
      // if (state is TranslationLoaded) {
      //   final currentState = state as TranslationLoaded;
      //   final updatedTranslations = currentState.translations
      //       .where((t) => !(t.category == event.category &&
      //       t.locale == event.locale &&
      //       t.key == event.key))
      //       .toList();
      //
      //   final filteredTranslations = _applyFilters(
      //     updatedTranslations,
      //     currentState.selectedCategory,
      //     currentState.selectedLocale,
      //     currentState.searchTerm,
      //   );
      //
      //   emit(currentState.copyWith(
      //     translations: updatedTranslations,
      //     filteredTranslations: filteredTranslations,
      //     totalCount: updatedTranslations.length,
      //   ));
      // }

      emit(
        const TranslationOperationSuccess('Übersetzung erfolgreich gelöscht'),
      );
    } catch (e) {
      emit(
        TranslationError(
          'Fehler beim Löschen der Übersetzung: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  Future<void> _onFilterTranslations(
    FilterTranslations event,
    Emitter<TranslationState> emit,
  ) async {
    if (state is TranslationLoaded) {
      final currentState = state as TranslationLoaded;

      _selectCategory = event.category;
      _selectedLocale = event.locale;

      final filteredTranslations = _filterAsResponse(
        currentState.translations,
        event.category,
        event.locale,
        currentState.searchTerm,
      );

      emit(
        currentState.copyWith(
          filteredTranslations: filteredTranslations,
          selectedCategory: event.category,
          selectedLocale: event.locale,
        ),
      );
    }
  }

  Future<void> _onSearchTranslations(
    SearchTranslations event,
    Emitter<TranslationState> emit,
  ) async {
    if (state is TranslationLoaded) {
      final currentState = state as TranslationLoaded;

      final filteredTranslations = _filterAsResponse(
        currentState.translations,
        currentState.selectedCategory,
        currentState.selectedLocale,
        event.searchTerm,
      );

      emit(
        currentState.copyWith(
          filteredTranslations: filteredTranslations,
          searchTerm: event.searchTerm,
        ),
      );
    }
  }

  Future<void> _onResetSearch(
    ResetSearch event,
    Emitter<TranslationState> emit,
  ) async {
    if (state is TranslationLoaded) {
      final currentState = state as TranslationLoaded;

      final filteredTranslations = _filterAsResponse(
        currentState.translations,
        currentState.selectedCategory,
        currentState.selectedLocale,
        '',
      );

      emit(
        currentState.copyWith(
          filteredTranslations: filteredTranslations,
          searchTerm: '',
        ),
      );
    }
  }

  Future<void> _onCreateNewTranslationKey(
    CreateNewTranslationKey event,
    Emitter<TranslationState> emit,
  ) async {
    try {
      emit(const TranslationLoading());

      // 1. Erstelle lokale Dateien
      //await _service.createNewTranslationKey(
      //  category: event.category,
      //  key: event.key,
      //  localeValues: event.localeValues,
      //  isCustomizable: event.isCustomizable,
      //  maxLength: event.maxLength,
      //  isNewCategory: event.isNewCategory,
      //  targetLocales: event.targetLocales,
      //);

      // 2. Erstelle Backend-Einträge für alle Locales
      for (final localeEntry in event.localeValues.entries) {
        try {
          //await _backendService.createTranslation(CreateTranslationRequest(
          //  category: event.category,
          //  locale: localeEntry.key,
          //  key: event.key,
          //  value: localeEntry.value,
          //  maxLength: event.maxLength,
          //));
        } catch (e) {
          print(
            'Fehler beim Erstellen von ${event.key} für ${localeEntry.key}: $e',
          );
          // Continue mit anderen Locales auch wenn eins fehlschlägt
        }
      }

      emit(
        TranslationOperationSuccess(
          'Translation Key "${event.key}" erfolgreich erstellt und zu lokalen Dateien hinzugefügt',
        ),
      );

      // Reload translations
      add(const LoadTranslations());
    } catch (e) {
      emit(
        TranslationError(
          'Fehler beim Erstellen des Translation Keys: ${e.toString()}',
          e is TranslationException ? e : null,
        ),
      );
    }
  }

  List<TranslationResponse> _transform(
    Map<String, TranslationCategory> translations,
  ) {
    final List<TranslationResponse> result = [];

    for (final categoryEntry in translations.entries) {
      final category = categoryEntry.key;
      for (final String locale in categoryEntry.value.translations.keys) {
        categoryEntry.value.translations[locale]?.forEach((k, v) {
          final int? maxLength = _service.getCustomizable(category, k);

          final TranslationResponse? backendResponse = _service
              .fetchFromBackendResponse(category, locale, k);

          final String value = backendResponse?.value?? v;
          final String initialValue = backendResponse?.initialValue?? '';
          final String createdAt = backendResponse?.createdAt?? '';
          final String updatedAt = backendResponse?.updatedAt?? '';
          final trans = TranslationResponse(
            id: 0,
            category: category,
            locale: locale,
            key: k,
            value: value,
            maxLength: maxLength ?? v.length,
            initialValue: initialValue,
            createdAt: createdAt,
            updatedAt:updatedAt,
            isCustomizable: maxLength != null,
          );

          final element = TranslationResponse.checkEmptyValues(trans);
          result.add(element);
        });
      }
      ;
    }
    return result;
  }

  Map<String, TranslationCategory> _applyFilters(
    Map<String, TranslationCategory> translations,
    String? category,
    String? locale,
    String searchTerm,
  ) {
    final Map<String, TranslationCategory> filteredTranslations = {};

    // Apply filter on categories
    for (final categoryEntry in translations.entries) {
      if ((category != null && category == categoryEntry.key) ||
          (category == null)) {
        // Apply filter on locales

        final TranslationCategory newTranslationCategory = TranslationCategory(
          name: categoryEntry.key,
        );
        for (final String loc in categoryEntry.value.translations.keys) {
          if ((locale == null) || loc.toLowerCase() == locale.toLowerCase()) {
            // Apply filter on search term

            for (final translation
                in categoryEntry.value.translations[loc]!.entries) {
              if (searchTerm.isEmpty ||
                  translation.key.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  )) {
                final String transKey = translation.key;
                final String transValue = translation.value;

                newTranslationCategory.addTranslation(
                  loc,
                  transKey,
                  transValue,
                );
              }
            }
          }
        }

        if (newTranslationCategory.translations.isNotEmpty) {
          filteredTranslations.putIfAbsent(
            categoryEntry.key,
            () => newTranslationCategory,
          );
        }
      }
    }

    return filteredTranslations;
  }

  List<TranslationResponse> _filterAsResponse(
    List<TranslationResponse> translations,
    String? category,
    String? locale,
    String searchTerm,
  ) {
    final List<TranslationResponse> result = [];

    for (TranslationResponse entity in translations) {
      if ((category == null || entity.category == category) &&
          (locale == null ||
              entity.locale.toLowerCase() == locale.toLowerCase()) &&
          (searchTerm.isEmpty ||
              entity.key.toLowerCase().contains(searchTerm.toLowerCase()))) {
        result.add(TranslationResponse.checkEmptyValues(entity));
      }
    }
    return result;
  }
}
