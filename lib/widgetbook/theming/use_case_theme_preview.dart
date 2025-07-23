import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../src/theming/widgets/theme_preview_widget.dart';

@widgetbook.UseCase(name: 'Theme Preview', type: ThemePreviewWidget)
Widget buildWidget(BuildContext context) {
  final colorSeedName = context.knobs.list(
    label: 'Color Seed',
    options: ColorSeedOptions.options,
    initialOption: 'Purple (Default)',
  );

  final c = context.knobs.color(
    label: 'Custom Seed Color',
    initialValue: Colors.blue,
  );

  final useCustomSeedColor = context.knobs.boolean(
    label:
        'Use Custom '
        'Color',
  );

  final cc = useCustomSeedColor ? c : ColorSeedOptions.getColor(colorSeedName);

  final fontFamily = context.knobs.list(
    label: 'Font Family',
    options: ['Roboto', 'System Default'],
    initialOption: 'Roboto',
  );
  return ThemePreviewWidget(seedingColor: cc, fontFamily: fontFamily);
}

// Predefined color options for the knob
class ColorSeedOptions {
  static const Map<String, Color> seeds = {
    'Purple (Default)': Color(0xFF6750A4),
    'Blue': Color(0xFF1976D2),
    'Green': Color(0xFF2E7D32),
    'Orange': Color(0xFFEF6C00),
    'Red': Color(0xFFD32F2F),
    'Teal': Color(0xFF00796B),
    'Pink': Color(0xFFE91E63),
    'Indigo': Color(0xFF3F51B5),
    'Deep Orange': Color(0xFFFF5722),
    'Cyan': Color(0xFF00BCD4),
    'Lime': Color(0xFF689F38),
    'Amber': Color(0xFFFF8F00),
    'Brown': Color(0xFF5D4037),
    'Blue Grey': Color(0xFF455A64),
  };

  static List<String> get options => seeds.keys.toList();

  static Color getColor(String name) => seeds[name] ?? seeds.values.first;
}
