import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  // light mode themes
  static final ThemeData themeDataLight = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPurple,
      onPrimary: AppColors.black,
      secondary: AppColors.white,
      onSecondary: AppColors.defaultBlack,
      error: AppColors.errorDark,
      onError: AppColors.white,
      surface: AppColors.cardLight,
      onSurface: AppColors.appLight,
      scrim: AppColors.iconBgLight,
      shadow: AppColors.cardLight,
      outline: AppColors.greenLight,
      tertiary: AppColors.grayBackgroundLight,
    ),
  );

  // dark mode themes
  static final ThemeData themeDataDark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.lighterPurple,
      onPrimary: AppColors.white,
      secondary: AppColors.black,
      onSecondary: AppColors.defaultWhite,
      error: AppColors.errorDark,
      onError: AppColors.white,
      surface: AppColors.cardDark,
      onSurface: AppColors.pureBlack,
      scrim: AppColors.cardDark,
      shadow: AppColors.cardOption,
      outline: AppColors.greenDark,
      tertiary: AppColors.grayBackgroundDark,
    ),
  );
}
