
import 'package:flutter/material.dart';
import '/src/translation/translation_extension.dart';
import '../widgetbook/widgetbook.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await Locator.setup();

  runApp(const WidgetBookSandbox());
}




