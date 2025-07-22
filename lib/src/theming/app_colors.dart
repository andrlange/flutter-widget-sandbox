

import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color secondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color surface1;
  final Color surface2;
  final Color surface3;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.surface1,
    required this.surface2,
    required this.surface3,
  });

  static const light = AppColors(
    primary: Color(0xFF6750A4),
    secondary: Color(0xFF625B71),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFBA1A1A),
    info: Color(0xFF2196F3),
    surface1: Color(0xFFF7F2FA),
    surface2: Color(0xFFF1ECF4),
    surface3: Color(0xFFEAE7F0),
  );

  static const dark = AppColors(
    primary: Color(0xFFD0BCFF),
    secondary: Color(0xFFCCC2DC),
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFFFB4AB),
    info: Color(0xFF64B5F6),
    surface1: Color(0xFF1D1B20),
    surface2: Color(0xFF232025),
    surface3: Color(0xFF28252A),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? surface1,
    Color? surface2,
    Color? surface3,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
    );
  }
}

// theme/app_text_styles.dart
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle caption;
  final TextStyle overline;
  final TextStyle cardTitle;
  final TextStyle cardSubtitle;
  final TextStyle buttonText;

  const AppTextStyles({
    required this.caption,
    required this.overline,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.buttonText,
  });

  static const base = AppTextStyles(
    caption: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    overline: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
    ),
    cardTitle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
    ),
    cardSubtitle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    buttonText: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
  );

  @override
  AppTextStyles copyWith({
    TextStyle? caption,
    TextStyle? overline,
    TextStyle? cardTitle,
    TextStyle? cardSubtitle,
    TextStyle? buttonText,
  }) {
    return AppTextStyles(
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
      cardTitle: cardTitle ?? this.cardTitle,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      buttonText: buttonText ?? this.buttonText,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other is! AppTextStyles) return this;
    return AppTextStyles(
      caption: TextStyle.lerp(caption, other.caption, t)!,
      overline: TextStyle.lerp(overline, other.overline, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      cardSubtitle: TextStyle.lerp(cardSubtitle, other.cardSubtitle, t)!,
      buttonText: TextStyle.lerp(buttonText, other.buttonText, t)!,
    );
  }
}