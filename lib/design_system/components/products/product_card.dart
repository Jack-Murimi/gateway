import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../cards/app_card.dart';
import '../status/status_badge.dart';

/// Compact product card for POS and inventory surfaces.
class ProductCard extends StatelessWidget {
  /// Creates a product card.
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.stockLabel,
    required this.status,
    this.onTap,
  });

  /// Product name.
  final String name;

  /// Formatted price.
  final String price;

  /// Branch stock label.
  final String stockLabel;

  /// Inventory status.
  final AppStatus status;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return AppCard(
      onTap: onTap,
      semanticLabel: '$name, $price, $stockLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: spacing.sm),
          Text(price, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: spacing.md),
          StatusBadge(label: stockLabel, status: status),
        ],
      ),
    );
  }
}

/// Grid-optimized product item.
class ProductGridItem extends StatelessWidget {
  /// Creates a product grid item.
  const ProductGridItem({
    super.key,
    required this.name,
    required this.price,
    required this.stockLabel,
    required this.status,
    this.onTap,
  });

  /// Product name.
  final String name;

  /// Formatted price.
  final String price;

  /// Branch stock label.
  final String stockLabel;

  /// Inventory status.
  final AppStatus status;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ProductCard(
      name: name,
      price: price,
      stockLabel: stockLabel,
      status: status,
      onTap: onTap,
    );
  }
}
