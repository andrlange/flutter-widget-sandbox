import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import '../../../src/translation/translation_extension.dart';
import '../../../src/widgets/core/buttons/cool_action_button.dart';
import '../../../src/widgets/core/images/cool_image.dart';
import '../../../src/widgets/core/selectors/cool_radio_group.dart';
import '../../../src/responsive/responsive_extension.dart';

const Map<String,String>_moc = {
  'option.demo.one': 'Option 1',
  'option.demo.two': 'Option 2',
  'option.demo.three': 'Option 3',
  'option.demo.four': 'Option 4',
};

class DemoView extends StatelessWidget {
  const DemoView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      CoolActionButton(
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
      CoolImage(
          imageFile: 'appstore.jpg',
          borderColor: context.knobs.color(label: 'Border Color',
              initialColorSpace: ColorSpace.hex, initialValue: Colors.grey)

      ),
      const SizedBox(
        width: 250,
        height: 200,
        child: CoolRadioGroup(
          options: _moc, initialValue: 'Option 1',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.isDarkMode ?  Colors.black : Colors.blue,
        title: Text('${'app.name'.trSync(parameters: {'param1':'Demo'})} '
            '${'app'
            '.version'
            .trSync()}',
          style:
        TextStyle(
          color: context.isDarkMode ?  Colors.white30 : Colors.white
        ),),
      ),
      backgroundColor: context.isDarkMode ?  Colors.white10 : Colors.white70,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: (!context.isMobile && !context.isTiny) ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ) :Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Perform some action when the FAB is clicked
          debugPrint('Floating Action Button clicked');
        },
        tooltip: 'Increment Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}