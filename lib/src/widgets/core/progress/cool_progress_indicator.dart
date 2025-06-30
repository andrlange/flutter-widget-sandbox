import 'package:flutter/material.dart';

class CoolProgressIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const CoolProgressIndicator({
    super.key,
    this.size = 200.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(color: color),
    );
  }
}
