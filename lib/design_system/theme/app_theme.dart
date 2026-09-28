import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import 'theme_extensions.dart';

/// Gateway Material 3 light and dark themes.
abstract final class AppTheme {
  /// Light app theme.
  static ThemeData get light => _theme(Brightness.light);

  /// Dark app theme.
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [AppSpacing.standard, AppRadii.standard],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}

