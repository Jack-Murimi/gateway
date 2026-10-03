import 'package:flutter/material.dart';

/// Color seed tokens for the Gateway design system.
abstract final class AppColors {
  /// Primary LPG retail seed color used by Material 3 color schemes.
  static const Color seed = Color(0xFFFF4D00); // Orange - company color
}

/// Branch color palette for multi-branch visual distinction.
abstract final class BranchColorPalette {
  static const Color green = Color(0xFF2E7D32);
  static const Color blue = Color(0xFF1565C0);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color orange = Color(0xFFE65100);

  /// Get color by index (0-3).
  static Color getByIndex(int index) {
    final colors = [green, blue, purple, orange];
    return colors[index % colors.length];
  }

  /// All available colors.
  static const List<Color> all = [green, blue, purple, orange];
}
