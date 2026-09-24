import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Design-system card with consistent shape and padding.
class AppCard extends StatelessWidget {
  /// Creates an app card.
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
  });

  /// Card content.
  final Widget child;

  /// Optional tap handler.
  final VoidCallback? onTap;

  /// Accessible label override.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radii = context.radii;

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: radii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: spacing.card,
            child: child,
          ),
        ),
      ),
    );
  }
}
