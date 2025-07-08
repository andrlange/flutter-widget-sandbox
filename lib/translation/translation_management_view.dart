import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:widgetbook_example/src/config/app_config.dart';
import 'dialog/translation_dialog.dart';
import 'state/translation_bloc.dart';
import '../src/translation/service/translation_models.dart';

class TranslationManagementView extends StatelessWidget {
  const TranslationManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TranslationBloc()..add(const InitializeTranslations()),
      child: const _TranslationManagementView(),
    );
  }
}

class _TranslationManagementView extends StatefulWidget {
  const _TranslationManagementView({super.key});

  @override
  State<_TranslationManagementView> createState() =>
      _TranslationManagementViewState();
}

class _TranslationManagementViewState
    extends State<_TranslationManagementView> {
  final _searchController = TextEditingController();
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, bool> _editingStates = {};

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getTranslationKey(TranslationResponse translation) {
    return '${translation.category}_${translation.locale}_${translation.key}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
      ),
      floatingActionButton: BlocBuilder<TranslationBloc, TranslationState>(
        builder: (context, state) {
          if (state is TranslationLoaded && !AppConfig.isProductionMode &&
              AppConfig.addTranslationEnabled) {
            return FloatingActionButton.extended(
              onPressed: () => _showCreateTranslationDialog(context, state),
              icon: const Icon(Icons.add),
              label: const Text('Neue Übersetzung'),
              tooltip: 'Neue Übersetzung erstellen',
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocListener<TranslationBloc, TranslationState>(
        listener: (context, state) {
          if (state is TranslationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is TranslationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<TranslationBloc, TranslationState>(
          builder: (context, state) {
            if (state is TranslationInitial ||
                state is TranslationInitializing) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Initialisiere Translation Service...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lade lokale Dateien und synchronisiere mit Backend',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (state is TranslationLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Lade Übersetzungen...'),
                  ],
                ),
              );
            }

            if (state is TranslationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fehler beim Laden',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TranslationBloc>().add(
                          const InitializeTranslations(),
                        );
                      },
                      child: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              );
            }

            if (state is TranslationLoaded) {
              return Column(
                children: [
                  _buildFiltersAndSearch(context, state),
                  _buildStatsBar(state),
                  Expanded(child: _buildTranslationsList(context, state)),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFiltersAndSearch(BuildContext context, TranslationLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategorie',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Alle Kategorien'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Alle Kategorien'),
                    ),
                    ...state.categories.map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<TranslationBloc>().add(
                      FilterTranslations(
                        category: value,
                        locale: state.selectedLocale,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.selectedLocale,
                  decoration: const InputDecoration(
                    labelText: 'Sprache',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Alle Sprachen'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Alle Sprachen'),
                    ),
                    ...state.locales.map(
                      (locale) => DropdownMenuItem<String>(
                        value: locale,
                        child: Text(locale.toUpperCase()),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    context.read<TranslationBloc>().add(
                      FilterTranslations(
                        category: state.selectedCategory,
                        locale: value,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Suchen...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<TranslationBloc>().add(
                          const ResetSearch(),
                        );
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              context.read<TranslationBloc>().add(SearchTranslations(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(TranslationLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.filteredTranslations.length} von ${state.totalCount} Übersetzungen',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              if (state.searchTerm.isNotEmpty)
                Chip(
                  label: Text('Suche: "${state.searchTerm}"'),
                  onDeleted: () {
                    _searchController.clear();
                    context.read<TranslationBloc>().add(const ResetSearch());
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                ),
            ],
          ),
          // Cache-Info nur in Debug-Mode anzeigen
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Cache: ${state.categories.length} Kategorien, ${state.locales.length} Sprachen',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTranslationsList(BuildContext context, TranslationLoaded state) {
    if (state.filteredTranslations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.translate,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Übersetzungen gefunden',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versuche andere Filter oder Suchbegriffe',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredTranslations.length,
      itemBuilder: (context, index) {
        final TranslationResponse translation =
            state.filteredTranslations[index];
        return _buildTranslationCard(context, translation);
      },
    );
  }

  Widget _buildTranslationCard(
    BuildContext context,
    TranslationResponse translation,
  ) {
    final key = _getTranslationKey(translation);
    final isEditing = _editingStates[key] ?? false;

    if (!_editControllers.containsKey(key)) {
      _editControllers[key] = TextEditingController(text: translation.value);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translation.key,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(translation.category),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(translation.locale.toUpperCase()),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.tertiaryContainer,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: translation.isCustomizable
                                ? Text(
                                    'CUSTOMIZABLE : ${translation.maxLength}',
                                  )
                                : Text('FIXED'),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.onTertiary,
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onTertiaryContainer,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (translation.isCustomizable && !AppConfig.isProductionMode)
                  PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        setState(() {
                          _editingStates[key] = true;
                        });
                        break;
                      case 'reset':
                        _editControllers[key]?.text = translation.initialValue;
                        _updateTranslation(
                          context,
                          translation,
                          translation.initialValue,
                        );
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, translation);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (translation.isCustomizable)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Bearbeiten'),
                          ],
                        ),
                      ),
                    if (translation.isCustomizable)
                      const PopupMenuItem(
                        value: 'reset',
                        child: Row(
                          children: [
                            Icon(Icons.restore),
                            SizedBox(width: 8),
                            Text('Zurücksetzen'),
                          ],
                        ),
                      ),
                    //const PopupMenuItem(
                    //  value: 'delete',
                    //  child: Row(
                    //    children: [
                    //      Icon(Icons.delete, color: Colors.red),
                    //      SizedBox(width: 8),
                    //      Text('Löschen', style: TextStyle(color: Colors
    //      .red)),
                    //    ],
                    //  ),
                    //),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isEditing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  translation.value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ] else ...[
              TextField(
                controller: _editControllers[key],
                maxLength: translation.maxLength > 0
                    ? translation.maxLength
                    : 1024,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Übersetzung',
                  helperText: translation.maxLength > 0
                      ? 'Maximal ${translation.maxLength} Zeichen'
                      : 'Maximal 1024 Zeichen',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          final newValue = _editControllers[key]?.text ?? '';
                          if (newValue != translation.value) {
                            _updateTranslation(context, translation, newValue);
                          }
                          setState(() {
                            _editingStates[key] = false;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _editControllers[key]?.text = translation.value;
                          setState(() {
                            _editingStates[key] = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (translation.value != translation.initialValue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Original: "${translation.initialValue}"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            if(translation.isCustomizable) Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Erstellt: ${_formatDate(translation.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (translation.createdAt != translation.updatedAt)
                  Text(
                    'Geändert: ${_formatDate(translation.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateTranslation(
    BuildContext context,
    TranslationResponse translation,
    String newValue,
  ) {
    context.read<TranslationBloc>().add(
      UpdateTranslationEvent(
        UpdateTranslationRequest(
          category: translation.category,
          locale: translation.locale,
          key: translation.key,
          value: newValue,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TranslationResponse translation,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Übersetzung löschen'),
        content: Text(
          'Möchten Sie die Übersetzung "${translation.key}" wirklich löschen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TranslationBloc>().add(
                DeleteTranslationEvent(
                  category: translation.category,
                  locale: translation.locale,
                  key: translation.key,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _showCreateTranslationDialog(
    BuildContext context,
    TranslationLoaded state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CreateTranslationDialog(
        availableCategories: state.categories,
        availableLocales: state.locales,
        onCreateTranslation: (data) {
          context.read<TranslationBloc>().add(
            CreateNewTranslationKey(
              category: data.category,
              key: data.key,
              localeValues: data.localeValues,
              isCustomizable: data.isCustomizable,
              maxLength: data.maxLength,
              isNewCategory: data.isNewCategory,
              targetLocales: data.targetLocales,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
