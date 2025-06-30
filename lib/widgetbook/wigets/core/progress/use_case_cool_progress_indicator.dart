import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '/src/widgets/core/progress/cool_progress_indicator.dart';

@widgetbook.UseCase(name: 'Cool Progress Indicator', type: CoolProgressIndicator)
Widget buildWidget(BuildContext context) {
  return Center(
    child: CoolProgressIndicator(
      size: context.knobs.double.slider(
        label: 'Size',
        min: 100,
        max: 300,
        divisions: 10,
        initialValue: 200,
        description: 'The size of the progress indicator in pixels.',
      ),
      color: context.knobs.color(label: 'Progress Color', description: 'The color of the progress indicator.', initialValue: Colors.blue),
    ),
  );
}
