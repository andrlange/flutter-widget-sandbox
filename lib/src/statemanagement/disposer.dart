import 'package:flutter/material.dart';

class Disposer extends StatefulWidget {
  const Disposer({super.key, required this.dispose});
  final void Function() dispose;

  @override
  DisposerState createState() {
    return DisposerState();
  }
}

class DisposerState extends State<Disposer> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}