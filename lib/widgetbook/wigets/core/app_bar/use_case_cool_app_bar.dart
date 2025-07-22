import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../../../../src/widgets/core/app_bar/cool_app_bar.dart';

@widgetbook.UseCase(name: 'Cool App Bar', type: CoolAppBar)
Widget buildWidget(BuildContext context) {
  return Center(child: SizedBox(height: 50.0,child: CoolAppBar(

    menuOnRight:  context.knobs.boolean(
      label: 'Menü links/rechts',
      initialValue: false,
      description:
      'Zeigt das Context-Menü link oder rechts an.',
    ),
  )));
}
