import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '/src/widgets/core/buttons/cool_action_button.dart';

@widgetbook.UseCase(name: 'Cool Action Button', type: CoolActionButton)
Widget buildWidget(BuildContext context) {
  return Center(
    child: CoolActionButton(
      () => debugPrint('CoolActionButton pressed...'),
      context.knobs.list(
        label: 'Types',
        options: [
          ButtonActionType.print,
          ButtonActionType.add,
          ButtonActionType.save,
          ButtonActionType.delete,
        ],
        initialOption: ButtonActionType.print,
        description: 'Action Type',
      ),
      showIcon: context.knobs.boolean(
        label: 'Show Icon',
        initialValue: true,
        description:
            'Show Icon, default: true, if false Show Text must be '
            'true!',
      ),
      showText: context.knobs.boolean(
        label: 'Show Text',
        initialValue: true,
        description:
            'Show Text, default: true, if false Show Icon must be '
            'true!',
      ),
    ),
  );
}
