import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../tokens/breakpoints.dart';
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

/// Adaptive app scaffold using bottom navigation on phones, rail on tablets, and sidebar on large screens.
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
    final sizeClass = context.windowSizeClass;
    final spacing = context.spacing;

    // Compact: Bottom navigation
    if (sizeClass == WindowSizeClass.compact) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: _AppDrawer(),
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

    // Large: Full sidebar navigation
    if (sizeClass == WindowSizeClass.large) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              _NavigationSidebar(
                title: title,
                destinations: destinations,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
              ),
              VerticalDivider(width: spacing.xs),
              Expanded(
                child: Column(
                  children: [
                    AppBar(title: Text(title), actions: actions),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Medium/Expanded: Navigation rail
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

/// App drawer with additional pages.
class _AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            child: Row(
              children: [
                Icon(Icons.local_fire_department, color: colorScheme.primary, size: 32),
                SizedBox(width: spacing.sm),
                Text(
                  'Gateway',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('People'),
            onTap: () {
              Navigator.pop(context);
              context.go('/people');
            },
          ),
          ListTile(
            leading: Icon(Icons.local_shipping),
            title: const Text('Suppliers'),
            onTap: () {
              Navigator.pop(context);
              context.go('/suppliers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Sales History'),
            onTap: () {
              Navigator.pop(context);
              context.go('/sales-history');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Branch Management'),
            onTap: () {
              Navigator.pop(context);
              context.go('/branches');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

/// Full sidebar navigation for large screens.
class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final String title;
  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: 200,
        child: Column(
          children: [
            Padding(
              padding: spacing.page,
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: colorScheme.primary),
                  SizedBox(width: spacing.sm),
                  Text(
                    'Gateway',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final item = destinations[index];
                  final selected = index == selectedIndex;

                  return _SidebarDestination(
                    label: item.label,
                    icon: selected
                        ? (item.selectedIcon ?? item.icon)
                        : item.icon,
                    selected: selected,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single sidebar destination item.
class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected ? colorScheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: spacing.md),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




