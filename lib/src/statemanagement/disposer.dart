import 'package:flutter/material.dart';

class Disposer extends StatefulWidget {
  final void Function() dispose;
  const Disposer({super.key, required this.dispose});

  @override
  DisposerState createState() {
    return DisposerState();
  }
}

class DisposerState extends State<Disposer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}