import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_example/translation/translation_management_view.dart';

@widgetbook.UseCase(name: 'Translation View', type: TranslationManagementView)
Widget buildWidget(BuildContext context) {
  return TranslationManagementView();
}
