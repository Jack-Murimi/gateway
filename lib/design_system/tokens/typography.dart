import 'dart:ui';
import 'package:flutter/material.dart';

/// Named typography accessors for product UI surfaces.
extension AppTypographyTokens on TextTheme {
  /// Dense table or metadata text.
  TextStyle? get meta => labelMedium;

  /// Emphasized currency and totals text with tabular figures for alignment.
  TextStyle? get money => titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Section title text.
  TextStyle? get sectionTitle => titleLarge;
}
