import 'package:flutter/widgets.dart';

/// Spacing, sizing, and breakpoint tokens for the Gateway UI.
abstract final class AppSpacingTokens {
  /// Extra-small gap.
  static const double xs = 4;

  /// Small gap.
  static const double sm = 8;

  /// Medium gap.
  static const double md = 12;

  /// Large gap.
  static const double lg = 16;

  /// Extra-large gap.
  static const double xl = 24;

  /// Double extra-large gap.
  static const double xxl = 32;

  /// Minimum accessible touch target.
  static const double touchTarget = 48;

  /// Compact window maximum width.
  static const double compactMax = 600;

  /// Medium window maximum width.
  static const double mediumMax = 840;

  /// Standard page padding.
  static const EdgeInsets page = EdgeInsets.all(lg);

  /// Compact content padding.
  static const EdgeInsets compact = EdgeInsets.all(md);

  /// Card content padding.
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Chip content padding.
  static const EdgeInsets chip = EdgeInsets.symmetric(horizontal: md, vertical: xs);

  /// Button content padding.
  static const EdgeInsets button = EdgeInsets.symmetric(horizontal: xl, vertical: md);
}
