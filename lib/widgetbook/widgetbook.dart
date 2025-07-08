import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import '../src/config/app_config.dart';
import '../src/translation/translated_text.dart';
import '../widgetbook/devices/cool_devices.dart';
import 'widgetbook.directories.g.dart';

class TranslationAddon extends WidgetbookAddon<String> {
  TranslationAddon()
    : super(name: 'Language');

  @override
  Widget buildUseCase(BuildContext context, Widget child, String setting) {
    return child;
  }


  Future<void> _switchLanguage(String locale) async {
   await TranslationHelper.switchLanguage(locale);
  }

  @override
  List<Field> get fields {
    return [
      ListField(name: 'Languages', values: AppConfig.supportedLocales,
          initialValue: AppConfig.fallbackLocale,),
    ];
  }

  @override
  String valueFromQueryGroup(Map<String, String> group) {
    _switchLanguage(group['Languages'] ??  AppConfig.fallbackLocale,);
    return group['Languages'] ??  AppConfig.fallbackLocale;
  }
}

@widgetbook.App()
class WidgetBookSandbox extends StatelessWidget {
  const WidgetBookSandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: TranslationHelper.preloadCategories(['common']),
      builder: (context, asyncSnapshot) {
        return Widgetbook.material(
          directories: directories,
          addons: [
            MaterialThemeAddon(
              themes: [
                WidgetbookTheme(name: 'dark', data: ThemeData.dark()),
                WidgetbookTheme(name: 'light', data: ThemeData.light()),
              ],
            ),
            DeviceFrameAddon(
              devices: [
                CoolDevices.layout.smallPhone,
                CoolDevices.layout.mediumPhone,
                CoolDevices.layout.mediumTablet,
                CoolDevices.layout.mediumDesktop,
              ],
            ),
            TranslationAddon(),
          ],
        );
      },
    );
  }
}
