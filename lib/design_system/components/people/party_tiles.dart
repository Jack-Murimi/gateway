import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';

/// Customer summary tile.
class CustomerTile extends StatelessWidget {
  /// Creates a customer tile.
  const CustomerTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// Customer name.
  final String name;

  /// Customer subtitle.
  final String subtitle;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _PartyTile(
      name: name,
      subtitle: subtitle,
      icon: Icons.person_outline,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Supplier summary tile.
class SupplierTile extends StatelessWidget {
  /// Creates a supplier tile.
  const SupplierTile({
    super.key,
    required this.name,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  /// Supplier name.
  final String name;

  /// Supplier subtitle.
  final String subtitle;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Optional tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _PartyTile(
      name: name,
      subtitle: subtitle,
      icon: Icons.local_shipping_outlined,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _PartyTile extends StatelessWidget {
  const _PartyTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.trailing,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      button: onTap != null,
      label: '$name, $subtitle',
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: spacing.touchTarget),
        child: ListTile(
          leading: Icon(icon),
          title: Text(name),
          subtitle: Text(subtitle),
          trailing: trailing,
          onTap: onTap,
        ),
      ),
    );
  }
}
