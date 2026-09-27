import 'package:flutter/widgets.dart';

import 'spacing.dart';

/// Window size class for responsive design.
enum WindowSizeClass {
  /// Phone (< 600dp).
  compact,

  /// Phablet/small tablet (600-900dp).
  medium,

  /// Tablet (900-1200dp).
  expanded,

  /// Large tablet/desktop (≥ 1200dp).
  large,
}

/// Responsive breakpoint utilities.
extension BreakpointExtensions on BuildContext {
  /// Returns the current window size class.
  WindowSizeClass get windowSizeClass {
    final width = MediaQuery.sizeOf(this).width;
    if (width < AppSpacingTokens.compactMax) return WindowSizeClass.compact;
    if (width < AppSpacingTokens.mediumMax) return WindowSizeClass.medium;
    if (width < AppSpacingTokens.expandedMax) return WindowSizeClass.expanded;
    return WindowSizeClass.large;
  }

  /// Returns true if the screen is compact (phone).
  bool get isCompact => windowSizeClass == WindowSizeClass.compact;

  /// Returns true if the screen is medium (phablet/small tablet).
  bool get isMedium => windowSizeClass == WindowSizeClass.medium;

  /// Returns true if the screen is expanded (tablet).
  bool get isExpanded => windowSizeClass == WindowSizeClass.expanded;

  /// Returns true if the screen is large (large tablet/desktop).
  bool get isLarge => windowSizeClass == WindowSizeClass.large;

  /// Returns true if the screen should use rail navigation (≥ 900dp).
  bool get useNavigationRail =>
      windowSizeClass == WindowSizeClass.expanded ||
      windowSizeClass == WindowSizeClass.large;

  /// Returns true if the screen should use full sidebar navigation (≥ 1200dp).
  bool get useNavigationSidebar => windowSizeClass == WindowSizeClass.large;

  /// Returns true if the sales screen should use two-row header.
  bool get useTwoRowSalesHeader =>
      windowSizeClass == WindowSizeClass.compact ||
      windowSizeClass == WindowSizeClass.medium ||
      windowSizeClass == WindowSizeClass.expanded;
}

/// Responsive value selector.
T responsive<T>(
  BuildContext context, {
  required T compact,
  T? medium,
  T? expanded,
  T? large,
}) {
  switch (context.windowSizeClass) {
    case WindowSizeClass.compact:
      return compact;
    case WindowSizeClass.medium:
      return medium ?? compact;
    case WindowSizeClass.expanded:
      return expanded ?? medium ?? compact;
    case WindowSizeClass.large:
      return large ?? expanded ?? medium ?? compact;
  }
}
