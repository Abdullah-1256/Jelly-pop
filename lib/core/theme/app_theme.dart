import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Bright candy-themed Material theme.
abstract class AppTheme {
  static ThemeData get light {
    final String fontFamily = GoogleFonts.baloo2().fontFamily!;
    final TextTheme textTheme = _extraBoldTheme(GoogleFonts.baloo2TextTheme());
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundTop,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      fontFamily: fontFamily,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: AppColors.textLight,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: AppColors.text,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.text),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.text),
      ),
    );
  }

  static TextTheme _extraBoldTheme(TextTheme theme) {
    const FontWeight extraBold = FontWeight.w800;
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(fontWeight: extraBold),
      displayMedium: theme.displayMedium?.copyWith(fontWeight: extraBold),
      displaySmall: theme.displaySmall?.copyWith(fontWeight: extraBold),
      headlineLarge: theme.headlineLarge?.copyWith(fontWeight: extraBold),
      headlineMedium: theme.headlineMedium?.copyWith(fontWeight: extraBold),
      headlineSmall: theme.headlineSmall?.copyWith(fontWeight: extraBold),
      titleLarge: theme.titleLarge?.copyWith(fontWeight: extraBold),
      titleMedium: theme.titleMedium?.copyWith(fontWeight: extraBold),
      titleSmall: theme.titleSmall?.copyWith(fontWeight: extraBold),
      bodyLarge: theme.bodyLarge?.copyWith(fontWeight: extraBold),
      bodyMedium: theme.bodyMedium?.copyWith(fontWeight: extraBold),
      bodySmall: theme.bodySmall?.copyWith(fontWeight: extraBold),
      labelLarge: theme.labelLarge?.copyWith(fontWeight: extraBold),
      labelMedium: theme.labelMedium?.copyWith(fontWeight: extraBold),
      labelSmall: theme.labelSmall?.copyWith(fontWeight: extraBold),
    );
  }
}
