import 'package:flutter/material.dart';

/// Semantic colors for status, alerts, and feedback.
/// Independent of brand seed to ensure consistent meaning across themes.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDanger,
    required this.onDangerContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfo,
    required this.onInfoContainer,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color onSuccessContainer;

  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color onWarningContainer;

  final Color danger;
  final Color dangerContainer;
  final Color onDanger;
  final Color onDangerContainer;

  final Color info;
  final Color infoContainer;
  final Color onInfo;
  final Color onInfoContainer;

  static const light = AppSemanticColors(
    success: Color(0xFF2E7D32),
    successContainer: Color(0xFFC8E6C9),
    onSuccess: Color(0xFFFFFFFF),
    onSuccessContainer: Color(0xFF1B5E20),
    warning: Color(0xFFF57C00),
    warningContainer: Color(0xFFFFE0B2),
    onWarning: Color(0xFFFFFFFF),
    onWarningContainer: Color(0xFFE65100),
    danger: Color(0xFFC62828),
    dangerContainer: Color(0xFFFFCDD2),
    onDanger: Color(0xFFFFFFFF),
    onDangerContainer: Color(0xFFB71C1C),
    info: Color(0xFF1565C0),
    infoContainer: Color(0xFFBBDEFB),
    onInfo: Color(0xFFFFFFFF),
    onInfoContainer: Color(0xFF0D47A1),
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF66BB6A),
    successContainer: Color(0xFF1B5E20),
    onSuccess: Color(0xFF003300),
    onSuccessContainer: Color(0xFFC8E6C9),
    warning: Color(0xFFFFB74D),
    warningContainer: Color(0xFFE65100),
    onWarning: Color(0xFF3E2723),
    onWarningContainer: Color(0xFFFFE0B2),
    danger: Color(0xFFEF5350),
    dangerContainer: Color(0xFFB71C1C),
    onDanger: Color(0xFF3E0000),
    onDangerContainer: Color(0xFFFFCDD2),
    info: Color(0xFF42A5F5),
    infoContainer: Color(0xFF0D47A1),
    onInfo: Color(0xFF002171),
    onInfoContainer: Color(0xFFBBDEFB),
  );

  @override
  ThemeExtension<AppSemanticColors> copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccess,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? onWarningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? onDanger,
    Color? onDangerContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfo,
    Color? onInfoContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccess: onSuccess ?? this.onSuccess,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDanger: onDanger ?? this.onDanger,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfo: onInfo ?? this.onInfo,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  ThemeExtension<AppSemanticColors> lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      onDangerContainer: Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}

/// Extension to access semantic colors from BuildContext.
extension SemanticColorsExtension on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
