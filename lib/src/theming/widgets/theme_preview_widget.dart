import 'package:flutter/material.dart';

import '../app_theme.dart';

class ThemePreviewWidget extends StatelessWidget {
  const ThemePreviewWidget({
    super.key,
    this.seedingColor,
    this.fontFamily = 'monospace',
  });

  final Color? seedingColor;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.brightness == Brightness.dark
        ? AppTheme.darkTheme(seedColor: seedingColor).colorScheme
        : AppTheme.lightTheme(seedColor: seedingColor).colorScheme; //theme
    // .colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Preview'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('ColorScheme Colors\nseed: #$seedingColor : '
                'Font: $fontFamily'),
            const SizedBox(height: 16),
            _buildColorSchemeTable(colorScheme),
            const SizedBox(height: 32),
            _buildSectionTitle('Text Styles'),
            const SizedBox(height: 16),
            _buildTextStylesTable(textTheme),
            const SizedBox(height: 32),
            _buildSectionTitle('Additional Theme Properties'),
            const SizedBox(height: 16),
            _buildAdditionalProperties(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildColorSchemeTable(ColorScheme colorScheme) {
    final colors = [
      ColorInfo('primary', colorScheme.primary),
      ColorInfo('onPrimary', colorScheme.onPrimary),
      ColorInfo('primaryContainer', colorScheme.primaryContainer),
      ColorInfo('onPrimaryContainer', colorScheme.onPrimaryContainer),
      ColorInfo('secondary', colorScheme.secondary),
      ColorInfo('onSecondary', colorScheme.onSecondary),
      ColorInfo('secondaryContainer', colorScheme.secondaryContainer),
      ColorInfo('onSecondaryContainer', colorScheme.onSecondaryContainer),
      ColorInfo('tertiary', colorScheme.tertiary),
      ColorInfo('onTertiary', colorScheme.onTertiary),
      ColorInfo('tertiaryContainer', colorScheme.tertiaryContainer),
      ColorInfo('onTertiaryContainer', colorScheme.onTertiaryContainer),
      ColorInfo('error', colorScheme.error),
      ColorInfo('onError', colorScheme.onError),
      ColorInfo('errorContainer', colorScheme.errorContainer),
      ColorInfo('onErrorContainer', colorScheme.onErrorContainer),
      ColorInfo('surface', colorScheme.surface),
      ColorInfo('onSurface', colorScheme.onSurface),
      ColorInfo('surfaceVariant', colorScheme.surfaceVariant),
      ColorInfo('onSurfaceVariant', colorScheme.onSurfaceVariant),
      ColorInfo('outline', colorScheme.outline),
      ColorInfo('outlineVariant', colorScheme.outlineVariant),
      ColorInfo('shadow', colorScheme.shadow),
      ColorInfo('scrim', colorScheme.scrim),
      ColorInfo('inverseSurface', colorScheme.inverseSurface),
      ColorInfo('onInverseSurface', colorScheme.onInverseSurface),
      ColorInfo('inversePrimary', colorScheme.inversePrimary),
      ColorInfo('surfaceTint', colorScheme.surfaceTint),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: colors.map(_buildColorRow).toList()),
      ),
    );
  }

  Widget _buildColorRow(ColorInfo colorInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorInfo.color,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              colorInfo.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _colorToHex(colorInfo.color),
              style: TextStyle(fontFamily: fontFamily),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'RGB(${colorInfo.color.red}, ${colorInfo.color.green}, ${colorInfo.color.blue})',
              style: TextStyle(fontSize: 12, fontFamily: fontFamily),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextStylesTable(TextTheme textTheme) {
    final textStyles = [
      TextStyleInfo('displayLarge', textTheme.displayLarge),
      TextStyleInfo('displayMedium', textTheme.displayMedium),
      TextStyleInfo('displaySmall', textTheme.displaySmall),
      TextStyleInfo('headlineLarge', textTheme.headlineLarge),
      TextStyleInfo('headlineMedium', textTheme.headlineMedium),
      TextStyleInfo('headlineSmall', textTheme.headlineSmall),
      TextStyleInfo('titleLarge', textTheme.titleLarge),
      TextStyleInfo('titleMedium', textTheme.titleMedium),
      TextStyleInfo('titleSmall', textTheme.titleSmall),
      TextStyleInfo('bodyLarge', textTheme.bodyLarge),
      TextStyleInfo('bodyMedium', textTheme.bodyMedium),
      TextStyleInfo('bodySmall', textTheme.bodySmall),
      TextStyleInfo('labelLarge', textTheme.labelLarge),
      TextStyleInfo('labelMedium', textTheme.labelMedium),
      TextStyleInfo('labelSmall', textTheme.labelSmall),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: textStyles
              .map((styleInfo) => _buildTextStyleRow(styleInfo))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTextStyleRow(TextStyleInfo styleInfo) {
    final style = styleInfo.textStyle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  styleInfo.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(flex: 3, child: Text('Sample Text', style: style)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _getTextStyleDescription(style),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: fontFamily,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildAdditionalProperties(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPropertyRow(
              'Font Family',
              fontFamily ?? 'Default',
            ),
            _buildPropertyRow('Brightness', theme.brightness.name),
            _buildPropertyRow('Material 3', theme.useMaterial3.toString()),
            _buildPropertyRow('Platform', theme.platform.name),
            _buildPropertyRow('Visual Density', theme.visualDensity.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontFamily: fontFamily)),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).toUpperCase().padLeft(8, '0')}';
  }

  String _getTextStyleDescription(TextStyle? style) {
    if (style == null) return 'null';

    final fontSize = style.fontSize?.toStringAsFixed(1) ?? 'inherit';
    final fontWeight = _fontWeightToString(style.fontWeight);
    final fontFamily = style.fontFamily ?? 'inherit';
    final letterSpacing = style.letterSpacing?.toStringAsFixed(2) ?? 'normal';

    return 'Size: ${fontSize}px, Weight: $fontWeight, Family: $fontFamily, Spacing: $letterSpacing';
  }

  String _fontWeightToString(FontWeight? weight) {
    if (weight == null) return 'inherit';

    switch (weight) {
      case FontWeight.w100:
        return '100 (Thin)';
      case FontWeight.w200:
        return '200 (ExtraLight)';
      case FontWeight.w300:
        return '300 (Light)';
      case FontWeight.w400:
        return '400 (Regular)';
      case FontWeight.w500:
        return '500 (Medium)';
      case FontWeight.w600:
        return '600 (SemiBold)';
      case FontWeight.w700:
        return '700 (Bold)';
      case FontWeight.w800:
        return '800 (ExtraBold)';
      case FontWeight.w900:
        return '900 (Black)';
      default:
        return weight.toString();
    }
  }
}

class ColorInfo {

  ColorInfo(this.name, this.color);
  final String name;
  final Color color;
}

class TextStyleInfo {

  TextStyleInfo(this.name, this.textStyle);
  final String name;
  final TextStyle? textStyle;
}
