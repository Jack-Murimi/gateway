import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import 'app_card.dart';

/// KPI summary card for dashboards and reports.
class StatCard extends StatelessWidget {
  /// Creates a stat card.
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.supportingText,
  });

  /// KPI label.
  final String label;

  /// KPI value.
  final String value;

  /// Optional icon.
  final IconData? icon;

  /// Optional supporting text.
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = Theme.of(context).colorScheme;

    return AppCard(
      semanticLabel: '$label $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (icon != null) Icon(icon, color: colors.primary),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          if (supportingText != null) ...[
            SizedBox(height: spacing.xs),
            Text(supportingText!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
