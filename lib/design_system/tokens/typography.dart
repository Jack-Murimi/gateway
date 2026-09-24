import 'package:flutter/material.dart';

/// Named typography accessors for product UI surfaces.
extension AppTypographyTokens on TextTheme {
  /// Dense table or metadata text.
  TextStyle? get meta => labelMedium;

  /// Emphasized currency and totals text.
  TextStyle? get money => titleMedium;

  /// Section title text.
  TextStyle? get sectionTitle => titleLarge;
}
