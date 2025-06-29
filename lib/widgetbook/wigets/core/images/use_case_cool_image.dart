import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_example/src/widgets/core/images/cool_image.dart';

@widgetbook.UseCase(name: 'Cool Image', type: CoolImage)
Widget buildWidget(BuildContext context) {
  return Center(
    child: CoolImage(
      imageFile: 'appstore.jpg',
      borderColor: context.knobs.color(label: 'Border Color',
          initialColorSpace: ColorSpace.hex, initialValue: Colors.grey)

    ),
  );
}
