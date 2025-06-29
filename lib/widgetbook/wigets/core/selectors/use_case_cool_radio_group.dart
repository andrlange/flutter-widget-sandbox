import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '/src/widgets/core/selectors/cool_radio_group.dart';

const Map<String,String>_moc = {
  'option.demo.one': 'Option 1',
  'option.demo.two': 'Option 2',
  'option.demo.three': 'Option 3',
  'option.demo.four': 'Option 4',
};

@widgetbook.UseCase(name: 'Cool Radio Group', type: CoolRadioGroup)
Widget buildWidget(BuildContext context) {
  return Center(
    child: SizedBox(
      width: 250,
      height: 200,
      child: CoolRadioGroup(
         options: _moc, initialValue: 'Option 1',
      ),
    ),
  );
}
