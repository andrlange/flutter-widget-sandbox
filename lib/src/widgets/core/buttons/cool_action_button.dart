import 'package:flutter/material.dart';
import '/src/responsive/responsive_extension.dart';
import '/src/internationalization/translation_extension.dart';


/// A custom widget that represents a button with an icon and/or text,
/// providing various customization options.
///
/// The [CoolActionButton] widget takes in a callback function [_onPressed],
/// a [ButtonActionType] to determine the button's appearance, and optional
/// parameters to control the visibility of the icon and text.
///
/// The button's appearance is determined by the provided [ButtonActionType],
/// which can be one of the following:
/// - [ButtonActionType.print]: Displays a print icon and "Print" text.
/// - [ButtonActionType.add]: Displays an add icon and "Add" text.
/// - [ButtonActionType.delete]: Displays an add icon and "Delete" text.
/// - [ButtonActionType.save]: Displays an add icon and "Save" text.
///
/// If both [showText] and [showIcon] are set to `false`, the button will display
/// an error icon and "ERROR!" text.
///
/// The button's size can be controlled using the [_buildButton] method,
/// which wraps the provided child widget in a [SizedBox] with a width
/// of 120.0 and a height of 40.0 in Desktop or Tablet Size and
/// of 60.0 and a height of 40.0 in Mobile Size without Text
class CoolActionButton extends StatelessWidget {
  final VoidCallback _onPressed;
  final ButtonActionType _buttonType;
  final bool showText;
  final bool showIcon;

  const CoolActionButton(
    this._onPressed,
    this._buttonType, {
    super.key,
    this.showText = true,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText = "";
    Icon icon = Icon(Icons.print);

    switch (_buttonType) {
      case ButtonActionType.print:
        buttonText = "print";
        icon = Icon(Icons.print);
        break;
      case ButtonActionType.add:
        buttonText = "add";
        icon = Icon(Icons.add);
        break;
      case ButtonActionType.delete:
        buttonText = "delete";
        icon = Icon(Icons.delete);
        break;
      case ButtonActionType.save:
        buttonText = "save";
        icon = Icon(Icons.save);
        break;
    }
    if (!showText && !showIcon) {
      buttonText = "ERROR!";
      icon = Icon(Icons.help);
    }

    return _buildButton(
      FloatingActionButton.extended(
        onPressed: _onPressed,
        label: showText || (!showText && !showIcon)
            ? (buttonText == 'ERROR!')
                  ? Text(buttonText)
                  : !context.isTiny
                  ? Text(
                      'action.button'
                      '.$buttonText'.trSync(),
                    )
                  : SizedBox.shrink()
            : SizedBox.shrink(),
        icon: context.isTiny
            ? Padding(padding: EdgeInsets.only(left: 14.0), child: icon)
            : showIcon || (!showText && !showIcon)
            ? icon
            : null,
      ),
      context,
    );
  }

  Widget _buildButton(Widget child, BuildContext context) {
    double width = 120.0;
    if (context.isTiny) {
      width = 60.0;
    }
    return SizedBox(width: width, height: 40.0, child: child);
  }
}

enum ButtonActionType { print, add, delete, save }
