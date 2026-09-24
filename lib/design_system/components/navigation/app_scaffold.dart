import 'package:flutter/material.dart';

import '../../tokens/spacing.dart';
import '../../theme/theme_extensions.dart';

/// Destination used by [AppScaffold] adaptive navigation.
class AppNavDestination {
  /// Creates an app navigation destination.
  const AppNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
  });

  /// Destination label.
  final String label;

  /// Destination icon.
  final IconData icon;

  /// Optional selected icon.
  final IconData? selectedIcon;
}

/// Adaptive app scaffold using bottom navigation on phones and rail on tablets.
class AppScaffold extends StatelessWidget {
  /// Creates an app scaffold.
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.actions,
  });

  /// Screen title.
  final String title;

  /// Screen body.
  final Widget body;

  /// Navigation destinations.
  final List<AppNavDestination> destinations;

  /// Current navigation index.
  final int selectedIndex;

  /// Destination selection callback.
  final ValueChanged<int> onDestinationSelected;

  /// Optional app bar actions.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < AppSpacingTokens.compactMax;

    if (compact) {
      return Scaffold(
        appBar: AppBar(title: Text(title), actions: actions),
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: [
            for (final item in destinations)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon ?? item.icon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    final spacing = context.spacing;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon ?? item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
            VerticalDivider(width: spacing.xs),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
