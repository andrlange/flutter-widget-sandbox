import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../responsive/responsive_extension.dart';

class CoolImage extends StatelessWidget {

  const CoolImage({
    super.key,
    this.borderColor = Colors.grey,
    required this.imageFile,
  });
  final Color borderColor;
  final String imageFile;

  @override
  Widget build(BuildContext context) {
    final isSmall = context.isTiny || context.isMobile;
    final width = isSmall ? 100.0 : 140.0;
    final image = Image.asset('${(kIsWeb ||
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
        padding: const EdgeInsets.all(10.0),
        child: image,
      ),
    );
  }
}
