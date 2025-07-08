import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTranslationDialog extends StatefulWidget {
  final Set<String> availableCategories;
  final Set<String> availableLocales;
  final Function(CreateTranslationData) onCreateTranslation;

  const CreateTranslationDialog({
    Key? key,
    required this.availableCategories,
    required this.availableLocales,
    required this.onCreateTranslation,
  }) : super(key: key);

  @override
  State<CreateTranslationDialog> createState() => _CreateTranslationDialogState();
}

class _CreateTranslationDialogState extends State<CreateTranslationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _localeController = TextEditingController();
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _maxLengthController = TextEditingController(text: '0');

  String? _selectedCategory;
  String? _selectedLocale;
  bool _isCustomizable = false;
  bool _isNewCategory = false;
  bool _isNewLocale = false;
  bool _createForAllLocales = true;

  final Map<String, TextEditingController> _localeValueControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialisiere Controller für alle verfügbaren Locales
    for (final locale in widget.availableLocales) {
      _localeValueControllers[locale] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _localeController.dispose();
    _keyController.dispose();
    _valueController.dispose();
    _maxLengthController.dispose();
    for (final controller in _localeValueControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      if (value == '__new__') {
        _selectedCategory = null;
        _isNewCategory = true;
      } else {
        _selectedCategory = value;
        _isNewCategory = false;
        _categoryController.clear();
      }
    });
  }

  void _onLocaleChanged(String? value) {
    setState(() {
      if (value == '__new__') {
        _selectedLocale = null;
        _isNewLocale = true;
      } else {
        _selectedLocale = value;
        _isNewLocale = false;
        _localeController.clear();
      }
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = _isNewCategory ? _categoryController.text : _selectedCategory!;
      final locale = _isNewLocale ? _localeController.text : _selectedLocale!;

      print('🎯 CreateTranslationDialog._onSubmit:');
      print('   - category: $category (isNew: $_isNewCategory)');
      print('   - locale: $locale (isNew: $_isNewLocale)');
      print('   - key: ${_keyController.text}');
      print('   - isCustomizable: $_isCustomizable');
      print('   - maxLength: ${_maxLengthController.text}');
      print('   - createForAllLocales: $_createForAllLocales');

      Map<String, String> localeValues = {};

      if (_createForAllLocales) {
        // Sammle Werte für alle Locales
        final allLocales = Set<String>.from(widget.availableLocales);
        if (_isNewLocale) {
          allLocales.add(locale);
        }

        print('   - Processing all locales: $allLocales');

        for (final loc in allLocales) {
          final controller = _localeValueControllers[loc];
          if (controller != null && controller.text.isNotEmpty) {
            localeValues[loc] = controller.text;
            print('     - $loc: "${controller.text}" (from input)');
          } else {
            localeValues[loc] = 'EMPTY';
            print('     - $loc: "EMPTY" (default)');
          }
        }
      } else {
        // Nur für das ausgewählte Locale
        localeValues[locale] = _valueController.text;
        print('   - Single locale $locale: "${_valueController.text}"');
      }

      final targetLocales = _createForAllLocales
          ? Set<String>.from(widget.availableLocales)
          : {locale};

      if (_isNewLocale) {
        targetLocales.add(locale);
      }

      print('   - Final localeValues: $localeValues');
      print('   - Final targetLocales: $targetLocales');

      final data = CreateTranslationData(
        category: category,
        key: _keyController.text,
        localeValues: localeValues,
        isCustomizable: _isCustomizable,
        maxLength: _isCustomizable ? int.tryParse(_maxLengthController.text) ?? 0 : 0,
        isNewCategory: _isNewCategory,
        targetLocales: targetLocales,
      );

      print('✅ Calling onCreateTranslation with data: ${data.toString()}');
      widget.onCreateTranslation(data);
      Navigator.of(context).pop();
    } else {
      print('❌ Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Neue Übersetzung erstellen',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 32),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategorySection(),
                      const SizedBox(height: 24),
                      _buildLocaleSection(),
                      const SizedBox(height: 24),
                      _buildKeySection(),
                      const SizedBox(height: 24),
                      _buildCustomizableSection(),
                      const SizedBox(height: 24),
                      _buildCreateForAllLocalesSection(),
                      const SizedBox(height: 24),
                      if (_createForAllLocales)
                        _buildAllLocalesValueSection()
                      else
                        _buildSingleValueSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategorie',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Kategorie auswählen oder erstellen',
          ),
          items: [
            ...widget.availableCategories.map(
                  (category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ),
            ),
            const DropdownMenuItem(
              value: '__new__',
              child: Row(
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Neue Kategorie erstellen'),
                ],
              ),
            ),
          ],
          onChanged: _onCategoryChanged,
          validator: (value) {
            if (!_isNewCategory && (value == null || value.isEmpty)) {
              return 'Bitte wählen Sie eine Kategorie';
            }
            return null;
          },
        ),
        if (_isNewCategory) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Neue Kategorie',
              hintText: 'z.B. errors, navigation, etc.',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie einen Kategorienamen ein';
              }
              if (widget.availableCategories.contains(value)) {
                return 'Diese Kategorie existiert bereits';
              }
              if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(value)) {
                return 'Nur Kleinbuchstaben, Zahlen und Unterstriche erlaubt';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLocaleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sprache (Locale)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLocale,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Sprache auswählen oder erstellen',
          ),
          items: [
            ...widget.availableLocales.map(
                  (locale) => DropdownMenuItem(
                value: locale,
                child: Text(locale.toUpperCase()),
              ),
            ),
            const DropdownMenuItem(
              value: '__new__',
              child: Row(
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('Neue Sprache hinzufügen'),
                ],
              ),
            ),
          ],
          onChanged: _onLocaleChanged,
          validator: (value) {
            if (!_isNewLocale && (value == null || value.isEmpty)) {
              return 'Bitte wählen Sie eine Sprache';
            }
            return null;
          },
        ),
        if (_isNewLocale) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _localeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Neue Sprache (ISO Code)',
              hintText: 'z.B. fr, es, it',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie einen Sprachcode ein';
              }
              if (widget.availableLocales.contains(value)) {
                return 'Diese Sprache existiert bereits';
              }
              if (!RegExp(r'^[a-z]{2,3}$').hasMatch(value)) {
                return 'Bitte verwenden Sie einen gültigen ISO-Sprachcode (2-3 Buchstaben)';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildKeySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Übersetzungsschlüssel',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _keyController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Key',
            hintText: 'z.B. button.save, error.validation',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie einen Key ein';
            }
            if (!RegExp(r'^[a-z][a-z0-9_.]*$').hasMatch(value)) {
              return 'Nur Kleinbuchstaben, Zahlen, Punkte und Unterstriche erlaubt';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomizableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _isCustomizable,
              onChanged: (value) {
                setState(() {
                  _isCustomizable = value ?? false;
                });
              },
            ),
            Text(
              'Key als customizable markieren',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (_isCustomizable) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _maxLengthController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Maximale Länge',
              hintText: '0 = unbegrenzt (max. 1024)',
              suffixText: 'Zeichen',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie eine maximale Länge ein';
              }
              final intValue = int.tryParse(value);
              if (intValue == null || intValue < 0 || intValue > 1024) {
                return 'Wert muss zwischen 0 und 1024 liegen';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Customizable Keys können in der Benutzeroberfläche bearbeitet werden. 0 bedeutet unbegrenzt (max. 1024 Zeichen).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCreateForAllLocalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _createForAllLocales,
              onChanged: (value) {
                setState(() {
                  _createForAllLocales = value ?? true;
                });
              },
            ),
            Text(
              'Für alle Sprachen erstellen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _createForAllLocales
              ? 'Der Key wird für alle verfügbaren Sprachen erstellt. Nicht ausgefüllte Werte werden mit "EMPTY" gefüllt.'
              : 'Der Key wird nur für die ausgewählte Sprache erstellt.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAllLocalesValueSection() {
    final allLocales = Set<String>.from(widget.availableLocales);
    if (_isNewLocale && _localeController.text.isNotEmpty) {
      allLocales.add(_localeController.text);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Übersetzungen für alle Sprachen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lassen Sie Felder leer, um automatisch "EMPTY" als Platzhalter zu verwenden.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        ...allLocales.map((locale) {
          if (!_localeValueControllers.containsKey(locale)) {
            _localeValueControllers[locale] = TextEditingController();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _localeValueControllers[locale],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '${locale.toUpperCase()} - Übersetzung',
                hintText: 'Leer lassen für "EMPTY"',
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSingleValueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Übersetzungstext',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _valueController,
          maxLines: 3,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Übersetzung für ${_isNewLocale ? _localeController.text.toUpperCase() : (_selectedLocale?.toUpperCase() ?? "")}',
            hintText: 'Geben Sie die Übersetzung ein',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie eine Übersetzung ein';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save, size: 20),
              SizedBox(width: 8),
              Text('Erstellen'),
            ],
          ),
        ),
      ],
    );
  }
}

class CreateTranslationData {
  final String category;
  final String key;
  final Map<String, String> localeValues;
  final bool isCustomizable;
  final int maxLength;
  final bool isNewCategory;
  final Set<String> targetLocales;

  CreateTranslationData({
    required this.category,
    required this.key,
    required this.localeValues,
    required this.isCustomizable,
    required this.maxLength,
    required this.isNewCategory,
    required this.targetLocales,
  });

  @override
  String toString() {
    return 'CreateTranslationData{category: $category, key: $key, localeValues: $localeValues, isCustomizable: $isCustomizable, maxLength: $maxLength, isNewCategory: $isNewCategory, targetLocales: $targetLocales}';
  }
}