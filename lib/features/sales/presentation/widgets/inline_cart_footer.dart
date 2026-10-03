import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/theme/theme_extensions.dart';
import '../../../../design_system/tokens/sizes.dart';
import '../../../../design_system/tokens/typography.dart';

/// Pinned cart footer — sits at the bottom of the screen.
/// On large screens: constrained width, elevated card style, right-aligned.
/// On compact: full-width bar flush to the bottom.
class InlineCartFooter extends StatelessWidget {
  const InlineCartFooter({
    super.key,
    required this.grandTotal,
    required this.totalItems,
    required this.currency,
    required this.onSave,
    this.elevated = false,
  });

  final int grandTotal;
  final int totalItems;
  final NumberFormat currency;
  final VoidCallback? onSave;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    final content = SafeArea(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$totalItems item${totalItems == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: spacing.xs),
                Text(
                  currency.format(grandTotal),
                  style: Theme.of(context).textTheme.money?.copyWith(
                    fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onSave,
              icon: Icon(Icons.payment, size: AppSizes.iconLg),
              label: Text('Pay ${currency.format(grandTotal)}'),
            ),
          ],
        ),
      ),
    );

    if (elevated) {
      return Material(
        elevation: 8,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: colorScheme.surfaceContainerLow,
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: content,
    );
  }
}
