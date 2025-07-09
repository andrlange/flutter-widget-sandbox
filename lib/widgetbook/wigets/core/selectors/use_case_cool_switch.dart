import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '/src/widgets/core/selectors/cool_switch.dart';

@widgetbook.UseCase(name: 'Cool Switch', type: CoolSwitch)
Widget buildWidget(BuildContext context) {
  return Center(
    child: CoolSwitch(
      initialValue: context.knobs.boolean(
        label: 'Cool Switch',
        description: 'Set initial value',
        initialValue: false,
      ),
      onValueChange: (value) => print('Cool Switch value changed: $value'),
    ),
  );
}
