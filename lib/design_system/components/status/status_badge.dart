import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Semantic statuses used by [StatusBadge].
enum AppStatus { success, warning, danger, neutral, info }

/// Small semantic badge for inventory, payment, and workflow states.
class StatusBadge extends StatelessWidget {
  /// Creates a status badge.
  const StatusBadge({
    super.key,
    required this.label,
    required this.status,
    this.semanticLabel,
  });

  /// Visible badge label.
  final String label;

  /// Badge semantic color group.
  final AppStatus status;

  /// Accessible label override.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final spacing = context.spacing;
    final radii = context.radii;
    final (:background, :foreground) = switch (status) {
      AppStatus.success => (
        background: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
      ),
      AppStatus.warning => (
        background: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
      ),
      AppStatus.danger => (
        background: colors.errorContainer,
        foreground: colors.onErrorContainer,
      ),
      AppStatus.neutral => (
        background: colors.surfaceContainerHighest,
        foreground: colors.onSurfaceVariant,
      ),
      AppStatus.info => (
        background: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      ),
    };

    return Semantics(
      label: semanticLabel ?? label,
      child: DecoratedBox(
        decoration: BoxDecoration(color: background, borderRadius: radii.chip),
        child: Padding(
          padding: spacing.chip,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
