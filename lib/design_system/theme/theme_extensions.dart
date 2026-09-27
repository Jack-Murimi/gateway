import 'package:flutter/material.dart';

import '../tokens/radii.dart';
import '../tokens/spacing.dart';

/// Theme extension exposing layout spacing tokens.
@immutable
final class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Creates app spacing tokens.
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
    required this.touchTarget,
    required this.page,
    required this.compact,
    required this.card,
    required this.chip,
    required this.button,
  });

  /// Default spacing scale.
  static const AppSpacing standard = AppSpacing(
    xs: AppSpacingTokens.xs,
    sm: AppSpacingTokens.sm,
    md: AppSpacingTokens.md,
    lg: AppSpacingTokens.lg,
    xl: AppSpacingTokens.xl,
    xxl: AppSpacingTokens.xxl,
    touchTarget: AppSpacingTokens.touchTarget,
    page: AppSpacingTokens.page,
    compact: AppSpacingTokens.compact,
    card: AppSpacingTokens.card,
    chip: AppSpacingTokens.chip,
    button: AppSpacingTokens.button,
  );

  /// Extra-small gap.
  final double xs;

  /// Small gap.
  final double sm;

  /// Medium gap.
  final double md;

  /// Large gap.
  final double lg;

  /// Extra-large gap.
  final double xl;

  /// Double extra-large gap.
  final double xxl;

  /// Minimum accessible touch target.
  final double touchTarget;

  /// Standard page padding.
  final EdgeInsets page;

  /// Compact content padding.
  final EdgeInsets compact;

  /// Card content padding.
  final EdgeInsets card;

  /// Chip content padding.
  final EdgeInsets chip;

  /// Button content padding.
  final EdgeInsets button;

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? touchTarget,
    EdgeInsets? page,
    EdgeInsets? compact,
    EdgeInsets? card,
    EdgeInsets? chip,
    EdgeInsets? button,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      touchTarget: touchTarget ?? this.touchTarget,
      page: page ?? this.page,
      compact: compact ?? this.compact,
      card: card ?? this.card,
      chip: chip ?? this.chip,
      button: button ?? this.button,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }

    return AppSpacing(
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      touchTarget: _lerpDouble(touchTarget, other.touchTarget, t),
      page: EdgeInsets.lerp(page, other.page, t) ?? page,
      compact: EdgeInsets.lerp(compact, other.compact, t) ?? compact,
      card: EdgeInsets.lerp(card, other.card, t) ?? card,
      chip: EdgeInsets.lerp(chip, other.chip, t) ?? chip,
      button: EdgeInsets.lerp(button, other.button, t) ?? button,
    );
  }
}

/// Theme extension exposing corner radius tokens.
@immutable
final class AppRadii extends ThemeExtension<AppRadii> {
  /// Creates radius tokens.
  const AppRadii({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.card,
    required this.chip,
  });

  /// Default radius scale.
  static const AppRadii standard = AppRadii(
    sm: AppRadiiTokens.sm,
    md: AppRadiiTokens.md,
    lg: AppRadiiTokens.lg,
    xl: AppRadiiTokens.xl,
    card: AppRadiiTokens.card,
    chip: AppRadiiTokens.chip,
  );

  /// Small radius.
  final double sm;

  /// Medium radius.
  final double md;

  /// Large radius.
  final double lg;

  /// Extra-large radius.
  final double xl;

  /// Card border radius.
  final BorderRadius card;

  /// Chip border radius.
  final BorderRadius chip;

  @override
  AppRadii copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    BorderRadius? card,
    BorderRadius? chip,
  }) {
    return AppRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      card: card ?? this.card,
      chip: chip ?? this.chip,
    );
  }

  @override
  AppRadii lerp(ThemeExtension<AppRadii>? other, double t) {
    if (other is! AppRadii) {
      return this;
    }

    return AppRadii(
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      card: BorderRadius.lerp(card, other.card, t) ?? card,
      chip: BorderRadius.lerp(chip, other.chip, t) ?? chip,
    );
  }
}

/// Design token accessors for a build context.
extension AppThemeTokens on BuildContext {
  /// App spacing tokens.
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? AppSpacing.standard;

  /// App radius tokens.
  AppRadii get radii =>
      Theme.of(this).extension<AppRadii>() ?? AppRadii.standard;
}

double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
