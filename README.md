# Flutter Widget Sandbox using Widgetbook

A comprehensive Flutter sandbox system designed for cross-platform applications with Widgetbook multi language 
support, responsive design support, and state management capabilities.

## 🚀 Overview

This project demonstrates a Widget Sandbox service that seamlessly integrates with:
- **Widgetbook** for component development and testing
- **Bloc State Management** for reactive translation updates
- **Responsive Design** with breakpoint system
- **GetIt Dependency Injection** for context-free translations
- **API Fallback** for missing translations (in development)
- **Category-based Loading** for performance optimization

## ✨ Key Features

### 🌍 Advanced Translation System
- **Context-free translations** using GetIt dependency injection
- **Named parameters** and **positional arguments** support
- **Category-based organization** (common, buttons, forms, etc.)
- **API fallback** for missing local translations
- **Caching and persistence** for offline support
- **Real-time language switching** in Widgetbook

### 📱 Widgetbook Integration
- **Custom Translation Addon** for language switching
- **Live preview** of translations across components
- **Pre-loading strategies** for smooth development experience
- **Sync translation methods** for immediate rendering

### 🎯 Responsive Design Ready
- **Breakpoint system** integration for different screen sizes
- **Adaptive layouts** that work with translation changes

### 🏗️ State Management Integration
- **Bloc/Cubit compatibility** for reactive UI updates
- **Error handling** and loading states

## 🔧 Core Components

### Translation Service Architecture

```dart
// Context-free translation anywhere in your app
final message = await 'login_success'.tr(args: [username, timestamp]);

// Sync translation for pre-loaded content
final label = 'save'.trSync(category: 'buttons');

// Widget-based translations with parameters
TranslatedText('welcome_message', parameters: {'name': user.name})
```

### Widgetbook Development Experience

The translation service is designed with Widgetbook-first approach:

```dart
// Language switching in Widgetbook
UnifiedTranslationAddon(
  locales: [Locale('en'), Locale('de'), Locale('es'), Locale('fr')],
)

// Live translation preview
TranslatedWidgetShowcase() // Demonstrates all translation features
```

### Bloc Integration Pattern

```dart
// Translation-aware Bloc
class SettingsCubit extends Cubit<SettingsState> {
  final ITranslationService _translationService;
  
  Future<void> changeLanguage(String locale) async {
    emit(state.copyWith(isChangingLanguage: true));
    await _translationService.setLocale(locale);
    emit(state.copyWith(
      currentLocale: locale,
      isChangingLanguage: false,
    ));
  }
}

// Reactive UI updates
BlocBuilder<SettingsCubit, SettingsState>(
  builder: (context, state) {
    return TranslatedText(
      'current_language',
      args: [state.currentLocale.toUpperCase()],
    );
  },
)
```



## 🎨 Demo Components

### Widget Showcase
The project includes comprehensive demo components:

- **TranslatedWidgetShowcase**: Demonstrates translation features
- **ArgumentsDemo**: Showcases positional and named arguments
- **LanguageDemoWidget**: Real-time language switching
- **BreakpointDemo**: Responsive design with translations

### Demo Screen Features
- **Live language switching** with immediate UI updates
- **Responsive layout** adaptation based on screen size

## 🛠️ Translation Patterns

### Argument Types Support

```dart
// Named parameters
'welcome_message'.tr(parameters: {'name': 'John'})
// Result: "Welcome, John!"

// Positional arguments  
'login_success'.tr(args: ['Alice', 'now'])
// Result: "Log in for Alice was successful at now"

// Mixed arguments
'mixed_example'.tr(
  parameters: {'name': 'John'}, 
  args: [5, 'Support']
)
// Result: "Hello John, you have 5 new messages from Support"
```

### Category Organization

```json
{
  "common": ["hello_world", "loading", "success"],
  "buttons": ["save", "cancel", "submit"],
  "forms": ["email", "password", "required_field"],
  "errors": ["network_error", "validation_failed"]
}
```

### API Integration (under development)

```dart
// Automatic API fallback for missing translations
class ProductionTranslationService extends TranslationService {
  @override
  Future<String?> _fetchFromApi(String key, String category) async {
    // Fetches missing translations from your API
    // Caches results locally
    // Reports missing translations for analysis
  }
}
```

## 📊 Bloc State Management Integration

### Translation State Pattern

```dart
// Translation-aware app state
abstract class AppState extends Equatable {
  final String currentLocale;
  final bool isLoadingTranslations;
  final Map<String, bool> loadedCategories;
  
  const AppState({
    required this.currentLocale,
    required this.isLoadingTranslations,
    required this.loadedCategories,
  });
}

// Events for translation management
abstract class TranslationEvent extends Equatable {}

class ChangeLanguageEvent extends TranslationEvent {
  final String locale;
  ChangeLanguageEvent(this.locale);
}

class LoadCategoryEvent extends TranslationEvent {
  final String category;
  LoadCategoryEvent(this.category);
}
```


# Flutter Responsive Extensions

A minimalistic and clean approach to responsive design in Flutter using extension methods. No external dependencies, just pure Flutter goodness.

## ✨ Features

- 🎯 **Simple API** - Intuitive method names like `context.isMobile`, `.showOnTablet()`
- 📱 **Mobile-first** - Progressive enhancement from mobile to desktop
- 🎨 **Widget Extensions** - Add responsive behavior to any widget
- 📏 **Flexible Breakpoints** - Customizable breakpoints for all screen sizes
- ⚡ **Zero Dependencies** - Uses only Flutter's built-in classes
- 🔧 **Type Safe** - Full Dart type safety with generic methods

## 🚀 Quick Start

### 1. Add the Extensions

Copy `responsive_extensions.dart` to your project:

```
lib/
  src/
    responsive/
    responsive_extensions.dart
```

### 2. Import and Use

```dart
import 'responsive/responsive_extensions.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Conditional widgets
        Text('Mobile Only').showOnMobile(context),
        Text('Desktop Only').showOnDesktopOrLarger(context),
        
        // Responsive sizing
        Text(
          'Hello World',
          style: TextStyle(
            fontSize: ResponsiveSize.fontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
              defaultSize: 16,
            ),
          ),
        ),
        
        // Responsive padding
        MyContent().responsivePadding(
          context,
          mobile: EdgeInsets.all(16),
          desktop: EdgeInsets.all(32),
        ),
      ],
    );
  }
}
```

## 📱 Breakpoints

| Device        | Width Range   | Enum                      |
|---------------|---------------|---------------------------|
| Tiny          | < 412px       | `DeviceType.tiny`         |
| Mobile        | < 576px       | `DeviceType.mobile`       |
| Tablet        | 576px - 768px | `DeviceType.tablet`       |
| Desktop       | 768px - 992px | `DeviceType.desktop`      |
| Large Desktop | > 992px       | `DeviceType.largeDesktop` |

## 🎯 Core API

### Context Extensions

```dart
// Device detection
context.isTiny            // bool
context.isMobile          // bool
context.isTablet          // bool 
context.isDesktop         // bool
context.isTabletOrLarger  // bool
context.deviceType        // DeviceType enum

// Screen dimensions
context.width             // double
context.height            // double

// Responsive values
context.responsive<T>(
  tiny: tinyValue,
  mobile: mobileValue,
  tablet: tabletValue,
  desktop: desktopValue,
  defaultValue: fallback,
)
```

### Widget Extensions

```dart
// Conditional display
widget.showOnTiny(context)
widget.showOnMobile(context)
widget.hideOnMobile(context)
widget.showOnTabletOrLarger(context)
widget.showOn(context, [DeviceType.desktop])

// Responsive spacing
widget.responsivePadding(context, mobile: ..., desktop: ...)
widget.responsiveMargin(context, mobile: ..., desktop: ...)
widget.responsiveConstraints(context, mobile: ..., desktop: ...)
```

### Responsive Sizing

```dart
// Font sizes
ResponsiveSize.fontSize(
  context,
  tiny: 12,
  mobile: 14,
  tablet: 16,
  desktop: 18,
  defaultSize: 14,
)

// Percentage-based sizing
ResponsiveSize.widthPercent(context, 80)   // 80% of screen width
ResponsiveSize.heightPercent(context, 50)  // 50% of screen height
```

## 📋 Common Patterns

### Navigation Layout

```dart
Scaffold(
  drawer: context.isMobile ? AppDrawer() : null,
  body: Row(
    children: [
      if (context.isDesktopOrLarger) SideNavigation(),
      Expanded(child: MainContent()),
    ],
  ),
)
```

### Responsive Grid

```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: context.responsive<int>(
      mobile: 1,
      tablet: 2,
      desktop: 3,
      defaultValue: 1,
    ),
  ),
  // ...
)
```

### Responsive Builder

```dart
ResponsiveBuilder(
  tiny: TinyLayout(),
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

## 🎨 Customization

### Custom Breakpoints

```dart
class MyBreakpoints {
  static const double tiny = 412;
  static const double phone = 480;
  static const double tablet = 768;
  static const double laptop = 1024;
  static const double desktop = 1440;
}
```

### Theme Integration

```dart
class AppTextStyles {
  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: ResponsiveSize.fontSize(
      context,
      tiny: 20,
      mobile: 24,
      tablet: 28,
      desktop: 32,
      defaultSize: 24,
    ),
    fontWeight: FontWeight.bold,
  );
}
```

## 🔧 Best Practices

### ✅ Do's

- Start with mobile design, enhance for larger screens
- Use semantic method names (`showOnMobile` vs device width checks)
- Cache responsive values when doing multiple calculations
- Prefer responsive extensions over manual breakpoint checks

### ❌ Don'ts

- Don't overuse device type checks everywhere
- Avoid hardcoded sizes - use responsive helpers
- Don't ignore tablet devices in your responsive design
- Don't use fixed pixel values for spacing


## 🤝 Contributing

This is a minimal, self-contained solution. Feel free to:

- Customize breakpoints for your project
- Add your own extension methods
- Adapt the patterns to your design system

## 🎨 Widgetbook Features

- **Real-time language switching** during development
- **Component isolation** with translation context
- **Custom translation addon** for easy language testing
- **Pre-loading strategies** for smooth development
- **Responsive testing** with different screen sizes
- **Error state handling** for missing translations

## 🔄 State Management Benefits

- **Reactive language changes** across entire app
- **Loading states** for translation category loading
- **Error handling** for network failures
- **Event-driven updates** for optimal performance

## 📱 Responsive Design Features

- **Breakpoint-aware layouts** that adapt to screen size
- **Text scaling** based on available space
- **Overflow handling** for long translations
- **Adaptive component sizing** with translation support
- **RTL language preparation** for international markets

## 📄 License

Use freely in your Flutter projects. No attribution required.

---

**Made with ❤️ for the Flutter community**
