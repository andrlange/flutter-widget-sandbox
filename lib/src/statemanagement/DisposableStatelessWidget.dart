import 'package:flutter/material.dart';
export 'package:flutter/material.dart';

/// A widget that behaves like StatelessWidget but provides dispose functionality
abstract class DisposableStatelessWidget extends StatefulWidget {
  const DisposableStatelessWidget({super.key});

  @override
  State<DisposableStatelessWidget> createState() => _DisposableStatelessWidgetState();

  /// Build method - similar to StatelessWidget.build()
  Widget build(BuildContext context);

  /// Called when the widget is removed from the widget tree
  void onDispose() {}
}

class _DisposableStatelessWidgetState extends State<DisposableStatelessWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}