import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/components/feedback/feedback_views.dart';
import '../../design_system/components/navigation/app_scaffold.dart';
import '../../design_system/tokens/breakpoints.dart';
import '../../design_system/theme/theme_extensions.dart';
import '../../features/people/domain/staff.dart';
import '../providers/connectivity_providers.dart';
import 'app_destination.dart';

/// Primary destinations (max 5 for compact bottom bar).
final _primaryDestinations = [
  const AppDestination(
    path: '/sales',
    label: 'Sales',
    icon: Icons.point_of_sale_outlined,
    selectedIcon: Icons.point_of_sale,
  ),
  const AppDestination(
    path: '/history',
    label: 'History',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  const AppDestination(
    path: '/inventory',
    label: 'Inventory',
    icon: Icons.inventory_2_outlined,
    selectedIcon: Icons.inventory_2,
  ),
  const AppDestination(
    path: '/customers',
    label: 'Customers',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  const AppDestination(
    path: '/reports',
    label: 'Reports',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    requiredRole: UserRole.director,
  ),
];

/// More destinations (shown in drawer/menu).
final _moreDestinations = [
  const AppDestination(
    path: '/suppliers',
    label: 'Suppliers',
    icon: Icons.local_shipping_outlined,
    selectedIcon: Icons.local_shipping,
  ),
  const AppDestination(
    path: '/staff',
    label: 'Staff',
    icon: Icons.badge_outlined,
    selectedIcon: Icons.badge,
    requiredRole: UserRole.director,
  ),
  const AppDestination(
    path: '/branches',
    label: 'Branches',
    icon: Icons.store_outlined,
    selectedIcon: Icons.store,
    requiredRole: UserRole.admin,
  ),
  const AppDestination(
    path: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

/// App shell with adaptive navigation.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // ponytail: Mock role. Replace with actual auth provider when backend ready.
  final _currentRole = UserRole.admin;

  List<AppDestination> get _filteredPrimary =>
      _primaryDestinations.where((d) => d.canAccess(_currentRole)).toList();

  List<AppDestination> get _filteredMore =>
      _moreDestinations.where((d) => d.canAccess(_currentRole)).toList();

  int? _selectedIndex(String currentPath) {
    final primary = _filteredPrimary;
    for (var i = 0; i < primary.length; i++) {
      if (currentPath.startsWith(primary[i].path)) return i;
    }
    return null;
  }

  String _titleForPath(String path) {
    final dest = [..._filteredPrimary, ..._filteredMore]
        .where((d) => path.startsWith(d.path))
        .firstOrNull;
    return dest?.label ?? 'Gateway';
  }

  void _onDestinationSelected(int index) {
    final dest = _filteredPrimary[index];
    context.go(dest.path);
  }

  void _showMoreMenu() {
    final sizeClass = context.windowSizeClass;
    
    if (sizeClass == WindowSizeClass.compact) {
      _showMoreBottomSheet();
    }
  }

  void _showMoreBottomSheet() {
    final spacing = context.spacing;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: spacing.page,
              child: Row(
                children: [
                  Text(
                    'More',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final dest in _filteredMore)
              ListTile(
                leading: Icon(dest.icon),
                title: Text(dest.label),
                onTap: () {
                  Navigator.pop(context);
                  context.go(dest.path);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final sizeClass = context.windowSizeClass;
    final isOnlineAsync = ref.watch(isOnlineProvider);
    
    // On compact: show 4 primary + More button
    // On larger: show all primary in nav
    final destinations = sizeClass == WindowSizeClass.compact
        ? _filteredPrimary.take(4).toList()
        : _filteredPrimary;

    return AppScaffold(
      title: _titleForPath(location),
      body: Column(
        children: [
          // Show offline banner when not connected
          isOnlineAsync.whenOrNull(
            data: (isOnline) => !isOnline ? const OfflineBanner() : null,
          ) ?? const SizedBox.shrink(),
          Expanded(child: widget.child),
        ],
      ),
      destinations: [
        for (final dest in destinations)
          AppNavDestination(
            label: dest.label,
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
          ),
        if (sizeClass == WindowSizeClass.compact && _filteredMore.isNotEmpty)
          const AppNavDestination(
            label: 'More',
            icon: Icons.more_horiz,
          ),
      ],
      selectedIndex: _selectedIndex(location),
      onDestinationSelected: (index) {
        if (sizeClass == WindowSizeClass.compact && 
            index == destinations.length) {
          _showMoreMenu();
        } else {
          _onDestinationSelected(index);
        }
      },
    );
  }
}
