import 'package:flutter/material.dart';
import '/src/internationalization/translation_extension.dart';
import '../widgetbook/widgetbook.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await ServiceLocator.setup();

  runApp(WidgetBookSandbox());
}