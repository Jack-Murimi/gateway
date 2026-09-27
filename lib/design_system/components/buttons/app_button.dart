import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Visual priority for [AppButton].
enum AppButtonVariant { primary, secondary, danger }

/// Design-system button with accessible sizing and optional loading state.
class AppButton extends StatelessWidget {
  /// Creates an app button.
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.semanticLabel,
  });

  /// Visible button label.
  final String label;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Button visual style.
  final AppButtonVariant variant;

  /// Whether to show a loading indicator and disable the button.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Accessible label override.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null && !isLoading;
    final child = _ButtonContent(
      label: label,
      icon: icon,
      isLoading: isLoading,
    );

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(spacing.touchTarget)),
      padding: WidgetStatePropertyAll(spacing.button),
    );

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      ),
      AppButtonVariant.danger => FilledButton(
        onPressed: enabled ? onPressed : null,
        style: style.copyWith(
          backgroundColor: WidgetStatePropertyAll(colorScheme.error),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onError),
        ),
        child: child,
      ),
    };

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      enabled: enabled,
      child: button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    if (isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: spacing.lg,
            child: const CircularProgressIndicator(
              strokeWidth: AppProgressIndicator.strokeWidth,
            ),
          ),
          SizedBox(width: spacing.sm),
          Text(label),
        ],
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        SizedBox(width: spacing.sm),
        Text(label),
      ],
    );
  }
}

/// Shared progress indicator dimensions.
abstract final class AppProgressIndicator {
  /// Stroke width for inline loaders.
  static const double strokeWidth = 2;
}
