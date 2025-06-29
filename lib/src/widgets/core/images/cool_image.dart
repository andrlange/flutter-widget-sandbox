import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_example/src/responsive/responsive_extension.dart';

class CoolImage extends StatelessWidget {
  final Color borderColor;
  final String imageFile;

  const CoolImage({
    super.key,
    this.borderColor = Colors.grey,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmall = context.isTiny || context.isMobile;
    final double width = isSmall ? 100 : 140;
    final Image image = Image.asset('${(kIsWeb ||
        kIsWasm) ? '' : 'assets/'}images/$imageFile', width: width);

    final double height = isSmall ? 100 : 140;

    return Container(
      width: width + 20.0,
      height: height + 20.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: borderColor, width: 2.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: image,
      ),
    );
  }
}
