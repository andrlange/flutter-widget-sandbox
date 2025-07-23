import 'package:flutter/material.dart';

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
