import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'demo_view.dart';

@widgetbook.UseCase(name: 'Demo View', type: DemoView)
Widget buildWidget(BuildContext context) {
  return DemoView();
}
